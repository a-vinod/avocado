const std = @import("std");
const AutoHashMap = std.AutoHashMap;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

/// Graph: a graph data structure G=(V,E)
pub const Graph = struct {
    /// Memory allocator
    allocator: Allocator,
    /// Adjacency list
    adjacency: ArrayList(AutoHashMap(usize, f32)),
    /// Is a directed graph (true) or undirected graph (false)
    isDirected: bool,

    /// Creates a new empty Graph.
    ///     allocator: memory allocator,
    ///     isDirected: true if it is directed graph and false otherwise
    pub fn init(allocator: Allocator, isDirected: bool) !Graph {
        return Graph{
            .allocator = allocator,
            .adjacency = ArrayList(AutoHashMap(usize, f32)).init(allocator),
            .isDirected = isDirected,
        };
    }

    /// Frees resources for the Graph.
    pub fn deinit(self: *Graph) void {
        for (self.adjacency.items) |*neighbors| {
            neighbors.deinit();
        }
        self.adjacency.deinit();
    }

    /// Add a vertex and return its ID.
    pub fn addVertex(self: *Graph) !usize {
        const id = self.adjacency.items.len;
        try self.adjacency.append(AutoHashMap(usize, f32).init(self.allocator));

        return id;
    }

    /// Add a weighted edge between two vertices.
    pub fn addEdge(self: *Graph, from: usize, to: usize, weight: f32) !void {
        const max_vertex_id = self.adjacency.items.len;

        if (from >= max_vertex_id or to >= max_vertex_id) {
            return error.InvalidVertexId;
        }

        try self.adjacency.items[from].put(to, weight);
        if (!self.isDirected) {
            try self.adjacency.items[to].put(from, weight);
        }
    }

    /// Pretty-print the graph (DOT).
    pub fn prettyPrint(self: *Graph) !void {
        const stdout = std.io.getStdOut().writer();

        try stdout.writeAll("graph g {\n");
        for (self.adjacency.items, 0..) |neighbors, i| {
            var iterator = neighbors.iterator();
            while (iterator.next()) |neighbor| {
                if (self.isDirected) {
                    try stdout.print("    {d} -> {d}\n", .{ i, neighbor.key_ptr.* });
                } else if (i < neighbor.key_ptr.*) {
                    try stdout.print("    {d} -- {d}\n", .{ i, neighbor.key_ptr.* });
                }
            }
        }
        try stdout.writeAll("}\n");
    }
};

test "graph basic operations" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Create an undirected graph
    var graph = try Graph.init(allocator, false);
    defer graph.deinit();

    // Add vertices
    const v0 = try graph.addVertex();
    const v1 = try graph.addVertex();
    const v2 = try graph.addVertex();

    try std.testing.expectEqual(@as(usize, 0), v0);
    try std.testing.expectEqual(@as(usize, 1), v1);
    try std.testing.expectEqual(@as(usize, 2), v2);

    // Add edges
    try graph.addEdge(v0, v1, 2.5);
    try graph.addEdge(v1, v2, 3.0);
    try graph.addEdge(v2, v0, 1.5);

    // Verify graph size
    try std.testing.expectEqual(@as(usize, 3), graph.adjacency.items.len);

    // Check edges exist (undirected, so check both ways)
    try std.testing.expect(graph.adjacency.items[v0].contains(v1));
    try std.testing.expect(graph.adjacency.items[v1].contains(v0));
    try std.testing.expect(graph.adjacency.items[v1].contains(v2));
    try std.testing.expect(graph.adjacency.items[v2].contains(v1));
    try std.testing.expect(graph.adjacency.items[v2].contains(v0));
    try std.testing.expect(graph.adjacency.items[v0].contains(v2));

    // Check edge weights
    try std.testing.expectEqual(@as(f32, 2.5), graph.adjacency.items[v0].get(v1).?);
    try std.testing.expectEqual(@as(f32, 3.0), graph.adjacency.items[v1].get(v2).?);
    try std.testing.expectEqual(@as(f32, 1.5), graph.adjacency.items[v2].get(v0).?);
}
