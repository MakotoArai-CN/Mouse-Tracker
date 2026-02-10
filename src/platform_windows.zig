const std = @import("std");
const windows = std.os.windows;
const builtin = @import("builtin");

pub const WindowHandle = windows.HWND;

const HWND = windows.HWND;
const UINT = windows.UINT;
const WPARAM = windows.WPARAM;
const LPARAM = windows.LPARAM;
const LRESULT = windows.LRESULT;
const CALLBACK = windows.WINAPI;
const INT = i32;
const LPCSTR = [*:0]const u8;
const LPCWSTR = [*:0]const u16;
const DWORD = u32;
const BOOL = windows.BOOL;
const HINSTANCE = windows.HINSTANCE;
const HICON = *anyopaque;

const POINT = extern struct {
    x: INT = 0,
    y: INT = 0,
};

const NOTIFYICONDATAW = extern struct {
    cbSize: UINT = @sizeOf(NOTIFYICONDATAW),
    hWnd: HWND,
    uID: UINT,
    uFlags: UINT = 0,
    uCallbackMessage: UINT = 0,
    hIcon: ?HICON = null,
    szTip: [128]u16 = [_]u16{0} ** 128,
    dwState: DWORD = 0,
    dwStateMask: DWORD = 0,
    szInfo: [256]u16 = [_]u16{0} ** 256,
    union_field: u32 = 0,
    szInfoTitle: [64]u16 = [_]u16{0} ** 64,
    dwInfoFlags: UINT = 0,
    guidItem: [16]u8 = [_]u8{0} ** 16,
    hBalloonIcon: ?HICON = null,
};

const NIM_ADD: UINT = 0;
const NIM_MODIFY: UINT = 1;
const NIM_DELETE: UINT = 2;

const NIF_MESSAGE: UINT = 0x00000001;
const NIF_ICON: UINT = 0x00000002;
const NIF_TIP: UINT = 0x00000004;
const NIF_SHOWTIP: UINT = 0x00000080;

const WM_USER: UINT = 0x0400;
const WM_TRAYICON: UINT = WM_USER + 1;

pub const TRAY_CMD_RESTORE: UINT = 4001;
pub const TRAY_CMD_ABOUT: UINT = 4002;
pub const TRAY_CMD_TOGGLE_LOCK: UINT = 4003;
pub const TRAY_CMD_TOGGLE_FOLLOW: UINT = 4004;
pub const TRAY_CMD_EXIT: UINT = 4005;

const CF_UNICODETEXT: UINT = 13;
const GMEM_MOVEABLE: DWORD = 0x0002;

const MF_STRING: UINT = 0x00000000;
const MF_SEPARATOR: UINT = 0x00000800;

const TPM_LEFTALIGN: UINT = 0x0000;
const TPM_RIGHTBUTTON: UINT = 0x0002;

const IMAGE_ICON: UINT = 1;
const LR_DEFAULTSIZE: UINT = 0x00000040;
const LR_SHARED: UINT = 0x00008000;

const SW_SHOW: INT = 5;

// ============================================================================
// Windows API
// ============================================================================
extern "shell32" fn Shell_NotifyIconW(dwMessage: UINT, pnid: *const NOTIFYICONDATAW) callconv(CALLBACK) BOOL;
extern "shell32" fn ShellExecuteW(hwnd: ?HWND, lpOperation: ?LPCWSTR, lpFile: ?LPCWSTR, lpParameters: ?LPCWSTR, lpDirectory: ?LPCWSTR, nShowCmd: INT) callconv(CALLBACK) ?*anyopaque;

extern "user32" fn SetForegroundWindow(hWnd: ?HWND) callconv(CALLBACK) BOOL;
extern "user32" fn CreatePopupMenu() callconv(CALLBACK) ?windows.HMENU;
extern "user32" fn DestroyMenu(hMenu: ?windows.HMENU) callconv(CALLBACK) BOOL;
extern "user32" fn AppendMenuW(hMenu: ?windows.HMENU, uFlags: UINT, uIDNewItem: usize, lpNewItem: ?LPCWSTR) callconv(CALLBACK) BOOL;
extern "user32" fn TrackPopupMenu(hMenu: ?windows.HMENU, uFlags: UINT, x: INT, y: INT, nReserved: INT, hWnd: HWND, prcRect: ?*const anyopaque) callconv(CALLBACK) BOOL;
extern "user32" fn GetCursorPos(pt: *POINT) callconv(CALLBACK) BOOL;
extern "user32" fn PostMessageA(hWnd: ?HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM) callconv(CALLBACK) BOOL;
extern "user32" fn LoadImageA(hInst: ?HINSTANCE, name: LPCSTR, img_type: UINT, cx: INT, cy: INT, fuLoad: UINT) callconv(CALLBACK) ?HICON;
extern "user32" fn IsWindowVisible(hWnd: HWND) callconv(CALLBACK) BOOL;

extern "user32" fn OpenClipboard(hWndNewOwner: ?HWND) callconv(CALLBACK) BOOL;
extern "user32" fn CloseClipboard() callconv(CALLBACK) BOOL;
extern "user32" fn EmptyClipboard() callconv(CALLBACK) BOOL;
extern "user32" fn SetClipboardData(uFormat: UINT, hMem: ?windows.HANDLE) callconv(CALLBACK) ?windows.HANDLE;

extern "kernel32" fn GlobalAlloc(uFlags: DWORD, dwBytes: usize) callconv(CALLBACK) ?windows.HANDLE;
extern "kernel32" fn GlobalFree(hMem: ?windows.HANDLE) callconv(CALLBACK) ?windows.HANDLE;
extern "kernel32" fn GlobalLock(hMem: windows.HANDLE) callconv(CALLBACK) ?*anyopaque;
extern "kernel32" fn GlobalUnlock(hMem: windows.HANDLE) callconv(CALLBACK) BOOL;
extern "kernel32" fn GetModuleHandleW(lpModuleName: ?LPCWSTR) callconv(CALLBACK) ?HINSTANCE;

// ============================================================================
// Global State
// ============================================================================
var g_tray_hwnd: ?HWND = null;
var g_tray_icon_id: UINT = 1;
var g_is_tray_hidden: bool = false;

// ============================================================================
// Comptime UTF-8 to UTF-16
// ============================================================================
fn ComptimeUtf16(comptime len: usize) type {
    return struct {
        data: [len:0]u16,
        pub fn ptr(self: *const @This()) LPCWSTR {
            return @ptrCast(&self.data);
        }
    };
}

fn comptimeUtf8ToUtf16(comptime s: []const u8) ComptimeUtf16(comptimeUtf16Len(s)) {
    const out_len = comptime comptimeUtf16Len(s);
    var buf: [out_len:0]u16 = undefined;
    comptime {
        var i: usize = 0;
        var si: usize = 0;
        while (si < s.len) {
            const byte = s[si];
            if (byte < 0x80) {
                buf[i] = byte;
                si += 1;
            } else if (byte & 0xE0 == 0xC0) {
                buf[i] = @as(u16, byte & 0x1F) << 6 | @as(u16, s[si + 1] & 0x3F);
                si += 2;
            } else if (byte & 0xF0 == 0xE0) {
                buf[i] = @as(u16, byte & 0x0F) << 12 | @as(u16, s[si + 1] & 0x3F) << 6 | @as(u16, s[si + 2] & 0x3F);
                si += 3;
            } else {
                const cp: u21 = @as(u21, byte & 0x07) << 18 | @as(u21, s[si + 1] & 0x3F) << 12 | @as(u21, s[si + 2] & 0x3F) << 6 | @as(u21, s[si + 3] & 0x3F);
                const adjusted = cp - 0x10000;
                buf[i] = @intCast(0xD800 + (adjusted >> 10));
                i += 1;
                buf[i] = @intCast(0xDC00 + (adjusted & 0x3FF));
                si += 4;
            }
            i += 1;
        }
        buf[out_len] = 0;
    }
    return .{ .data = buf };
}

fn comptimeUtf16Len(comptime s: []const u8) usize {
    var i: usize = 0;
    var si: usize = 0;
    while (si < s.len) {
        const byte = s[si];
        if (byte < 0x80) {
            si += 1;
        } else if (byte & 0xE0 == 0xC0) {
            si += 2;
        } else if (byte & 0xF0 == 0xE0) {
            si += 3;
        } else {
            si += 4;
            i += 1;
        }
        i += 1;
    }
    return i;
}

fn utf8ToUtf16Runtime(src: []const u8, dest: []u16) usize {
    var di: usize = 0;
    var si: usize = 0;
    while (si < src.len and di < dest.len) {
        const byte = src[si];
        if (byte < 0x80) {
            dest[di] = byte;
            si += 1;
        } else if (byte & 0xE0 == 0xC0 and si + 1 < src.len) {
            dest[di] = @as(u16, byte & 0x1F) << 6 | @as(u16, src[si + 1] & 0x3F);
            si += 2;
        } else if (byte & 0xF0 == 0xE0 and si + 2 < src.len) {
            dest[di] = @as(u16, byte & 0x0F) << 12 | @as(u16, src[si + 1] & 0x3F) << 6 | @as(u16, src[si + 2] & 0x3F);
            si += 3;
        } else {
            si += 1;
            continue;
        }
        di += 1;
    }
    return di;
}

// ============================================================================
// Pre-computed menu strings
// ============================================================================
const menu_show = comptimeUtf8ToUtf16("显示/隐藏窗口");
const menu_lock = comptimeUtf8ToUtf16("锁定/解锁");
const menu_follow = comptimeUtf8ToUtf16("跟随/固定");
const menu_about = comptimeUtf8ToUtf16("关于(GitHub)");
const menu_exit = comptimeUtf8ToUtf16("退出");
const about_url = comptimeUtf8ToUtf16("https://github.com/MakotoArai-CN/mouse-tracker");
const shell_open = comptimeUtf8ToUtf16("open");

// ============================================================================
// Platform Functions
// ============================================================================
pub fn initPlatform() void {}

pub fn shutdownPlatform() void {
    if (g_tray_hwnd) |hwnd| {
        _ = removeTrayIcon(hwnd);
    }
}

pub fn copyToClipboard(text: []const u8) bool {
    if (OpenClipboard(null) == 0) return false;
    _ = EmptyClipboard();

    var wide_buf: [256]u16 = undefined;
    const wide_len = utf8ToUtf16Runtime(text, wide_buf[0 .. wide_buf.len - 1]);
    wide_buf[wide_len] = 0;

    const byte_size = (wide_len + 1) * 2;
    const handle = GlobalAlloc(GMEM_MOVEABLE, byte_size) orelse {
        _ = CloseClipboard();
        return false;
    };

    const raw_ptr = GlobalLock(handle) orelse {
        _ = GlobalFree(handle);
        _ = CloseClipboard();
        return false;
    };

    const dest: [*]u16 = @ptrCast(@alignCast(raw_ptr));
    for (0..wide_len + 1) |i| {
        dest[i] = wide_buf[i];
    }
    _ = GlobalUnlock(handle);

    const result = SetClipboardData(CF_UNICODETEXT, handle);
    if (result == null) {
        _ = GlobalFree(handle);
    }
    _ = CloseClipboard();
    return result != null;
}

pub fn createTrayIcon(hwnd: HWND, hicon: ?*anyopaque, tip_text: []const u8) bool {
    g_tray_hwnd = hwnd;
    var nid: NOTIFYICONDATAW = .{
        .hWnd = hwnd,
        .uID = g_tray_icon_id,
        .uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP | NIF_SHOWTIP,
        .uCallbackMessage = WM_TRAYICON,
        .hIcon = hicon,
    };
    _ = utf8ToUtf16Runtime(tip_text, nid.szTip[0..127]);
    return Shell_NotifyIconW(NIM_ADD, &nid) != 0;
}

pub fn showTrayMenu(hwnd: HWND) void {
    const hmenu = CreatePopupMenu();
    if (hmenu == null) return;
    defer _ = DestroyMenu(hmenu);

    _ = AppendMenuW(hmenu, MF_STRING, TRAY_CMD_RESTORE, menu_show.ptr());
    _ = AppendMenuW(hmenu, MF_SEPARATOR, 0, null);
    _ = AppendMenuW(hmenu, MF_STRING, TRAY_CMD_TOGGLE_LOCK, menu_lock.ptr());
    _ = AppendMenuW(hmenu, MF_STRING, TRAY_CMD_TOGGLE_FOLLOW, menu_follow.ptr());
    _ = AppendMenuW(hmenu, MF_SEPARATOR, 0, null);
    _ = AppendMenuW(hmenu, MF_STRING, TRAY_CMD_ABOUT, menu_about.ptr());
    _ = AppendMenuW(hmenu, MF_SEPARATOR, 0, null);
    _ = AppendMenuW(hmenu, MF_STRING, TRAY_CMD_EXIT, menu_exit.ptr());

    var pt: POINT = .{};
    _ = GetCursorPos(&pt);
    _ = SetForegroundWindow(hwnd);
    _ = TrackPopupMenu(hmenu, TPM_LEFTALIGN | TPM_RIGHTBUTTON, pt.x, pt.y, 0, hwnd, null);
    _ = PostMessageA(hwnd, 0, 0, 0);
}

pub fn openAboutUrl(hwnd: ?HWND) void {
    _ = ShellExecuteW(hwnd, shell_open.ptr(), about_url.ptr(), null, null, SW_SHOW);
}

pub fn updateTrayIcon(hwnd: HWND, hicon: ?*anyopaque, tip_text: []const u8) bool {
    var nid: NOTIFYICONDATAW = .{
        .hWnd = hwnd,
        .uID = g_tray_icon_id,
        .uFlags = NIF_ICON | NIF_TIP,
        .hIcon = hicon,
    };
    _ = utf8ToUtf16Runtime(tip_text, nid.szTip[0..127]);
    return Shell_NotifyIconW(NIM_MODIFY, &nid) != 0;
}

pub fn removeTrayIcon(hwnd: HWND) bool {
    var nid: NOTIFYICONDATAW = .{
        .hWnd = hwnd,
        .uID = g_tray_icon_id,
        .uFlags = 0,
    };
    const result = Shell_NotifyIconW(NIM_DELETE, &nid) != 0;
    g_tray_hwnd = null;
    return result;
}

pub fn loadAppIcon() ?*anyopaque {
    const hInst = GetModuleHandleW(null);
    return LoadImageA(
        @ptrCast(hInst),
        @ptrFromInt(1),
        IMAGE_ICON,
        0,
        0,
        LR_DEFAULTSIZE | LR_SHARED,
    );
}

pub fn minimizeToTray(hwnd: HWND) void {
    _ = hwnd;
    g_is_tray_hidden = true;
}

pub fn restoreFromTray(hwnd: HWND) void {
    _ = hwnd;
    g_is_tray_hidden = false;
}

pub fn isTrayHidden() bool {
    return g_is_tray_hidden;
}

pub fn isWindowVisible(hwnd: HWND) bool {
    return IsWindowVisible(hwnd) != 0;
}

pub fn getTrayMessageId() UINT {
    return WM_TRAYICON;
}