const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("zig-tree-sitter", .{
        .source_file = .{ .path = "src/lib.zig" },
    });

    const lib = b.addStaticLibrary(.{
        .name = "zig-tree-sitter",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "src/lib.zig" },
    });
    linkTreeSitter(lib);
    b.installArtifact(lib);

    var main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    main_tests.linkLibrary(lib);
    main_tests.addIncludePath(.{ .path = "tree-sitter-json/src" });
    main_tests.addCSourceFile(.{ .file = .{ .path = "tree-sitter-json/src/parser.c" }, .flags = &.{} });

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&lib.step);
    test_step.dependOn(&run_main_tests.step);
}

pub fn linkTreeSitter(exe: *std.build.Step.Compile) void {
    exe.linkLibC();
    exe.addCSourceFile(.{ .file = .{ .path = "tree-sitter/lib/src/lib.c" }, .flags = &.{} });
    exe.addIncludePath(.{ .path = "tree-sitter/lib/src" });
    exe.addIncludePath(.{ .path = "tree-sitter/lib/include" });
}
