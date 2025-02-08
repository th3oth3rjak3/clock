const std = @import("std");
const zeit = @import("zeit");
const rl = @import("raylib");

const fontData: ?[]const u8 = @embedFile("resources/B612Mono-Bold.ttf");

pub fn main() anyerror!void {
    const screenWidth = 220;
    const screenHeight = 75;
    rl.initWindow(screenWidth, screenHeight, "Clock");
    defer rl.closeWindow();
    rl.setTargetFPS(5);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == std.heap.Check.ok);
    const allocator = gpa.allocator();

    // Pre-allocate fixed buffers for text
    var time_buf: [16:0]u8 = undefined;
    var date_buf: [11:0]u8 = undefined;

    // Get environment map once, outside the loop
    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();

    // Initialize timezone once
    var tz = try zeit.local(allocator, &env);
    defer tz.deinit();

    // Load custom font (replace the path with your own font file)
    const font = try rl.loadFontFromMemory(".ttf", fontData, 20, null);
    defer rl.unloadFont(font);

    while (!rl.windowShouldClose()) {
        const date = try getCurrentTimeString(allocator, &tz, "01-02-2006");
        defer allocator.free(date);
        const time = try getCurrentTimeString(allocator, &tz, "03:04:05 P MST");
        defer allocator.free(time);
        const time_message = try std.fmt.bufPrintZ(&time_buf, "{s}", .{time});
        const date_message = try std.fmt.bufPrintZ(&date_buf, "{s}", .{date});

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.fromHSV(234.0, 0.0, 0.13));

        // Use custom font to draw the text
        rl.drawTextEx(font, time_message, rl.Vector2{ .x = 20, .y = 15 }, 20.0, 2.0, rl.Color.light_gray);
        rl.drawTextEx(font, date_message, rl.Vector2{ .x = 45, .y = 45 }, 20.0, 2.0, rl.Color.light_gray);
    }
}

pub fn getCurrentTimeString(allocator: std.mem.Allocator, tz: *zeit.TimeZone, fmt: []const u8) ![]u8 {
    var buffer = std.ArrayList(u8).init(allocator);
    const writer = buffer.writer();
    const now = try zeit.instant(.{});
    const dt = now.in(tz).time();
    try dt.gofmt(writer, fmt);
    return buffer.toOwnedSlice();
}
