require "../spec_helper"

describe Wasmer do
  it "test exporttype for functiontype" do
    params = Wasmer.value_types(Wasmer::I32, Wasmer::I64)
    results = Wasmer.value_types(Wasmer::F32)
    functype = Wasmer::FunctionType.new(params, results)

    name = "foo"
    export_type = Wasmer::ExportType.new(name, functype)
    export_type.name.should eq(name)

    extern_type = export_type.type
    extern_type.kind.should eq(Wasmer::ExternKind::Func)

    functype_again = extern_type.to_functiontype.not_nil!
    functype_again.params.size.should eq(params.size)
    functype_again.results.size.should eq(results.size)
  end

  it "test exporttype for globaltype" do
    valtype = Wasmer::ValueType.new(Wasmer::I32)
    globaltype = Wasmer::GlobalType.new(valtype, Wasmer::Mutable)

    name = "foo"
    export_type = Wasmer::ExportType.new(name, globaltype)
    export_type.name.should eq(name)

    extern_type = export_type.type
    extern_type.kind.should eq(Wasmer::ExternKind::Global)

    globaltype_again = extern_type.to_globaltype.not_nil!
    globaltype_again.value_type.kind.should eq(Wasmer::I32)
    globaltype_again.mutability.should eq(Wasmer::Mutable)
  end

  it "test exporttype for tabletype" do
    valtype = Wasmer::ValueType.new(Wasmer::I32)
    min = 1
    max = 7
    limits = Wasmer::Limits.new(min, max)

    tabletype = Wasmer::TableType.new(valtype, limits)
    name = "foo"
    export_type = Wasmer::ExportType.new(name, tabletype)
    export_type.name.should eq(name)

    extern_type = export_type.type
    extern_type.kind.should eq(Wasmer::ExternKind::Table)

    tabletype_again = extern_type.to_tabletype.not_nil!
    valtype_again = tabletype_again.value_type
    valtype_again.kind.should eq(Wasmer::I32)

    limits_again = tabletype_again.limits
    limits_again.minimum.should eq(min)
    limits_again.maximum.should eq(max)
  end

  it "test exporttype for memorytype" do
    min = 1
    max = 7
    limits = Wasmer::Limits.new(min, max)

    memorytype = Wasmer::MemoryType.new(limits)
    name = "foo"
    export_type = Wasmer::ExportType.new(name, memorytype)
    export_type.name.should eq(name)

    extern_type = export_type.type
    extern_type.kind.should eq(Wasmer::ExternKind::Memory)

    memorytype_again = extern_type.to_memorytype.not_nil!

    limits_again = memorytype_again.limits
    limits_again.minimum.should eq(min)
    limits_again.maximum.should eq(max)
  end
end
