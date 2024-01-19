pub const File = union(enum) {
    zig_object: *ZigObject,
    object: *Object,

    pub const Index = enum(u16) {
        null = std.math.maxInt(u16),
        _,
    };

    pub fn path(file: File) []const u8 {
        return switch (file) {
            inline else => |obj| obj.path,
        };
    }

    pub fn segmentInfo(file: File) []const types.Segment {
        return switch (file) {
            .zig_object => |obj| obj.segment_info.items,
            .object => |obj| obj.segment_info,
        };
    }

    pub fn symbol(file: File, index: u32) *Symbol {
        return switch (file) {
            .zig_object => |obj| &obj.symbols.items[index],
            .object => |obj| &obj.symtable[index],
        };
    }

    pub fn symbols(file: File) []const Symbol {
        return switch (file) {
            .zig_object => |obj| obj.symbols.items,
            .object => |obj| obj.symtable,
        };
    }

    pub fn symbolName(file: File, index: u32) []const u8 {
        switch (file) {
            .zig_object => |obj| {
                const sym = obj.symbols.items[index];
                return obj.string_table.get(sym.name).?;
            },
            .object => |obj| {
                const sym = obj.symtable[index];
                return obj.string_table.get(sym.name);
            },
        }
    }

    pub fn parseSymbolIntoAtom(file: File, wasm_file: *Wasm, index: u32) !AtomIndex {
        return switch (file) {
            inline else => |obj| obj.parseSymbolIntoAtom(wasm_file, index),
        };
    }

    /// For a given symbol index, find its corresponding import.
    /// Asserts import exists.
    pub fn import(file: File, symbol_index: u32) types.Import {
        return switch (file) {
            .zig_object => |obj| obj.imports.get(symbol_index).?,
            .object => |obj| obj.findImport(obj.symtable[symbol_index]),
        };
    }

    /// For a given offset, returns its string value.
    /// Asserts string exists in the object string table.
    pub fn string(file: File, offset: u32) []const u8 {
        return switch (file) {
            .zig_object => |obj| obj.string_table.get(offset).?,
            .object => |obj| obj.string_table.get(offset),
        };
    }

    pub fn importedGlobals(file: File) u32 {
        return switch (file) {
            inline else => |obj| obj.imported_globals_count,
        };
    }

    pub fn importedFunctions(file: File) u32 {
        return switch (file) {
            inline else => |obj| obj.imported_functions_count,
        };
    }

    pub fn importedTables(file: File) u32 {
        return switch (file) {
            inline else => |obj| obj.imported_tables_count,
        };
    }

    pub fn functions(file: File) []const std.wasm.Func {
        return switch (file) {
            .zig_object => |obj| obj.functions.items,
            .object => |obj| obj.functions,
        };
    }

    pub fn globals(file: File) []const std.wasm.Global {
        return switch (file) {
            .zig_object => |obj| obj.globals.items,
            .object => |obj| obj.globals,
        };
    }

    pub fn funcTypes(file: File) []const std.wasm.Type {
        return switch (file) {
            .zig_object => |obj| obj.func_types.items,
            .object => |obj| obj.func_types,
        };
    }

    pub const Entry = union(enum) {
        null: void,
        zig_object: ZigObject,
        object: Object,
    };
};

const std = @import("std");
const types = @import("types.zig");

const AtomIndex = @import("Atom.zig").Index;
const Object = @import("Object.zig");
const Symbol = @import("Symbol.zig");
const Wasm = @import("../Wasm.zig");
const ZigObject = @import("ZigObject.zig");
