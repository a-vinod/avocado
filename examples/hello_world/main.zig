const std = @import("std");
const Graph = @import("avocado").Graph;

pub fn main() !void {
    // Get general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create an undirected graph
    var graph = try Graph.init(allocator, false);
    defer graph.deinit();

    // Add some vertices
    const v0 = try graph.addVertex();
    const v1 = try graph.addVertex();
    const v2 = try graph.addVertex();
    const v3 = try graph.addVertex();

    // Create a diamond-shaped graph
    try graph.addEdge(v0, v1, 1.5);
    try graph.addEdge(v0, v2, 2.0);
    try graph.addEdge(v1, v3, 1.0);
    try graph.addEdge(v2, v3, 3.0);

    // Print the graph structure
    try graph.prettyPrint();
}
