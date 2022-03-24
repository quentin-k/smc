const std = @import("std");

pub fn main() !void {
    const fn_bytes = [_]u8{ 197, 251, 88, 193, 195, 102, 102, 46, 15, 31, 132, 0, 0, 0, 0, 0 };
    const allocator = std.heap.page_allocator;
    var slice: []align(std.mem.page_size) u8 = try allocator.alignedAlloc(u8, std.mem.page_size, std.mem.page_size);
    defer dynFree(allocator, slice);
    slice[0..fn_bytes.len].* = fn_bytes;
    for (fn_bytes) |b, i| slice[i] = b;
    try setX(slice);
    var mem_fn = @ptrCast(fn (f64, f64) f64, slice.ptr);
    const n1: f64 = 1.23;
    const n2: f64 = 4.56;
    std.log.info("{d}", .{mem_fn(n1, n2)});
    std.log.info("{*}", .{slice.ptr});

    try setRw(slice);
    slice[2] = 92;
    try setX(slice);
    std.log.info("{d}", .{mem_fn(n1, n2)});
    std.log.info("{*}", .{slice.ptr});

    try setRw(slice);
    slice[2] = 89;
    try setX(slice);
    std.log.info("{d}", .{mem_fn(n1, n2)});
    std.log.info("{*}", .{slice.ptr});

    try setRw(slice);
    slice[2] = 94;
    try setX(slice);
    std.log.info("{d}", .{mem_fn(n1, n2)});
    std.log.info("{*}", .{slice.ptr});
}

fn dynFree(allocator: std.mem.Allocator, slice: []align(std.mem.page_size) u8) void {
    setRw(slice) catch @panic("😬");
    allocator.free(slice);
}

fn setX(slice: []align(std.mem.page_size) u8) !void {
    try std.os.mprotect(slice, std.os.PROT.EXEC);
}

fn setRw(slice: []align(std.mem.page_size) u8) !void {
    try std.os.mprotect(slice, std.os.PROT.WRITE | std.os.PROT.READ);
}

// Add -> { 197, 251, 88, 193, 195, 102, 102, 46, 15, 31, 132, 0, 0, 0, 0, 0 }
// Sub -> { 197, 251, 92, 193, 195, 102, 102, 46, 15, 31, 132, 0, 0, 0, 0, 0 }
// Mul -> { 197, 251, 89, 193, 195, 102, 102, 46, 15, 31, 132, 0, 0, 0, 0, 0 }
// Div -> { 197, 251, 94, 193, 195, 102, 102, 46, 15, 31, 132, 0, 0, 0, 0, 0 }
