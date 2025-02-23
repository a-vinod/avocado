const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // Create an executable for the zachary_karate_club example
    const exe = b.addExecutable(.{
        .name = "zachary_karate_club",
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add the avocado library as a module
    const avocado_module = b.addModule("avocado", .{
        .root_source_file = b.path("../../lib/avocado/avocado.zig"),
    });

    // Add the module dependency to the executable
    exe.root_module.addImport("avocado", avocado_module);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step
    b.installArtifact(exe);

    // Creates a step for running the executable
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    // Add a "run" step that will run the executable after building
    const run_step = b.step("run", "Run the zachary_karate_club example");
    run_step.dependOn(&run_cmd.step);
}
