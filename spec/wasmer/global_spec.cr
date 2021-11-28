require "../spec_helper"

def test_mod
  <<-WAT
(module
(global $x (export "x") (mut i32) (i32.const 0))
(global $y (export "y") (mut i32) (i32.const 7))
(global $z (export "z") i32 (i32.const 42))

(func (export "get_x") (result i32)
  (global.get $x))

(func (export "increment_x")
  (global.set $x
    (i32.add (global.get $x) (i32.const 1)))))
WAT
end

def get_test_instance
  store = Wasmer.default_engine.new_store
  mod = Wasmer.module(store, test_mod)
  Wasmer.new_instance(mod)
end

describe Wasmer do
  it "test global get type" do
    x = get_test_instance.global("x").not_nil!
    ty = x.type
    ty.value_type.kind.should eq(Wasmer::I32)
    ty.mutability.should eq(Wasmer::Mutable)
  end

  it "test global mutable" do
    exp = get_test_instance
    x = exp.global("x").not_nil!
    x.type.mutability.should eq(Wasmer::Mutable)
    y = exp.global("y").not_nil!
    y.type.mutability.should eq(Wasmer::Mutable)
    z = exp.global("z").not_nil!
    z.type.mutability.should eq(Wasmer::Immutable)
  end

  it "test global read write" do
    exp = get_test_instance
    y = exp.global("y").not_nil!
    y.get.should eq(7)
    y.set(8)
    y.get.should eq(8)
  end

  it "test global read write and exported functions" do
    exp = get_test_instance
    x = exp.global("x").not_nil!
    x.get.should eq(0)
    x.set(1)
    getx = exp.function("get_x").not_nil!
    getx.call.should eq(1)

    incrx = exp.function("increment_x").not_nil!
    incrx.call
    getx.call.should eq(2)
  end

  it "test global read write constant" do
    exp = get_test_instance
    z = exp.global("z").not_nil!
    z.get.should eq(42)
    expect_raises(Wasmer::WasmerError, "The global variable is not mutable, cannot set a new value") do
      z.set(8)
    end
    z.get.should eq(42)
  end
end
