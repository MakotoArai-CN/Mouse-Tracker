const std = @import("std");
const builtin = @import("builtin");

pub const Platform = switch (builtin.os.tag) {
    .windows => @import("platform_windows.zig"),
    else => @compileError("Unsupported platform"),
};

pub const initPlatform = Platform.initPlatform;
pub const shutdownPlatform = Platform.shutdownPlatform;
pub const copyToClipboard = Platform.copyToClipboard;
pub const createTrayIcon = Platform.createTrayIcon;
pub const updateTrayIcon = Platform.updateTrayIcon;
pub const removeTrayIcon = Platform.removeTrayIcon;
pub const minimizeToTray = Platform.minimizeToTray;
pub const restoreFromTray = Platform.restoreFromTray;
pub const isTrayHidden = Platform.isTrayHidden;
pub const getTrayMessageId = Platform.getTrayMessageId;
pub const showTrayMenu = Platform.showTrayMenu;
pub const isWindowVisible = Platform.isWindowVisible;
pub const WindowHandle = Platform.WindowHandle;

pub const loadAppIcon = if (@hasDecl(Platform, "loadAppIcon")) Platform.loadAppIcon else loadAppIconStub;
fn loadAppIconStub() ?*anyopaque {
    return null;
}

pub const openAboutUrl = if (@hasDecl(Platform, "openAboutUrl")) Platform.openAboutUrl else openAboutUrlStub;
fn openAboutUrlStub(hwnd: ?*anyopaque) void {
    _ = hwnd;
}

pub const TRAY_CMD_RESTORE = Platform.TRAY_CMD_RESTORE;
pub const TRAY_CMD_ABOUT = Platform.TRAY_CMD_ABOUT;
pub const TRAY_CMD_TOGGLE_LOCK = Platform.TRAY_CMD_TOGGLE_LOCK;
pub const TRAY_CMD_TOGGLE_FOLLOW = Platform.TRAY_CMD_TOGGLE_FOLLOW;
pub const TRAY_CMD_EXIT = Platform.TRAY_CMD_EXIT;