require "../spec_helper"

describe Wasmer do
  it "test importtype for functiontype" do
    params = Wasmer.value_types(Wasmer::I32, Wasmer::I64)
    results = Wasmer.value_types(Wasmer::F32)
    functype = Wasmer::FunctionType.new(params, results)

    mod_ns = "foo"
    name = "bar"
    import_type = Wasmer::ImportType.new(mod_ns, name, functype)
    import_type.mod_name.should eq(mod_ns)
    import_type.name.should eq(name)

    extern_type = import_type.type
    extern_type.kind.should eq(Wasmer::ExternKind::Func)

    functype_again = extern_type.to_functiontype.not_nil!
    functype_again.params.size.should eq(params.size)
    functype_again.results.size.should eq(results.size)
  end

  it "test importtype for globaltype" do
    valtype = Wasmer::ValueType.new(Wasmer::I32)
    globaltype = Wasmer::GlobalType.new(valtype, Wasmer::Mutable)

    mod_ns = "foo"
    name = "bar"
    import_type = Wasmer::ImportType.new(mod_ns, name, globaltype)
    import_type.mod_name.should eq(mod_ns)
    import_type.name.should eq(name)

    extern_type = import_type.type
    extern_type.kind.should eq(Wasmer::ExternKind::Global)

    globaltype_again = extern_type.to_globaltype.not_nil!
    globaltype_again.value_type.kind.should eq(Wasmer::I32)
    globaltype_again.mutability.should eq(Wasmer::Mutable)
  end

  it "test importtype for tabletype" do
    valtype = Wasmer::ValueType.new(Wasmer::I32)
    min = 1
    max = 7
    limits = Wasmer::Limits.new(min, max)

    tabletype = Wasmer::TableType.new(valtype, limits)
    mod_ns = "foo"
    name = "bar"
    import_type = Wasmer::ImportType.new(mod_ns, name, tabletype)
    import_type.mod_name.should eq(mod_ns)
    import_type.name.should eq(name)

    extern_type = import_type.type
    extern_type.kind.should eq(Wasmer::ExternKind::Table)

    tabletype_again = extern_type.to_tabletype.not_nil!
    valtype_again = tabletype_again.value_type
    valtype_again.kind.should eq(Wasmer::I32)

    limits_again = tabletype_again.limits
    limits_again.minimum.should eq(min)
    limits_again.maximum.should eq(max)
  end

  it "test importtype for memorytype" do
    min = 1
    max = 7
    limits = Wasmer::Limits.new(min, max)

    memorytype = Wasmer::MemoryType.new(limits)
    mod_ns = "foo"
    name = "bar"
    import_type = Wasmer::ImportType.new(mod_ns, name, memorytype)
    import_type.mod_name.should eq(mod_ns)
    import_type.name.should eq(name)

    extern_type = import_type.type
    extern_type.kind.should eq(Wasmer::ExternKind::Memory)

    memorytype_again = extern_type.to_memorytype.not_nil!

    limits_again = memorytype_again.limits
    limits_again.minimum.should eq(min)
    limits_again.maximum.should eq(max)
  end
end
