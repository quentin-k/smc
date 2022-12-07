const std = @import("std");
const options = @import("options");

pub fn main() !void {
    const fn_bytes = [_]u8{ 197, 251, 88, 193, 195, 102, 102, 46, 15, 31, 132, 0, 0, 0, 0, 0 };
    const allocator = if (options.valgrind) std.heap.c_allocator else std.heap.page_allocator;
    var slice: []align(std.mem.page_size) u8 = try allocator.alignedAlloc(u8, std.mem.page_size, std.mem.page_size);
    defer dynFree(allocator, slice);
    // defer allocator.free(slice);
    slice[0..fn_bytes.len].* = fn_bytes;
    for (fn_bytes) |b, i| slice[i] = b;
    try setRwx(slice);
    var mem_fn = @ptrCast(*const fn (f64, f64) f64, slice.ptr);
    const n1: f64 = 1.23;
    const n2: f64 = 4.56;
    std.log.info("{d}", .{mem_fn(n1, n2)});
    std.log.info("{*}", .{slice.ptr});

    slice[2] = 92;
    std.log.info("{d}", .{mem_fn(n1, n2)});
    std.log.info("{*}", .{slice.ptr});

    slice[2] = 89;
    std.log.info("{d}", .{mem_fn(n1, n2)});
    std.log.info("{*}", .{slice.ptr});

    slice[2] = 94;
    std.log.info("{d}", .{mem_fn(n1, n2)});
    std.log.info("{*}", .{slice.ptr});
}

fn dynFree(allocator: std.mem.Allocator, slice: []align(std.mem.page_size) u8) void {
    setRw(slice) catch @panic("😱");
    allocator.free(slice);
}

fn setRw(slice: []align(std.mem.page_size) u8) !void {
    try std.os.mprotect(slice, std.os.PROT.WRITE | std.os.PROT.READ);
}

fn setRwx(slice: []align(std.mem.page_size) u8) !void {
    try std.os.mprotect(slice, std.os.PROT.EXEC | std.os.PROT.WRITE | std.os.PROT.READ);
}

// Add -> { 197, 251, 88, 193, 195, 102, 102, 46, 15, 31, 132, 0, 0, 0, 0, 0 }
// Sub -> { 197, 251, 92, 193, 195, 102, 102, 46, 15, 31, 132, 0, 0, 0, 0, 0 }
// Mul -> { 197, 251, 89, 193, 195, 102, 102, 46, 15, 31, 132, 0, 0, 0, 0, 0 }
// Div -> { 197, 251, 94, 193, 195, 102, 102, 46, 15, 31, 132, 0, 0, 0, 0, 0 }
