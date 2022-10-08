require "../spec_helper"

describe Wasmer do
  it "test raw function" do
    store = Wasmer.default_engine.new_store
    str = <<-WAT
    (module
    (type $sum_t (func (param i32 i32) (result i32)))
    (func $sum_f (type $sum_t) (param $x i32) (param $y i32) (result i32)
      local.get $x
      local.get $y
      i32.add)
    (export "sum" (func $sum_f)))
    WAT
    mod = Wasmer::Module.new(store, str.to_slice)

    instance = Wasmer.new_instance(mod)
    sum = instance.raw_function("sum").not_nil!
    result = sum.call(1, 2)
    result.should eq(3)
  end

  it "test native function" do
    store = Wasmer.default_engine.new_store
    str = <<-WAT
    (module
    (type $sum_t (func (param i32 i32) (result i32)))
    (func $sum_f (type $sum_t) (param $x i32) (param $y i32) (result i32)
      local.get $x
      local.get $y
      i32.add)
    (export "sum" (func $sum_f)))
    WAT
    mod = Wasmer::Module.new(store, str.to_slice)

    instance = Wasmer.new_instance(mod)
    sum = instance.function("sum").not_nil!

    result = sum.call(1, 2)
    result.should eq(3)
  end

  it "test function type" do
    params = Wasmer.value_types(Wasmer::I32, Wasmer::I64)
    results = Wasmer.value_types(Wasmer::F32)

    function_type = Wasmer::FunctionType.new(params, results)
    function_type.params.size.should eq(params.size)
    function_type.results.size.should eq(results.size)
  end

  it "test function type and extern type" do
    params = Wasmer.value_types(Wasmer::I32, Wasmer::I64)
    results = Wasmer.value_types(Wasmer::F32)

    function_type = Wasmer::FunctionType.new(params, results)
    extern_type = function_type.to_externtype
    extern_type.kind.should eq(Wasmer::ExternKind::Func)

    function_type_again = extern_type.to_functiontype.not_nil!
    function_type_again.params.size.should eq(params.size)
    function_type_again.results.size.should eq(results.size)
  end

  it "test function call return zero value" do
    store = Wasmer.default_engine.new_store
    str = <<-WAT
    (module
    (type $test_t (func (param i32 i32)))
    (func $test_f (type $test_t) (param $x i32) (param $y i32))
    (export "test" (func $test_f)))
    WAT
    mod = Wasmer::Module.new(store, str.to_slice)

    instance = Wasmer.new_instance(mod)
    test = instance.function("test").not_nil!

    result = test.call(1, 2)
    result.should be_nil
  end

  it "test function call return multiple values" do
    store = Wasmer.default_engine.new_store
    str = <<-WAT
    (module
    (type $swap_t (func (param i32 i64) (result i64 i32)))
    (func $swap_f (type $swap_t) (param $x i32) (param $y i64) (result i64 i32)
      local.get $y
      local.get $x)
    (export "swap" (func $swap_f)))
    WAT
    mod = Wasmer::Module.new(store, str)

    instance = Wasmer.new_instance(mod)
    test = instance.function("swap").not_nil!

    result = test.call(41, 42)
    result.should eq([42, 41])
  end

  it "test function" do
    f = get_inst.function("sum").not_nil!
    f.call(1, 2).should eq(3)
  end

  it "test arity0" do
    f = get_inst.function("arity_0").not_nil!
    f.call.should eq(42)
  end

  it "test function I32 I32" do
    f = get_inst.function("i32_i32").not_nil!
    f.call(7).should eq(7)
    f.call(7_u32).should eq(7)
    f.call(7_i8).should eq(7)
    f.call(7_u8).should eq(7)
    f.call(7_i16).should eq(7)
    f.call(7_u16).should eq(7)
  end

  it "test function I64 I64" do
    f = get_inst.function("i64_i64").not_nil!
    f.call(7).should eq(7_i64)
    f.call(7_u32).should eq(7_i64)
    f.call(7_i8).should eq(7_i64)
    f.call(7_u8).should eq(7_i64)
    f.call(7_i16).should eq(7_i64)
    f.call(7_u16).should eq(7_i64)
    f.call(7_i64).should eq(7_i64)
    f.call(7_u64).should eq(7_i64)
  end

  it "test function F32 F32" do
    f = get_inst.function("f32_f32").not_nil!
    f.call(7.42_f32).should eq(7.42_f32)
  end

  it "test function F64 F64" do
    f = get_inst.function("f64_f64").not_nil!
    f.call(7.42).should eq(7.42)
  end

  it "test function i32_i64_f32_f64_f64" do
    f = get_inst.function("i32_i64_f32_f64_f64").not_nil!
    ret = f.call(1, 2, 3.4_f32, 5.6).not_nil!.as(Float64)
    ret.round.should eq(1 + 2 + 3.4 + 5.6)
  end

  it "test bool_casted_to_i32" do
    f = get_inst.function("bool_casted_to_i32").not_nil!
    f.call.should eq(1)
  end

  it "test host function" do
    store = Wasmer.default_engine.new_store
    str = <<-WAT
    (module
    (import "math" "sum" (func $sum (param i32 i32) (result i32)))
    (func (export "add_one") (param $x i32) (result i32)
      local.get $x
      i32.const 1
      call $sum))
    WAT
    mod = Wasmer::Module.new(store, str)

    func = Wasmer::Function.new(store, Wasmer::FunctionType.new(
      Wasmer.value_types(Wasmer::I32, Wasmer::I32),
      Wasmer.value_types(Wasmer::I32))) { |args|
      x = args[0].as_i
      y = args[1].as_i
      [Wasmer::Value.new(x + y)]
    }

    imp = Wasmer::ImportObject.new
    imp.register("math", {"sum" => func.as(Wasmer::WithExtern)})

    instance = Wasmer.new_instance(mod, imp)

    add_one = instance.function("add_one").not_nil!

    result = add_one.call(41)
    result.should eq(42)
  end

  it "test host function with I64" do
    store = Wasmer.default_engine.new_store
    str = <<-WAT
    (module
    (import "math" "sum" (func $sum (param i64 i64) (result i64)))
    (func (export "add_one") (param $x i64) (result i64)
      local.get $x
      i64.const 1
      call $sum))
    WAT
    mod = Wasmer::Module.new(store, str)

    func = Wasmer::Function.new(store, Wasmer::FunctionType.new(
      Wasmer.value_types(Wasmer::I64, Wasmer::I64),
      Wasmer.value_types(Wasmer::I64))) { |args|
      x = args[0].as_i64
      y = args[1].as_i64
      [Wasmer::Value.new(x + y)]
    }

    imp = Wasmer::ImportObject.new
    imp.register("math", {"sum" => func.as(Wasmer::WithExtern)})

    instance = Wasmer.new_instance(mod, imp)

    add_one = instance.function("add_one").not_nil!

    result = add_one.call(41)
    result.should eq(42_i64)
  end

  it "test host function with env" do
    store = Wasmer.default_engine.new_store
    str = <<-WAT
    (module
    (import "math" "sum" (func $sum (param i32 i32) (result i32)))
    (func (export "add_one") (param $x i32) (result i32)
      local.get $x
      i32.const 1
      call $sum))
    WAT
    mod = Wasmer::Module.new(store, str)

    env = MyEnvironment.new(nil, 42)

    func = Wasmer::Function.new(store, Wasmer::FunctionType.new(
      Wasmer.value_types(Wasmer::I32, Wasmer::I32),
      Wasmer.value_types(Wasmer::I32)), Box.box(env)) { |ev, args|
      mev = Box(MyEnvironment).unbox(ev)
      x = args[0].as_i
      y = args[1].as_i
      [Wasmer::Value.new(mev.answer + x + y)]
    }

    imp = Wasmer::ImportObject.new
    imp.register("math", {"sum" => func.as(Wasmer::WithExtern)})

    instance = Wasmer.new_instance(mod, imp)

    add_one = instance.function("add_one").not_nil!

    result = add_one.call(7)
    result.should eq(50)
  end

  it "test host function trap" do
    store = Wasmer.default_engine.new_store
    str = <<-WAT
    (module
    (import "math" "sum" (func $sum (param i32 i32) (result i32)))
    (func (export "add_one") (param $x i32) (result i32)
      local.get $x
      i32.const 1
      call $sum))
    WAT
    mod = Wasmer::Module.new(store, str)

    func = Wasmer::Function.new(store, Wasmer::FunctionType.new(
      Wasmer.value_types(Wasmer::I32, Wasmer::I32),
      Wasmer.value_types(Wasmer::I32))) { |args|
      raise "oops"
    }

    imp = Wasmer::ImportObject.new
    imp.register("math", {"sum" => func.as(Wasmer::WithExtern)})

    instance = Wasmer.new_instance(mod, imp)

    add_one = instance.function("add_one").not_nil!

    expect_raises(Wasmer::TrapException, "oops") do
      add_one.call(41)
    end
  end

  it "test function trap" do
    store = Wasmer.default_engine.new_store
    str = <<-WAT
    (module
    (func (export "trap") (result i32) (unreachable) (i32.const 1)))
    WAT
    mod = Wasmer::Module.new(store, str)

    instance = Wasmer.new_instance(mod)
    test = instance.function("trap").not_nil!
    begin
      test.call
    rescue ex : Wasmer::TrapException
      trap = ex.trap
      trap.message.should eq("unreachable")
    end
  end
end
