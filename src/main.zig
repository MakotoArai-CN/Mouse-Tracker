const std = @import("std");
const windows = std.os.windows;
const builtin = @import("builtin");

const platform = switch (builtin.os.tag) {
    .windows => @import("platform_windows.zig"),
    else => @compileError("Unsupported platform"),
};

// ============================================================================
// Windows API Type Definitions
// ============================================================================
const GdiHandle = opaque {};
const HWND = windows.HWND;
const HINSTANCE = windows.HINSTANCE;
const HDC = *GdiHandle;
const HBRUSH = *GdiHandle;
const HPEN = *GdiHandle;
const HFONT = *GdiHandle;
const HGDIOBJ = *GdiHandle;
const HICON = *GdiHandle;
const HCURSOR = HICON;
const HRGN = *GdiHandle;
const HMENU = *GdiHandle;
const HBITMAP = *GdiHandle;

const WPARAM = windows.WPARAM;
const LPARAM = windows.LPARAM;
const LRESULT = windows.LRESULT;
const UINT = windows.UINT;
const DWORD = windows.DWORD;
const WORD = windows.WORD;
const BOOL = windows.BOOL;
const LONG = windows.LONG;
const BYTE = windows.BYTE;
const LPVOID = windows.LPVOID;
const UINT_PTR = usize;
const TIMERPROC = ?*const fn (HWND, UINT, UINT_PTR, DWORD) callconv(CALLBACK) void;
const INT = i32;
const COLORREF = DWORD;
const CALLBACK = windows.WINAPI;
const LPCSTR = [*:0]const u8;
const LPSTR = [*:0]u8;
const LPCWSTR = [*:0]const u16;
const LPWSTR = [*:0]u16;

const POINT = extern struct {
    x: LONG = 0,
    y: LONG = 0,
};

const RECT = extern struct {
    left: LONG = 0,
    top: LONG = 0,
    right: LONG = 0,
    bottom: LONG = 0,
};

const WNDCLASSEXA = extern struct {
    cbSize: UINT = @sizeOf(WNDCLASSEXA),
    style: UINT = 0,
    lpfnWndProc: WNDPROC,
    cbClsExtra: INT = 0,
    cbWndExtra: INT = 0,
    hInstance: ?HINSTANCE = null,
    hIcon: ?HICON = null,
    hCursor: ?HCURSOR = null,
    hbrBackground: ?HBRUSH = null,
    lpszMenuName: ?LPCSTR = null,
    lpszClassName: LPCSTR,
    hIconSm: ?HICON = null,
};

const PAINTSTRUCT = extern struct {
    hdc: ?HDC = null,
    fErase: BOOL = 0,
    rcPaint: RECT = .{},
    fRestore: BOOL = 0,
    fIncUpdate: BOOL = 0,
    rgbReserved: [32]BYTE = [_]BYTE{0} ** 32,
};

const MSG = extern struct {
    hwnd: ?HWND = null,
    message: UINT = 0,
    wParam: WPARAM = 0,
    lParam: LPARAM = 0,
    time: DWORD = 0,
    pt: POINT = .{},
};

const BLENDFUNCTION = extern struct {
    BlendOp: BYTE = 0,
    BlendFlags: BYTE = 0,
    SourceConstantAlpha: BYTE = 255,
    AlphaFormat: BYTE = 0,
};

const BITMAPINFOHEADER = extern struct {
    biSize: DWORD = @sizeOf(BITMAPINFOHEADER),
    biWidth: LONG = 0,
    biHeight: LONG = 0,
    biPlanes: WORD = 1,
    biBitCount: WORD = 32,
    biCompression: DWORD = 0,
    biSizeImage: DWORD = 0,
    biXPelsPerMeter: LONG = 0,
    biYPelsPerMeter: LONG = 0,
    biClrUsed: DWORD = 0,
    biClrImportant: DWORD = 0,
};

const RGBQUAD = extern struct {
    rgbBlue: BYTE = 0,
    rgbGreen: BYTE = 0,
    rgbRed: BYTE = 0,
    rgbReserved: BYTE = 0,
};

const BITMAPINFO = extern struct {
    bmiHeader: BITMAPINFOHEADER = .{},
    bmiColors: [1]RGBQUAD = .{.{}},
};

const LOGFONTA = extern struct {
    lfHeight: LONG = 0,
    lfWidth: LONG = 0,
    lfEscapement: LONG = 0,
    lfOrientation: LONG = 0,
    lfWeight: LONG = 0,
    lfItalic: BYTE = 0,
    lfUnderline: BYTE = 0,
    lfStrikeOut: BYTE = 0,
    lfCharSet: BYTE = 1,
    lfOutPrecision: BYTE = 0,
    lfClipPrecision: BYTE = 0,
    lfQuality: BYTE = 5,
    lfPitchAndFamily: BYTE = 0,
    lfFaceName: [32]u8 = [_]u8{0} ** 32,
};

const MARGINS = extern struct {
    cxLeftWidth: INT = 0,
    cxRightWidth: INT = 0,
    cyTopHeight: INT = 0,
    cyBottomHeight: INT = 0,
};

const DEVMODEA = extern struct {
    dmDeviceName: [32]u8 = [_]u8{0} ** 32,
    dmSpecVersion: WORD = 0,
    dmDriverVersion: WORD = 0,
    dmSize: WORD = @sizeOf(DEVMODEA),
    dmDriverExtra: WORD = 0,
    dmFields: DWORD = 0,
    u1: extern union {
        s1: extern struct {
            dmOrientation: i16,
            dmPaperSize: i16,
            dmPaperLength: i16,
            dmPaperWidth: i16,
            dmScale: i16,
            dmCopies: i16,
            dmDefaultSource: i16,
            dmPrintQuality: i16,
        },
        s2: extern struct {
            dmPosition: POINT,
            dmDisplayOrientation: DWORD,
            dmDisplayFixedOutput: DWORD,
        },
    } = undefined,
    dmColor: i16 = 0,
    dmDuplex: i16 = 0,
    dmYResolution: i16 = 0,
    dmTTOption: i16 = 0,
    dmCollate: i16 = 0,
    dmFormName: [32]u8 = [_]u8{0} ** 32,
    dmLogPixels: WORD = 0,
    dmBitsPerPel: DWORD = 0,
    dmPelsWidth: DWORD = 0,
    dmPelsHeight: DWORD = 0,
    u2: extern union {
        dmDisplayFlags: DWORD,
        dmNup: DWORD,
    } = .{ .dmDisplayFlags = 0 },
    dmDisplayFrequency: DWORD = 0,
    dmICMMethod: DWORD = 0,
    dmICMIntent: DWORD = 0,
    dmMediaType: DWORD = 0,
    dmDitherType: DWORD = 0,
    dmReserved1: DWORD = 0,
    dmReserved2: DWORD = 0,
    dmPanningWidth: DWORD = 0,
    dmPanningHeight: DWORD = 0,
};

const WNDPROC = *const fn (HWND, UINT, WPARAM, LPARAM) callconv(CALLBACK) LRESULT;

// ============================================================================
// Windows API Constants
// ============================================================================
const WM_CREATE: UINT = 0x0001;
const WM_DESTROY: UINT = 0x0002;
const WM_SIZE: UINT = 0x0005;
const WM_PAINT: UINT = 0x000F;
const WM_CLOSE: UINT = 0x0010;
const WM_ERASEBKGND: UINT = 0x0014;
const WM_NCCALCSIZE: UINT = 0x0083;
const WM_NCHITTEST: UINT = 0x0084;
const WM_TIMER: UINT = 0x0113;
const WM_KEYDOWN: UINT = 0x0100;
const WM_LBUTTONDOWN: UINT = 0x0201;
const WM_LBUTTONUP: UINT = 0x0202;
const WM_LBUTTONDBLCLK: UINT = 0x0203;
const WM_RBUTTONUP: UINT = 0x0205;
const WM_MOUSEMOVE: UINT = 0x0200;
const WM_COMMAND: UINT = 0x0111;
const WM_HOTKEY: UINT = 0x0312;

const VK_SPACE: WPARAM = 0x20;
const VK_CONTROL: WPARAM = 0x11;

const WS_POPUP: DWORD = 0x80000000;
const WS_VISIBLE: DWORD = 0x10000000;
const WS_SYSMENU: DWORD = 0x00080000;
const WS_MINIMIZEBOX: DWORD = 0x00020000;
const WS_THICKFRAME: DWORD = 0x00040000;
const WS_CLIPCHILDREN: DWORD = 0x02000000;

const WS_EX_TOPMOST: DWORD = 0x00000008;
const WS_EX_TOOLWINDOW: DWORD = 0x00000080;
const WS_EX_LAYERED: DWORD = 0x00080000;
const WS_EX_APPWINDOW: DWORD = 0x00040000;

const CS_HREDRAW: UINT = 0x0002;
const CS_VREDRAW: UINT = 0x0001;

const CW_USEDEFAULT: INT = @bitCast(@as(u32, 0x80000000));

const SW_SHOW: INT = 5;
const SW_HIDE: INT = 0;
const SW_RESTORE: INT = 9;

const SM_CXSCREEN: INT = 0;
const SM_CYSCREEN: INT = 1;

const HTCAPTION: LRESULT = 2;
const HTCLOSE: LRESULT = 20;
const HTCLIENT: LRESULT = 1;
const HTNOWHERE: LRESULT = 0;

const IDI_APPLICATION: LPCSTR = @ptrFromInt(32512);
const IDC_ARROW: LPCSTR = @ptrFromInt(32512);

const COLOR_WINDOW: INT = 5;

const DT_CENTER: UINT = 0x00000001;
const DT_VCENTER: UINT = 0x00000004;
const DT_SINGLELINE: UINT = 0x00000020;
const DT_NOPREFIX: UINT = 0x00000800;
const DT_LEFT: UINT = 0x00000000;
const DT_RIGHT: UINT = 0x00000002;
const DT_NOCLIP: UINT = 0x00000100;

const FW_NORMAL: LONG = 400;
const FW_BOLD: LONG = 700;
const FW_SEMIBOLD: LONG = 600;
const FW_LIGHT: LONG = 300;

const DEFAULT_CHARSET: BYTE = 1;
const CLEARTYPE_QUALITY: BYTE = 5;
const ANTIALIASED_QUALITY: BYTE = 4;

const TRANSPARENT: INT = 1;
const OPAQUE: INT = 2;

const PS_SOLID: INT = 0;
const PS_NULL: INT = 5;

const DIB_RGB_COLORS: UINT = 0;
const SRCCOPY: DWORD = 0x00CC0020;

const AC_SRC_OVER: BYTE = 0x00;
const AC_SRC_ALPHA: BYTE = 0x01;

const NULL_BRUSH: INT = 5;

const ENUM_CURRENT_SETTINGS: DWORD = @bitCast(@as(u32, 0xFFFFFFFF));

const RGN_AND: INT = 1;

const MONITOR_DEFAULTTONEAREST: DWORD = 0x00000002;

const SWP_NOMOVE: UINT = 0x0002;
const SWP_NOSIZE: UINT = 0x0001;
const SWP_NOZORDER: UINT = 0x0004;
const SWP_NOACTIVATE: UINT = 0x0010;
const SWP_SHOWWINDOW: UINT = 0x0040;

const LOWORD_MASK: WPARAM = 0xFFFF;

const MOD_CONTROL: UINT = 0x0002;
const MOD_NOREPEAT: UINT = 0x4000;

const HOTKEY_ID_TOGGLE_VISIBLE: INT = 1;

// ============================================================================
// Windows API Function Imports
// ============================================================================
extern "user32" fn RegisterClassExA(*const WNDCLASSEXA) callconv(CALLBACK) u16;
extern "user32" fn CreateWindowExA(DWORD, LPCSTR, LPCSTR, DWORD, INT, INT, INT, INT, ?HWND, ?HMENU, ?HINSTANCE, ?LPVOID) callconv(CALLBACK) ?HWND;
extern "user32" fn ShowWindow(HWND, INT) callconv(CALLBACK) BOOL;
extern "user32" fn UpdateWindow(HWND) callconv(CALLBACK) BOOL;
extern "user32" fn GetMessageA(*MSG, ?HWND, UINT, UINT) callconv(CALLBACK) BOOL;
extern "user32" fn TranslateMessage(*const MSG) callconv(CALLBACK) BOOL;
extern "user32" fn DispatchMessageA(*const MSG) callconv(CALLBACK) LRESULT;
extern "user32" fn DefWindowProcA(HWND, UINT, WPARAM, LPARAM) callconv(CALLBACK) LRESULT;
extern "user32" fn DestroyWindow(HWND) callconv(CALLBACK) BOOL;
extern "user32" fn PostQuitMessage(INT) callconv(CALLBACK) void;
extern "user32" fn SetTimer(HWND, UINT_PTR, UINT, TIMERPROC) callconv(CALLBACK) UINT_PTR;
extern "user32" fn KillTimer(HWND, UINT_PTR) callconv(CALLBACK) BOOL;
extern "user32" fn GetCursorPos(*POINT) callconv(CALLBACK) BOOL;
extern "user32" fn GetSystemMetrics(INT) callconv(CALLBACK) INT;
extern "user32" fn GetClientRect(HWND, *RECT) callconv(CALLBACK) BOOL;
extern "user32" fn GetWindowRect(HWND, *RECT) callconv(CALLBACK) BOOL;
extern "user32" fn InvalidateRect(?HWND, ?*const RECT, BOOL) callconv(CALLBACK) BOOL;
extern "user32" fn BeginPaint(HWND, *PAINTSTRUCT) callconv(CALLBACK) ?HDC;
extern "user32" fn EndPaint(HWND, *const PAINTSTRUCT) callconv(CALLBACK) BOOL;
extern "user32" fn GetDC(?HWND) callconv(CALLBACK) ?HDC;
extern "user32" fn ReleaseDC(?HWND, HDC) callconv(CALLBACK) INT;
extern "user32" fn LoadIconA(?HINSTANCE, LPCSTR) callconv(CALLBACK) ?HICON;
extern "user32" fn LoadCursorA(?HINSTANCE, LPCSTR) callconv(CALLBACK) ?HCURSOR;
extern "user32" fn SetWindowPos(HWND, ?HWND, INT, INT, INT, INT, UINT) callconv(CALLBACK) BOOL;
extern "user32" fn FillRect(HDC, *const RECT, HBRUSH) callconv(CALLBACK) INT;
extern "user32" fn DrawTextA(HDC, [*]const u8, INT, *RECT, UINT) callconv(CALLBACK) INT;
extern "user32" fn DrawTextW(HDC, LPCWSTR, INT, *RECT, UINT) callconv(CALLBACK) INT;
extern "kernel32" fn MultiByteToWideChar(CodePage: UINT, dwFlags: DWORD, lpMultiByteStr: [*]const u8, cbMultiByte: INT, lpWideCharStr: ?LPWSTR, cchWideChar: INT) callconv(CALLBACK) INT;
extern "user32" fn SendMessageA(HWND, UINT, WPARAM, LPARAM) callconv(CALLBACK) LRESULT;
extern "user32" fn ReleaseCapture() callconv(CALLBACK) BOOL;
extern "user32" fn SetLayeredWindowAttributes(HWND, COLORREF, BYTE, DWORD) callconv(CALLBACK) BOOL;
extern "user32" fn EnumDisplaySettingsA(?LPCSTR, DWORD, *DEVMODEA) callconv(CALLBACK) BOOL;
extern "user32" fn ScreenToClient(HWND, *POINT) callconv(CALLBACK) BOOL;
extern "user32" fn SetCapture(HWND) callconv(CALLBACK) ?HWND;
extern "user32" fn IsWindowVisible(HWND) callconv(CALLBACK) BOOL;
extern "user32" fn GetKeyState(nVirtKey: INT) callconv(CALLBACK) i16;
extern "user32" fn RegisterHotKey(hWnd: ?HWND, id: INT, fsModifiers: UINT, vk: UINT) callconv(CALLBACK) BOOL;
extern "user32" fn UnregisterHotKey(hWnd: ?HWND, id: INT) callconv(CALLBACK) BOOL;

extern "gdi32" fn CreateCompatibleDC(?HDC) callconv(CALLBACK) ?HDC;
extern "gdi32" fn CreateCompatibleBitmap(HDC, INT, INT) callconv(CALLBACK) ?HBITMAP;
extern "gdi32" fn SelectObject(HDC, *GdiHandle) callconv(CALLBACK) ?HGDIOBJ;
extern "gdi32" fn DeleteObject(*GdiHandle) callconv(CALLBACK) BOOL;
extern "gdi32" fn DeleteDC(HDC) callconv(CALLBACK) BOOL;
extern "gdi32" fn BitBlt(HDC, INT, INT, INT, INT, HDC, INT, INT, DWORD) callconv(CALLBACK) BOOL;
extern "gdi32" fn CreateSolidBrush(COLORREF) callconv(CALLBACK) ?HBRUSH;
extern "gdi32" fn CreatePen(INT, INT, COLORREF) callconv(CALLBACK) ?HPEN;
extern "gdi32" fn CreateFontIndirectA(*const LOGFONTA) callconv(CALLBACK) ?HFONT;
extern "gdi32" fn SetBkMode(HDC, INT) callconv(CALLBACK) INT;
extern "gdi32" fn SetTextColor(HDC, COLORREF) callconv(CALLBACK) COLORREF;
extern "gdi32" fn Rectangle(HDC, INT, INT, INT, INT) callconv(CALLBACK) BOOL;
extern "gdi32" fn RoundRect(HDC, INT, INT, INT, INT, INT, INT) callconv(CALLBACK) BOOL;
extern "gdi32" fn Ellipse(HDC, INT, INT, INT, INT) callconv(CALLBACK) BOOL;
extern "gdi32" fn MoveToEx(HDC, INT, INT, ?*POINT) callconv(CALLBACK) BOOL;
extern "gdi32" fn LineTo(HDC, INT, INT) callconv(CALLBACK) BOOL;
extern "gdi32" fn GetStockObject(INT) callconv(CALLBACK) ?HGDIOBJ;
extern "gdi32" fn CreateDIBSection(HDC, *const BITMAPINFO, UINT, *?*anyopaque, ?windows.HANDLE, DWORD) callconv(CALLBACK) ?HBITMAP;
extern "gdi32" fn SetPixel(HDC, INT, INT, COLORREF) callconv(CALLBACK) COLORREF;
extern "gdi32" fn CreateRoundRectRgn(INT, INT, INT, INT, INT, INT) callconv(CALLBACK) ?HRGN;

extern "msimg32" fn AlphaBlend(HDC, INT, INT, INT, INT, HDC, INT, INT, INT, INT, BLENDFUNCTION) callconv(CALLBACK) BOOL;

extern "dwmapi" fn DwmExtendFrameIntoClientArea(HWND, *const MARGINS) callconv(CALLBACK) windows.HRESULT;
extern "dwmapi" fn DwmSetWindowAttribute(HWND, DWORD, *const anyopaque, DWORD) callconv(CALLBACK) windows.HRESULT;

extern "user32" fn SetWindowRgn(HWND, ?HRGN, BOOL) callconv(CALLBACK) INT;

// ============================================================================
// Helper Functions
// ============================================================================
inline fn RGB(r: u8, g: u8, b: u8) COLORREF {
    return @as(COLORREF, r) | (@as(COLORREF, g) << 8) | (@as(COLORREF, b) << 16);
}

inline fn GET_X_LPARAM(lp: LPARAM) INT {
    return @as(i16, @truncate(@as(isize, @bitCast(lp))));
}

inline fn GET_Y_LPARAM(lp: LPARAM) INT {
    return @as(i16, @truncate(@as(isize, @bitCast(lp)) >> 16));
}

fn castGdiObj(obj: anytype) *GdiHandle {
    return @ptrCast(obj);
}

fn isCtrlDown() bool {
    return (GetKeyState(0x11) & @as(i16, @bitCast(@as(u16, 0x8000)))) != 0;
}

// ============================================================================
// Color Palette - Modern Dark Theme
// ============================================================================
const Theme = struct {
    const bg_primary = RGB(22, 22, 30);
    const bg_secondary = RGB(30, 30, 42);
    const bg_card = RGB(38, 38, 52);
    const bg_card_hover = RGB(48, 48, 65);
    const accent_blue = RGB(99, 141, 255);
    const accent_purple = RGB(162, 120, 255);
    const accent_cyan = RGB(80, 220, 235);
    const accent_green = RGB(80, 230, 150);
    const accent_orange = RGB(255, 165, 80);
    const accent_pink = RGB(255, 100, 170);
    const text_primary = RGB(235, 235, 245);
    const text_secondary = RGB(160, 160, 185);
    const text_muted = RGB(100, 100, 130);
    const border_subtle = RGB(55, 55, 75);
    const border_accent = RGB(99, 141, 255);
    const dot_active = RGB(80, 230, 150);
};

// ============================================================================
// Window Configuration
// ============================================================================
const WIN_WIDTH = 380;
const WIN_HEIGHT = 520;
const COMPACT_WIDTH = 320;
const COMPACT_HEIGHT = 80;
const CORNER_RADIUS = 20;
const COMPACT_CORNER_RADIUS = 14;
const CARD_RADIUS = 12;
const PADDING = 20;
const CARD_PADDING = 16;

// ============================================================================
// Global State
// ============================================================================
var g_mouse_x: LONG = 0;
var g_mouse_y: LONG = 0;
var g_screen_w: LONG = 0;
var g_screen_h: LONG = 0;
var g_physical_w: DWORD = 0;
var g_physical_h: DWORD = 0;
var g_is_dragging: bool = false;
var g_drag_offset: POINT = .{};
var g_hover_close: bool = false;
var g_tick: u32 = 0;

var g_history_x: [60]LONG = [_]LONG{0} ** 60;
var g_history_y: [60]LONG = [_]LONG{0} ** 60;
var g_history_idx: usize = 0;

var g_coords_locked: bool = false;
var g_locked_x: LONG = 0;
var g_locked_y: LONG = 0;

var g_main_hwnd: ?HWND = null;

var g_follow_window: bool = false;

// ============================================================================
// New Feature State
// ============================================================================
var g_is_compact_mode: bool = false;
var g_last_copy_time: u32 = 30;
var g_copy_success: bool = false;
var g_tray_enabled: bool = true;

// ============================================================================
// Window Visibility Toggle
// ============================================================================
fn toggleWindowVisibility(hwnd: HWND) void {
    if (IsWindowVisible(hwnd) != 0) {
        _ = ShowWindow(hwnd, SW_HIDE);
        platform.minimizeToTray(hwnd);
    } else {
        _ = ShowWindow(hwnd, SW_RESTORE);
        _ = ShowWindow(hwnd, SW_SHOW);
        platform.restoreFromTray(hwnd);
    }
}

// ============================================================================
// Feature Functions
// ============================================================================
fn copyCurrentCoordinatesToClipboard() void {
    var buf: [64]u8 = undefined;
    const x_val = if (g_coords_locked) g_locked_x else g_mouse_x;
    const y_val = if (g_coords_locked) g_locked_y else g_mouse_y;
    var idx: usize = 0;
    const x_str = formatInt(buf[idx..], x_val);
    idx += x_str.len;
    buf[idx] = ',';
    idx += 1;
    buf[idx] = ' ';
    idx += 1;
    const y_str = formatInt(buf[idx..], y_val);
    idx += y_str.len;
    const text = buf[0..idx];
    const success = platform.copyToClipboard(text);
    g_copy_success = success;
    g_last_copy_time = 0;
}

fn toggleCompactMode() void {
    g_is_compact_mode = !g_is_compact_mode;
    if (g_main_hwnd) |hwnd| {
        if (g_is_compact_mode) {
            const rgn = CreateRoundRectRgn(0, 0, COMPACT_WIDTH, COMPACT_HEIGHT, COMPACT_CORNER_RADIUS, COMPACT_CORNER_RADIUS);
            if (rgn) |r| {
                _ = SetWindowRgn(hwnd, r, 1);
            }
            _ = SetWindowPos(hwnd, null, 0, 0, COMPACT_WIDTH, COMPACT_HEIGHT, SWP_NOMOVE | SWP_NOZORDER);
        } else {
            const rgn = CreateRoundRectRgn(0, 0, WIN_WIDTH, WIN_HEIGHT, CORNER_RADIUS, CORNER_RADIUS);
            if (rgn) |r| {
                _ = SetWindowRgn(hwnd, r, 1);
            }
            _ = SetWindowPos(hwnd, null, 0, 0, WIN_WIDTH, WIN_HEIGHT, SWP_NOMOVE | SWP_NOZORDER);
        }
    }
}

// ============================================================================
// Drawing Helpers
// ============================================================================
fn fillRoundedRect(hdc: HDC, x: INT, y: INT, w: INT, h: INT, radius: INT, color: COLORREF) void {
    const brush = CreateSolidBrush(color) orelse return;
    const pen = CreatePen(PS_NULL, 0, 0) orelse {
        _ = DeleteObject(castGdiObj(brush));
        return;
    };
    const old_brush = SelectObject(hdc, castGdiObj(brush));
    const old_pen = SelectObject(hdc, castGdiObj(pen));
    _ = RoundRect(hdc, x, y, x + w, y + h, radius, radius);
    if (old_pen) |p| _ = SelectObject(hdc, p);
    if (old_brush) |b| _ = SelectObject(hdc, b);
    _ = DeleteObject(castGdiObj(pen));
    _ = DeleteObject(castGdiObj(brush));
}

fn fillRect(hdc: HDC, x: INT, y: INT, w: INT, h: INT, color: COLORREF) void {
    const brush = CreateSolidBrush(color) orelse return;
    const r = RECT{ .left = x, .top = y, .right = x + w, .bottom = y + h };
    _ = FillRect(hdc, &r, brush);
    _ = DeleteObject(castGdiObj(brush));
}

fn drawRoundedBorder(hdc: HDC, x: INT, y: INT, w: INT, h: INT, radius: INT, color: COLORREF) void {
    const pen = CreatePen(PS_SOLID, 1, color) orelse return;
    const null_brush = GetStockObject(NULL_BRUSH) orelse {
        _ = DeleteObject(castGdiObj(pen));
        return;
    };
    const old_pen = SelectObject(hdc, castGdiObj(pen));
    const old_brush = SelectObject(hdc, null_brush);
    _ = RoundRect(hdc, x, y, x + w, y + h, radius, radius);
    if (old_brush) |b| _ = SelectObject(hdc, b);
    if (old_pen) |p| _ = SelectObject(hdc, p);
    _ = DeleteObject(castGdiObj(pen));
}

fn drawCircle(hdc: HDC, cx: INT, cy: INT, radius: INT, color: COLORREF) void {
    const brush = CreateSolidBrush(color) orelse return;
    const pen = CreatePen(PS_NULL, 0, 0) orelse {
        _ = DeleteObject(castGdiObj(brush));
        return;
    };
    const old_brush = SelectObject(hdc, castGdiObj(brush));
    const old_pen = SelectObject(hdc, castGdiObj(pen));
    _ = Ellipse(hdc, cx - radius, cy - radius, cx + radius, cy + radius);
    if (old_pen) |p| _ = SelectObject(hdc, p);
    if (old_brush) |b| _ = SelectObject(hdc, b);
    _ = DeleteObject(castGdiObj(pen));
    _ = DeleteObject(castGdiObj(brush));
}

fn createFont(size: LONG, weight: LONG, face: []const u8) ?HFONT {
    var lf = LOGFONTA{};
    lf.lfHeight = -size;
    lf.lfWeight = weight;
    lf.lfQuality = CLEARTYPE_QUALITY;
    const copy_len = @min(face.len, 31);
    @memcpy(lf.lfFaceName[0..copy_len], face[0..copy_len]);
    return CreateFontIndirectA(&lf);
}

fn drawText(hdc: HDC, text: []const u8, x: INT, y: INT, w: INT, h: INT, color: COLORREF, font: HFONT, flags: UINT) void {
    _ = SetTextColor(hdc, color);
    _ = SetBkMode(hdc, TRANSPARENT);
    const old_font = SelectObject(hdc, castGdiObj(font));
    var rect = RECT{ .left = x, .top = y, .right = x + w, .bottom = y + h };
    const CP_UTF8 = 65001;
    var wide_buf: [512:0]u16 = undefined;
    const wide_len = MultiByteToWideChar(CP_UTF8, 0, text.ptr, @intCast(text.len), @ptrCast(&wide_buf[0]), 511);
    if (wide_len > 0) {
        wide_buf[@intCast(wide_len)] = 0;
        const wide_ptr: [*:0]u16 = @ptrCast(&wide_buf[0]);
        _ = DrawTextW(hdc, wide_ptr, wide_len, &rect, flags | DT_NOPREFIX);
    }
    if (old_font) |f| _ = SelectObject(hdc, f);
}

fn drawLine(hdc: HDC, x1: INT, y1: INT, x2: INT, y2: INT, color: COLORREF, width: INT) void {
    const pen = CreatePen(PS_SOLID, width, color) orelse return;
    const old_pen = SelectObject(hdc, castGdiObj(pen));
    _ = MoveToEx(hdc, x1, y1, null);
    _ = LineTo(hdc, x2, y2);
    if (old_pen) |p| _ = SelectObject(hdc, p);
    _ = DeleteObject(castGdiObj(pen));
}

// ============================================================================
// Format Helpers
// ============================================================================
fn formatInt(buf: []u8, value: LONG) []u8 {
    var v = value;
    var negative = false;
    if (v < 0) {
        negative = true;
        v = -v;
    }
    var tmp: [20]u8 = undefined;
    var len: usize = 0;
    if (v == 0) {
        tmp[0] = '0';
        len = 1;
    } else {
        while (v > 0) : (len += 1) {
            tmp[len] = @intCast(@as(u32, @intCast(@mod(v, 10))) + '0');
            v = @divTrunc(v, 10);
        }
    }
    var idx: usize = 0;
    if (negative) {
        buf[0] = '-';
        idx = 1;
    }
    var i: usize = 0;
    while (i < len) : (i += 1) {
        buf[idx + i] = tmp[len - 1 - i];
    }
    return buf[0 .. idx + len];
}

fn formatCoord(buf: []u8, label: []const u8, value: LONG) []u8 {
    var idx: usize = 0;
    @memcpy(buf[idx .. idx + label.len], label);
    idx += label.len;
    const num = formatInt(buf[idx..], value);
    idx += num.len;
    return buf[0..idx];
}

fn formatPercent(buf: []u8, value: LONG, max_val: LONG) []u8 {
    if (max_val == 0) return formatInt(buf, 0);
    const pct = @divTrunc(value * 100, max_val);
    var idx: usize = 0;
    const num = formatInt(buf[idx..], pct);
    idx += num.len;
    buf[idx] = '%';
    idx += 1;
    return buf[0..idx];
}

fn formatResolution(buf: []u8, w: DWORD, h: DWORD) []u8 {
    var idx: usize = 0;
    const ws = formatInt(buf[idx..], @intCast(w));
    idx += ws.len;
    buf[idx] = ' ';
    idx += 1;
    buf[idx] = 'x';
    idx += 1;
    buf[idx] = ' ';
    idx += 1;
    const hs = formatInt(buf[idx..], @intCast(h));
    idx += hs.len;
    return buf[0..idx];
}

// ============================================================================
// Main Rendering (Full Mode)
// ============================================================================
fn renderUI(hdc: HDC, width: INT, height: INT) void {
    if (g_is_compact_mode) {
        renderUICompact(hdc, width, height);
        return;
    }

    // Background
    fillRoundedRect(hdc, 0, 0, width, height, CORNER_RADIUS, Theme.bg_primary);
    drawRoundedBorder(hdc, 0, 0, width, height, CORNER_RADIUS, Theme.border_subtle);

    const font_title = createFont(18, FW_BOLD, "Segoe UI") orelse return;
    const font_large = createFont(32, FW_BOLD, "Cascadia Code") orelse return;
    const font_medium = createFont(14, FW_SEMIBOLD, "Segoe UI") orelse return;
    const font_small = createFont(12, FW_NORMAL, "Segoe UI") orelse return;
    const font_mono = createFont(13, FW_NORMAL, "Cascadia Code") orelse return;
    const font_icon = createFont(16, FW_NORMAL, "Segoe UI") orelse return;
    defer {
        _ = DeleteObject(castGdiObj(font_title));
        _ = DeleteObject(castGdiObj(font_large));
        _ = DeleteObject(castGdiObj(font_medium));
        _ = DeleteObject(castGdiObj(font_small));
        _ = DeleteObject(castGdiObj(font_mono));
        _ = DeleteObject(castGdiObj(font_icon));
    }

    var y_offset: INT = PADDING;

    // Title Bar
    {
        drawCircle(hdc, PADDING + 6, y_offset + 10, 5, Theme.dot_active);
        drawText(hdc, "Mouse Tracker", PADDING + 20, y_offset, 200, 22, Theme.text_primary, font_title, DT_LEFT | DT_VCENTER | DT_SINGLELINE);

        const close_color = if (g_hover_close) Theme.accent_pink else Theme.text_muted;
        if (g_hover_close) {
            fillRoundedRect(hdc, width - PADDING - 28, y_offset - 2, 28, 24, 6, RGB(60, 30, 40));
        }
        drawText(hdc, "\xc3\x97", width - PADDING - 24, y_offset, 20, 20, close_color, font_icon, DT_CENTER | DT_VCENTER | DT_SINGLELINE);
        y_offset += 36;
    }

    // Separator
    {
        drawLine(hdc, PADDING, y_offset, width - PADDING, y_offset, Theme.border_subtle, 1);
        y_offset += 12;
    }

    // Main Coordinate Display
    {
        fillRoundedRect(hdc, PADDING, y_offset, width - PADDING * 2, 100, CARD_RADIUS, Theme.bg_secondary);
        drawRoundedBorder(hdc, PADDING, y_offset, width - PADDING * 2, 100, CARD_RADIUS, Theme.border_subtle);

        const card_x = PADDING + CARD_PADDING;
        drawText(hdc, "CURSOR POSITION", card_x, y_offset + 5, 200, 16, Theme.text_muted, font_small, DT_LEFT | DT_SINGLELINE);

        // X coordinate
        {
            var buf: [32]u8 = undefined;
            const x_val = if (g_coords_locked) g_locked_x else g_mouse_x;
            const text = formatCoord(&buf, "X ", x_val);
            drawText(hdc, text, card_x, y_offset + 32, 160, 36, Theme.accent_cyan, font_large, DT_LEFT | DT_SINGLELINE);
        }

        // Y coordinate
        {
            var buf: [32]u8 = undefined;
            const y_val = if (g_coords_locked) g_locked_y else g_mouse_y;
            const text = formatCoord(&buf, "Y ", y_val);
            drawText(hdc, text, card_x + 160, y_offset + 32, 160, 36, Theme.accent_purple, font_large, DT_LEFT | DT_SINGLELINE);
        }

        // Percentage
        {
            var buf_x: [16]u8 = undefined;
            var buf_y: [16]u8 = undefined;
            const x_val = if (g_coords_locked) g_locked_x else g_mouse_x;
            const y_val = if (g_coords_locked) g_locked_y else g_mouse_y;
            const pct_x = formatPercent(&buf_x, x_val, g_screen_w);
            const pct_y = formatPercent(&buf_y, y_val, g_screen_h);
            var combined: [40]u8 = undefined;
            var ci: usize = 0;
            @memcpy(combined[ci .. ci + pct_x.len], pct_x);
            ci += pct_x.len;
            @memcpy(combined[ci .. ci + 4], " ,  ");
            ci += 4;
            @memcpy(combined[ci .. ci + pct_y.len], pct_y);
            ci += pct_y.len;
            drawText(hdc, combined[0..ci], card_x, y_offset + 74, 300, 16, Theme.text_secondary, font_small, DT_LEFT | DT_SINGLELINE);
        }
        y_offset += 112;
    }

    // Movement Sparkline
    {
        y_offset += 8;
        fillRoundedRect(hdc, PADDING, y_offset, width - PADDING * 2, 120, CARD_RADIUS, Theme.bg_secondary);
        drawRoundedBorder(hdc, PADDING, y_offset, width - PADDING * 2, 120, CARD_RADIUS, Theme.border_subtle);

        const card_x = PADDING + CARD_PADDING;
        const chart_w = width - PADDING * 2 - CARD_PADDING * 2;
        drawText(hdc, "MOVEMENT TRACE", card_x, y_offset + 8, 200, 16, Theme.text_muted, font_small, DT_LEFT | DT_SINGLELINE);

        const chart_y = y_offset + 30;
        const chart_h: INT = 35;

        var min_x: LONG = std.math.maxInt(LONG);
        var max_x: LONG = std.math.minInt(LONG);
        var min_y: LONG = std.math.maxInt(LONG);
        var max_y: LONG = std.math.minInt(LONG);
        for (0..60) |i| {
            if (g_history_x[i] < min_x) min_x = g_history_x[i];
            if (g_history_x[i] > max_x) max_x = g_history_x[i];
            if (g_history_y[i] < min_y) min_y = g_history_y[i];
            if (g_history_y[i] > max_y) max_y = g_history_y[i];
        }
        const range_x = @max(max_x - min_x, 1);
        const range_y = @max(max_y - min_y, 1);

        // X sparkline
        {
            var prev_px: INT = 0;
            var prev_py: INT = 0;
            for (0..60) |i| {
                const idx = (g_history_idx + i) % 60;
                const px = card_x + @as(INT, @intCast(@divTrunc(@as(INT, @intCast(i)) * chart_w, 59)));
                const val = g_history_x[idx] - min_x;
                const py = chart_y + chart_h - @as(INT, @intCast(@divTrunc(val * chart_h, range_x)));
                if (i > 0) {
                    drawLine(hdc, prev_px, prev_py, px, py, Theme.accent_cyan, 2);
                }
                prev_px = px;
                prev_py = py;
            }
        }

        // Y sparkline
        const chart_y2 = chart_y + chart_h + 14;
        {
            var prev_px: INT = 0;
            var prev_py: INT = 0;
            for (0..60) |i| {
                const idx = (g_history_idx + i) % 60;
                const px = card_x + @as(INT, @intCast(@divTrunc(@as(INT, @intCast(i)) * chart_w, 59)));
                const val = g_history_y[idx] - min_y;
                const py = chart_y2 + chart_h - @as(INT, @intCast(@divTrunc(val * chart_h, range_y)));
                if (i > 0) {
                    drawLine(hdc, prev_px, prev_py, px, py, Theme.accent_purple, 2);
                }
                prev_px = px;
                prev_py = py;
            }
        }

        // Legend
        drawCircle(hdc, card_x + chart_w - 50, y_offset + 12, 3, Theme.accent_cyan);
        drawText(hdc, "X", card_x + chart_w - 44, y_offset + 6, 14, 16, Theme.accent_cyan, font_small, DT_LEFT | DT_SINGLELINE);
        drawCircle(hdc, card_x + chart_w - 25, y_offset + 12, 3, Theme.accent_purple);
        drawText(hdc, "Y", card_x + chart_w - 19, y_offset + 6, 14, 16, Theme.accent_purple, font_small, DT_LEFT | DT_SINGLELINE);

        y_offset += 132;
    }

    // Info Cards Row
    {
        y_offset += 8;
        const card_w_half = @divTrunc(width - PADDING * 2 - 8, 2);

        // Screen Resolution
        {
            fillRoundedRect(hdc, PADDING, y_offset, card_w_half, 80, CARD_RADIUS, Theme.bg_secondary);
            drawRoundedBorder(hdc, PADDING, y_offset, card_w_half, 80, CARD_RADIUS, Theme.border_subtle);
            drawText(hdc, "DISPLAY", PADDING + CARD_PADDING, y_offset + 10, 120, 14, Theme.text_muted, font_small, DT_LEFT | DT_SINGLELINE);
            {
                var buf: [32]u8 = undefined;
                const text = formatResolution(&buf, @intCast(g_screen_w), @intCast(g_screen_h));
                drawText(hdc, text, PADDING + CARD_PADDING, y_offset + 30, card_w_half - CARD_PADDING * 2, 20, Theme.accent_blue, font_mono, DT_LEFT | DT_SINGLELINE);
            }
            drawText(hdc, "Logical", PADDING + CARD_PADDING, y_offset + 54, 80, 14, Theme.text_muted, font_small, DT_LEFT | DT_SINGLELINE);
        }

        // Physical Resolution
        {
            const x2 = PADDING + card_w_half + 8;
            fillRoundedRect(hdc, x2, y_offset, card_w_half, 80, CARD_RADIUS, Theme.bg_secondary);
            drawRoundedBorder(hdc, x2, y_offset, card_w_half, 80, CARD_RADIUS, Theme.border_subtle);
            drawText(hdc, "PHYSICAL", x2 + CARD_PADDING, y_offset + 10, 120, 14, Theme.text_muted, font_small, DT_LEFT | DT_SINGLELINE);
            {
                var buf: [32]u8 = undefined;
                const text = formatResolution(&buf, g_physical_w, g_physical_h);
                drawText(hdc, text, x2 + CARD_PADDING, y_offset + 30, card_w_half - CARD_PADDING * 2, 20, Theme.accent_orange, font_mono, DT_LEFT | DT_SINGLELINE);
            }
            drawText(hdc, "Native", x2 + CARD_PADDING, y_offset + 54, 80, 14, Theme.text_muted, font_small, DT_LEFT | DT_SINGLELINE);
        }
        y_offset += 96;
    }

    // Coordinate Bar
    {
        y_offset += 4;
        fillRoundedRect(hdc, PADDING, y_offset, width - PADDING * 2, 76, CARD_RADIUS, Theme.bg_secondary);
        drawRoundedBorder(hdc, PADDING, y_offset, width - PADDING * 2, 76, CARD_RADIUS, Theme.border_subtle);

        const card_x = PADDING + CARD_PADDING;
        const bar_w = width - PADDING * 2 - CARD_PADDING * 2;

        // X progress bar
        {
            drawText(hdc, "X", card_x, y_offset + 10, 20, 14, Theme.accent_cyan, font_small, DT_LEFT | DT_SINGLELINE);
            const bar_x = card_x + 22;
            const bar_inner_w = bar_w - 22;
            fillRoundedRect(hdc, bar_x, y_offset + 12, bar_inner_w, 10, 5, Theme.bg_primary);
            const fill_w: INT = if (g_screen_w > 0) @intCast(@divTrunc(@as(i64, g_mouse_x) * bar_inner_w, g_screen_w)) else 0;
            if (fill_w > 0) {
                fillRoundedRect(hdc, bar_x, y_offset + 12, @min(fill_w, bar_inner_w), 10, 5, Theme.accent_cyan);
            }
        }

        // Y progress bar
        {
            drawText(hdc, "Y", card_x, y_offset + 44, 20, 14, Theme.accent_purple, font_small, DT_LEFT | DT_SINGLELINE);
            const bar_x = card_x + 22;
            const bar_inner_w = bar_w - 22;
            fillRoundedRect(hdc, bar_x, y_offset + 46, bar_inner_w, 10, 5, Theme.bg_primary);
            const fill_w: INT = if (g_screen_h > 0) @intCast(@divTrunc(@as(i64, g_mouse_y) * bar_inner_w, g_screen_h)) else 0;
            if (fill_w > 0) {
                fillRoundedRect(hdc, bar_x, y_offset + 46, @min(fill_w, bar_inner_w), 10, 5, Theme.accent_purple);
            }
        }
        y_offset += 70;
    }

    // Bottom Status
    {
        y_offset += 4;
        const dot_color = if (g_coords_locked) RGB(255, 100, 100) else if (g_tick % 40 < 20) Theme.dot_active else RGB(60, 180, 120);
        drawCircle(hdc, PADDING + 8, y_offset + 8, 3, dot_color);

        const status_text = if (g_coords_locked) "已锁定 (Space解锁)" else "Tracking active";
        drawText(hdc, status_text, PADDING + 18, y_offset, 250, 16, Theme.text_muted, font_small, DT_LEFT | DT_VCENTER | DT_SINGLELINE);

        // Copy indicator
        if (g_last_copy_time < 30) {
            const indicator_color = if (g_copy_success) Theme.accent_green else Theme.accent_orange;
            const copy_text = if (g_copy_success) "已复制!" else "复制失败";
            drawText(hdc, copy_text, width - PADDING - 80, y_offset, 80, 16, indicator_color, font_small, DT_RIGHT | DT_VCENTER | DT_SINGLELINE);
        } else {
            const follow_text = if (g_follow_window) "跟随" else "固定";
            drawText(hdc, follow_text, width - PADDING - 40, y_offset, 40, 16, Theme.text_muted, font_small, DT_RIGHT | DT_VCENTER | DT_SINGLELINE);
        }
    }
}

// ============================================================================
// Compact Mode Rendering
// ============================================================================
fn renderUICompact(hdc: HDC, width: INT, height: INT) void {
    fillRoundedRect(hdc, 0, 0, width, height, COMPACT_CORNER_RADIUS, Theme.bg_primary);
    drawRoundedBorder(hdc, 0, 0, width, height, COMPACT_CORNER_RADIUS, Theme.border_subtle);

    const font_large = createFont(32, FW_BOLD, "Cascadia Code") orelse return;
    const font_small = createFont(11, FW_NORMAL, "Segoe UI") orelse return;
    const font_icon = createFont(14, FW_NORMAL, "Segoe UI") orelse return;
    defer {
        _ = DeleteObject(castGdiObj(font_large));
        _ = DeleteObject(castGdiObj(font_small));
        _ = DeleteObject(castGdiObj(font_icon));
    }

    const margin: INT = PADDING;

    // Close button (top right)
    {
        const close_color = if (g_hover_close) Theme.accent_pink else Theme.text_muted;
        if (g_hover_close) {
            fillRoundedRect(hdc, width - margin - 22, 4, 22, 20, 4, RGB(60, 30, 40));
        }
        drawText(hdc, "\xc3\x97", width - margin - 20, 4, 16, 16, close_color, font_icon, DT_CENTER | DT_VCENTER | DT_SINGLELINE);
    }

    // Lock indicator dot
    {
        const dot_color = if (g_coords_locked) RGB(255, 100, 100) else Theme.dot_active;
        drawCircle(hdc, margin + 4, 14, 3, dot_color);
    }

    // Coordinates - same layout as full mode (X left, Y right)
    const x_val = if (g_coords_locked) g_locked_x else g_mouse_x;
    const y_val = if (g_coords_locked) g_locked_y else g_mouse_y;
    const card_x = margin + CARD_PADDING;

    {
        var buf: [32]u8 = undefined;
        const text = formatCoord(&buf, "X  ", x_val);
        drawText(hdc, text, card_x, 28, 160, 36, Theme.accent_cyan, font_large, DT_LEFT | DT_SINGLELINE);
    }
    {
        var buf: [32]u8 = undefined;
        const text = formatCoord(&buf, "Y  ", y_val);
        drawText(hdc, text, card_x + 160, 28, 160, 36, Theme.accent_purple, font_large, DT_LEFT | DT_SINGLELINE);
    }

    // Copy indicator at bottom right
    if (g_last_copy_time < 30) {
        const indicator_color = if (g_copy_success) Theme.accent_green else Theme.accent_orange;
        const status_text = if (g_copy_success) "已复制!" else "复制失败";
        drawText(hdc, status_text, width - margin - 60, height - 18, 60, 14, indicator_color, font_small, DT_RIGHT | DT_SINGLELINE);
    }
}

// ============================================================================
// Window Procedure
// ============================================================================
fn windowProc(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM) callconv(CALLBACK) LRESULT {
    switch (uMsg) {
        WM_CREATE => {
            g_main_hwnd = hwnd;
            const rgn = CreateRoundRectRgn(0, 0, WIN_WIDTH, WIN_HEIGHT, CORNER_RADIUS, CORNER_RADIUS);
            if (rgn) |r| {
                _ = SetWindowRgn(hwnd, r, 1);
            }
            g_screen_w = GetSystemMetrics(SM_CXSCREEN);
            g_screen_h = GetSystemMetrics(SM_CYSCREEN);
            var devMode: DEVMODEA = .{};
            devMode.dmSize = @sizeOf(DEVMODEA);
            if (EnumDisplaySettingsA(null, ENUM_CURRENT_SETTINGS, &devMode) != 0) {
                g_physical_w = devMode.dmPelsWidth;
                g_physical_h = devMode.dmPelsHeight;
            }

            platform.initPlatform();

            if (builtin.os.tag == .windows) {
                const raw_icon = platform.loadAppIcon();
                _ = platform.createTrayIcon(hwnd, raw_icon, "Mouse Tracker");
            }

            // Register global hotkey: Ctrl+H for toggle visibility
            _ = RegisterHotKey(hwnd, HOTKEY_ID_TOGGLE_VISIBLE, MOD_CONTROL | MOD_NOREPEAT, 'H');

            _ = SetTimer(hwnd, 1, 50, null);
            return 0;
        },
        WM_TIMER => {
            var pt: POINT = .{};
            _ = GetCursorPos(&pt);
            if (!g_coords_locked) {
                g_mouse_x = pt.x;
                g_mouse_y = pt.y;
                g_locked_x = g_mouse_x;
                g_locked_y = g_mouse_y;
                g_history_x[g_history_idx] = g_mouse_x;
                g_history_y[g_history_idx] = g_mouse_y;
                g_history_idx = (g_history_idx + 1) % 60;
            }
            g_tick +%= 1;
            if (g_last_copy_time < 30) {
                g_last_copy_time += 1;
            }

            // Follow mouse
            if (g_follow_window) {
                const cur_w: INT = if (g_is_compact_mode) COMPACT_WIDTH else WIN_WIDTH;
                const cur_h: INT = if (g_is_compact_mode) COMPACT_HEIGHT else WIN_HEIGHT;
                const offset_x: INT = 20;
                const offset_y: INT = 20;
                var new_x: INT = pt.x + offset_x;
                var new_y: INT = pt.y + offset_y;
                if (new_x + cur_w > g_screen_w) {
                    new_x = pt.x - cur_w - offset_x;
                }
                if (new_y + cur_h > g_screen_h) {
                    new_y = pt.y - cur_h - offset_y;
                }
                if (new_x < 0) new_x = 0;
                if (new_y < 0) new_y = 0;
                _ = SetWindowPos(hwnd, null, new_x, new_y, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
            }

            _ = InvalidateRect(hwnd, null, 0);
            return 0;
        },
        WM_ERASEBKGND => {
            return 1;
        },
        WM_PAINT => {
            var ps: PAINTSTRUCT = .{};
            const paint_hdc = BeginPaint(hwnd, &ps) orelse return 0;
            var rc: RECT = .{};
            _ = GetClientRect(hwnd, &rc);
            const w = rc.right - rc.left;
            const h = rc.bottom - rc.top;

            const mem_dc = CreateCompatibleDC(paint_hdc) orelse {
                _ = EndPaint(hwnd, &ps);
                return 0;
            };
            const mem_bmp = CreateCompatibleBitmap(paint_hdc, w, h) orelse {
                _ = DeleteDC(mem_dc);
                _ = EndPaint(hwnd, &ps);
                return 0;
            };
            const old_bmp = SelectObject(mem_dc, castGdiObj(mem_bmp));

            renderUI(mem_dc, w, h);

            _ = BitBlt(paint_hdc, 0, 0, w, h, mem_dc, 0, 0, SRCCOPY);
            if (old_bmp) |b| _ = SelectObject(mem_dc, b);
            _ = DeleteObject(castGdiObj(mem_bmp));
            _ = DeleteDC(mem_dc);
            _ = EndPaint(hwnd, &ps);
            return 0;
        },
        WM_NCHITTEST => {
            var pt: POINT = .{};
            pt.x = GET_X_LPARAM(lParam);
            pt.y = GET_Y_LPARAM(lParam);
            _ = ScreenToClient(hwnd, &pt);

            var rc: RECT = .{};
            _ = GetClientRect(hwnd, &rc);
            const client_w = rc.right - rc.left;

            if (g_follow_window) {
                return HTCLIENT;
            }

            if (g_is_compact_mode) {
                if (pt.y < 26 and pt.x < client_w - PADDING - 24) {
                    return HTCAPTION;
                }
            } else {
                if (pt.y < 48 and pt.x < client_w - PADDING - 30) {
                    return HTCAPTION;
                }
            }
            return HTCLIENT;
        },
        WM_LBUTTONDOWN => {
            var pt: POINT = .{};
            pt.x = GET_X_LPARAM(lParam);
            pt.y = GET_Y_LPARAM(lParam);

            var rc_click: RECT = .{};
            _ = GetClientRect(hwnd, &rc_click);
            const client_w = rc_click.right - rc_click.left;

            if (g_is_compact_mode) {
                if (pt.x >= client_w - PADDING - 24 and pt.x <= client_w - PADDING and pt.y >= 2 and pt.y <= 24) {
                    if (g_tray_enabled) {
                        _ = ShowWindow(hwnd, SW_HIDE);
                        platform.minimizeToTray(hwnd);
                    } else {
                        _ = DestroyWindow(hwnd);
                    }
                }
            } else {
                if (pt.x >= client_w - PADDING - 30 and pt.x <= client_w - PADDING and pt.y >= PADDING - 4 and pt.y <= PADDING + 24) {
                    if (g_tray_enabled) {
                        _ = ShowWindow(hwnd, SW_HIDE);
                        platform.minimizeToTray(hwnd);
                    } else {
                        _ = DestroyWindow(hwnd);
                    }
                }
            }
            return 0;
        },
        WM_MOUSEMOVE => {
            var pt: POINT = .{};
            pt.x = GET_X_LPARAM(lParam);
            pt.y = GET_Y_LPARAM(lParam);

            var rc_move: RECT = .{};
            _ = GetClientRect(hwnd, &rc_move);
            const client_w = rc_move.right - rc_move.left;

            const in_close = if (g_is_compact_mode)
                (pt.x >= client_w - PADDING - 24 and pt.x <= client_w - PADDING and pt.y >= 2 and pt.y <= 24)
            else
                (pt.x >= client_w - PADDING - 30 and pt.x <= client_w - PADDING and pt.y >= PADDING - 4 and pt.y <= PADDING + 24);

            if (in_close != g_hover_close) {
                g_hover_close = in_close;
                _ = InvalidateRect(hwnd, null, 0);
            }
            return 0;
        },
        WM_HOTKEY => {
            const hotkey_id: INT = @intCast(wParam);
            if (hotkey_id == HOTKEY_ID_TOGGLE_VISIBLE) {
                toggleWindowVisibility(hwnd);
            }
            return 0;
        },
        WM_KEYDOWN => {
            if (wParam == VK_SPACE) {
                g_coords_locked = !g_coords_locked;
                if (g_coords_locked) {
                    copyCurrentCoordinatesToClipboard();
                }
                _ = InvalidateRect(hwnd, null, 0);
                return 0;
            }
            // C: copy coordinates
            if (wParam == 'C') {
                copyCurrentCoordinatesToClipboard();
                _ = InvalidateRect(hwnd, null, 0);
                return 0;
            }
            // Ctrl+M: toggle compact mode
            if (wParam == 'M' and isCtrlDown()) {
                toggleCompactMode();
                _ = InvalidateRect(hwnd, null, 0);
                return 0;
            }
            // F: toggle follow mode
            if (wParam == 'F') {
                g_follow_window = !g_follow_window;
                _ = InvalidateRect(hwnd, null, 0);
                return 0;
            }
        },
        WM_COMMAND => {
            const cmd_id: UINT = @intCast(wParam & LOWORD_MASK);
            switch (cmd_id) {
                platform.TRAY_CMD_RESTORE => {
                    toggleWindowVisibility(hwnd);
                },
                platform.TRAY_CMD_ABOUT => {
                    platform.openAboutUrl(hwnd);
                },
                platform.TRAY_CMD_TOGGLE_LOCK => {
                    g_coords_locked = !g_coords_locked;
                    if (g_coords_locked) {
                        copyCurrentCoordinatesToClipboard();
                    }
                    _ = InvalidateRect(hwnd, null, 0);
                },
                platform.TRAY_CMD_TOGGLE_FOLLOW => {
                    g_follow_window = !g_follow_window;
                    _ = InvalidateRect(hwnd, null, 0);
                },
                platform.TRAY_CMD_EXIT => {
                    _ = DestroyWindow(hwnd);
                },
                else => {},
            }
            return 0;
        },
        platform.getTrayMessageId() => {
            if (builtin.os.tag == .windows) {
                const tray_event: UINT = @intCast(@as(usize, @bitCast(lParam)) & 0xFFFF);
                const WM_LBUTTONDBLCLK_VAL: UINT = 0x0203;
                const WM_RBUTTONUP_VAL: UINT = 0x0205;
                if (tray_event == WM_LBUTTONDBLCLK_VAL) {
                    toggleWindowVisibility(hwnd);
                } else if (tray_event == WM_RBUTTONUP_VAL) {
                    platform.showTrayMenu(hwnd);
                }
            }
            return 0;
        },
        WM_CLOSE => {
            if (g_tray_enabled and builtin.os.tag == .windows) {
                _ = ShowWindow(hwnd, SW_HIDE);
                platform.minimizeToTray(hwnd);
                return 0;
            }
            _ = DestroyWindow(hwnd);
            return 0;
        },
        WM_DESTROY => {
            _ = UnregisterHotKey(hwnd, HOTKEY_ID_TOGGLE_VISIBLE);
            _ = platform.removeTrayIcon(hwnd);
            platform.shutdownPlatform();
            _ = KillTimer(hwnd, 1);
            PostQuitMessage(0);
            return 0;
        },
        else => {},
    }
    return DefWindowProcA(hwnd, uMsg, wParam, lParam);
}

// ============================================================================
// Entry Point
// ============================================================================
pub export fn wWinMain(hInstance: HINSTANCE, _: ?HINSTANCE, _: ?[*:0]u16, _: INT) INT {
    return wWinMainImpl(hInstance);
}

fn wWinMainImpl(hInstance: HINSTANCE) INT {
    const class_name = "ModernMouseTracker";

    const raw_icon = if (builtin.os.tag == .windows) platform.loadAppIcon() else null;
    const use_icon: ?HICON = if (raw_icon) |ri| @ptrCast(ri) else LoadIconA(null, IDI_APPLICATION);

    const wc = WNDCLASSEXA{
        .lpfnWndProc = windowProc,
        .hInstance = hInstance,
        .hIcon = use_icon,
        .hCursor = LoadCursorA(null, IDC_ARROW),
        .lpszClassName = class_name,
        .hIconSm = use_icon,
    };

    if (RegisterClassExA(&wc) == 0) {
        return 0;
    }

    const screen_w = GetSystemMetrics(SM_CXSCREEN);
    const screen_h = GetSystemMetrics(SM_CYSCREEN);
    const pos_x = @divTrunc(screen_w - WIN_WIDTH, 2);
    const pos_y = @divTrunc(screen_h - WIN_HEIGHT, 2);

    const hwnd = CreateWindowExA(
        WS_EX_TOPMOST | WS_EX_TOOLWINDOW,
        class_name,
        "Mouse Tracker",
        WS_POPUP | WS_VISIBLE | WS_SYSMENU | WS_MINIMIZEBOX,
        pos_x,
        pos_y,
        WIN_WIDTH,
        WIN_HEIGHT,
        null,
        null,
        hInstance,
        null,
    ) orelse return 0;

    _ = ShowWindow(hwnd, SW_SHOW);
    _ = UpdateWindow(hwnd);

    var msg: MSG = .{};
    while (GetMessageA(&msg, null, 0, 0) != 0) {
        _ = TranslateMessage(&msg);
        _ = DispatchMessageA(&msg);
    }
    return 0;
}

pub fn main() void {
    const hInstance: HINSTANCE = @ptrCast(windows.kernel32.GetModuleHandleW(null) orelse return);
    _ = wWinMainImpl(hInstance);
}