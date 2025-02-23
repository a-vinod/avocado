const std = @import("std");
const AutoHashMap = std.AutoHashMap;

const Graph = @import("avocado").Graph;

const ParseResult = struct {
    is_comment: bool,
    edge: []const usize,
};

/// Parse a line of the data set
pub fn parseLine(line: []u8) !ParseResult {
    var edge: [2]usize = .{ 0, 0 };

    if (line[0] == '%' or line.len == 0) {
        return ParseResult{
            .is_comment = true,
            .edge = &edge,
        };
    }
    var iter = std.mem.split(u8, line, " ");
    var i: usize = 0;
    while (iter.next()) |val| {
        if (i >= edge.len) return error.TooManyValues;
        edge[i] = try std.fmt.parseInt(usize, val, 10);
        i += 1;
    }

    return ParseResult{
        .is_comment = false,
        .edge = &edge,
    };
}

pub fn main() !void {
    // Get general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create an undirected graph
    var graph = try Graph.init(allocator, false);
    defer graph.deinit();

    var file = try std.fs.cwd().openFile("ucidata-zachary/out.ucidata-zachary", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    // Map vertices in the data set to vertices in the graph
    var map = AutoHashMap(usize, usize).init(allocator);
    defer map.deinit();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const parsedLine = try parseLine(line);
        if (parsedLine.is_comment)
            continue;

        const from = parsedLine.edge[0];
        const to = parsedLine.edge[1];

        if (!map.contains(from)) {
            try map.put(from, try graph.addVertex());
        }
        if (!map.contains(to)) {
            try map.put(to, try graph.addVertex());
        }
        const from_vertex = map.get(from).?;
        const to_vertex = map.get(to).?;
        try graph.addEdge(from_vertex, to_vertex, 1.0);
    }

    try graph.prettyPrint();
}
