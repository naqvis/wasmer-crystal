require "../spec_helper"

describe Wasmer do
  it "test tabletype" do
    vtype = Wasmer::ValueType.new(Wasmer::I32)
    min = 1
    max = 7
    limits = Wasmer::Limits.new(min, max)

    table_type = Wasmer::TableType.new(vtype, limits)

    vtype_again = table_type.value_type
    vtype_again.kind.should eq(Wasmer::I32)

    limits_again = table_type.limits
    limits_again.minimum.should eq(min)
    limits_again.maximum.should eq(max)
  end

  it "test table type to extern and back" do
    vtype = Wasmer::ValueType.new(Wasmer::I32)
    min = 1
    max = 7
    limits = Wasmer::Limits.new(min, max)

    table_type = Wasmer::TableType.new(vtype, limits)
    extern_type = table_type.to_externtype
    extern_type.kind.should eq(Wasmer::ExternKind::Table)

    table_type_again = extern_type.to_tabletype.not_nil!

    vtype_again = table_type_again.value_type
    vtype_again.kind.should eq(Wasmer::I32)

    limits_again = table_type_again.limits
    limits_again.minimum.should eq(min)
    limits_again.maximum.should eq(max)
  end

  it "test table" do
    wat = <<-WAT
    (module
      (table (export "table") 2 10 funcref)
    
      (func (export "call_indirect") (param i32 i32) (result i32)
        (call_indirect (param i32) (result i32) (local.get 0) (local.get 1))
      )
    
      (func $f (export "f") (param i32) (result i32) (local.get 0))
      (func (export "g") (param i32) (result i32) (i32.const 666))
    
      (elem (i32.const 1) $f)
    )
    WAT

    store = Wasmer.default_engine.new_store
    mod = Wasmer.module(store, wat)
    inst = Wasmer.new_instance(mod)
    table = inst.table("table").not_nil!
    table.size.should eq(2)
    call_indirect = inst.function("call_indirect").not_nil!
    expect_raises(Wasmer::TrapException, "uninitialized element") do
      call_indirect.call(0, 0)
    end

    call_indirect.call(7, 1).should eq(7)
    expect_raises(Wasmer::TrapException, "undefined element: out of bounds table") do
      call_indirect.call(0, 2)
    end
  end
end
