const TestContext = @import("../../src-self-hosted/test.zig").TestContext;
const std = @import("std");

const ErrorMsg = @import("../../src-self-hosted/Module.zig").ErrorMsg;

const linux_x64 = std.zig.CrossTarget{
    .cpu_arch = .x86_64,
    .os_tag = .linux,
};

pub fn addCases(ctx: *TestContext) !void {
    try ctx.addError("call undefined local", linux_x64, .ZIR,
        \\@noreturn = primitive(noreturn)
        \\
        \\@start_fnty = fntype([], @noreturn, cc=Naked)
        \\@start = fn(@start_fnty, {
        \\  %0 = call(%test, [])
        \\})
 // TODO: address inconsistency in this message and the one in the next test
            , &[_][]const u8{":5:13: error: unrecognized identifier: %test"});

    try ctx.addError("call with non-existent target", linux_x64, .ZIR,
        \\@noreturn = primitive(noreturn)
        \\
        \\@start_fnty = fntype([], @noreturn, cc=Naked)
        \\@start = fn(@start_fnty, {
        \\  %0 = call(@notafunc, [])
        \\})
        \\@0 = str("_start")
        \\@1 = export(@0, "start")
    , &[_][]const u8{":5:13: error: decl 'notafunc' not found"});

    // TODO: this error should occur at the call site, not the fntype decl
    try ctx.addError("call naked function", linux_x64, .ZIR,
        \\@noreturn = primitive(noreturn)
        \\
        \\@start_fnty = fntype([], @noreturn, cc=Naked)
        \\@s = fn(@start_fnty, {})
        \\@start = fn(@start_fnty, {
        \\  %0 = call(@s, [])
        \\})
        \\@0 = str("_start")
        \\@1 = export(@0, "start")
    , &[_][]const u8{":4:9: error: unable to call function with naked calling convention"});

    // TODO: re-enable these tests.
    // https://github.com/ziglang/zig/issues/1364

    //  try ctx.addError("Export same symbol twice", linux_x64, .Zig,
    //      \\export fn entry() void {}
    //      \\export fn entry() void {}
    //  , &[_][]const u8{":2:1: error: exported symbol collision"});

    //    try ctx.addError("Missing function name", linux_x64, .Zig,
    //        \\fn() void {}
    //    , &[_][]const u8{":1:3: error: missing function name"});
    //try ctx.testCompileError(
    //    \\comptime {
    //    \\    return;
    //    \\}
    //, "1.zig", 2, 5, "return expression outside function definition");

    //try ctx.testCompileError(
    //    \\export fn entry() void {
    //    \\    defer return;
    //    \\}
    //, "1.zig", 2, 11, "cannot return from defer expression");

    //try ctx.testCompileError(
    //    \\export fn entry() c_int {
    //    \\    return 36893488147419103232;
    //    \\}
    //, "1.zig", 2, 12, "integer value '36893488147419103232' cannot be stored in type 'c_int'");

    //try ctx.testCompileError(
    //    \\comptime {
    //    \\    var a: *align(4) align(4) i32 = 0;
    //    \\}
    //, "1.zig", 2, 22, "Extra align qualifier");

    //try ctx.testCompileError(
    //    \\comptime {
    //    \\    var b: *const const i32 = 0;
    //    \\}
    //, "1.zig", 2, 19, "Extra align qualifier");

    //try ctx.testCompileError(
    //    \\comptime {
    //    \\    var c: *volatile volatile i32 = 0;
    //    \\}
    //, "1.zig", 2, 22, "Extra align qualifier");

    //try ctx.testCompileError(
    //    \\comptime {
    //    \\    var d: *allowzero allowzero i32 = 0;
    //    \\}
    //, "1.zig", 2, 23, "Extra align qualifier");
}
