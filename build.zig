const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .os_tag = .windows,
        },
    });
    const optimize = b.standardOptimizeOption(.{});

    const root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "mouse-tracker",
        .root_module = root_module,
    });

    exe.subsystem = .Windows;

    exe.addWin32ResourceFile(.{
        .file = b.path("resources/resource.rc"),
    });

    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("kernel32");
    exe.linkSystemLibrary("dwmapi");
    exe.linkSystemLibrary("msimg32");
    exe.linkSystemLibrary("shell32");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    // Release step
    const release_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = .ReleaseSmall,
    });

    const release_exe = b.addExecutable(.{
        .name = "mouse-tracker",
        .root_module = release_module,
    });

    release_exe.subsystem = .Windows;

    release_exe.addWin32ResourceFile(.{
        .file = b.path("resources/resource.rc"),
    });

    release_exe.linkSystemLibrary("gdi32");
    release_exe.linkSystemLibrary("user32");
    release_exe.linkSystemLibrary("kernel32");
    release_exe.linkSystemLibrary("dwmapi");
    release_exe.linkSystemLibrary("msimg32");
    release_exe.linkSystemLibrary("shell32");

    const release_install = b.addInstallArtifact(release_exe, .{});
    const release_step = b.step("release", "Build release optimized binary");
    release_step.dependOn(&release_install.step);
}