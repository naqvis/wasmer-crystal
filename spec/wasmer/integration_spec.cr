require "../spec_helper"

describe Wasmer do
  describe "Memory" do
    it "test host-created memory read/write" do
      store = Wasmer.default_engine.new_store
      mem = Wasmer::Memory.new(store, Wasmer::MemoryType.new(Wasmer::Limits.new(1, Wasmer.max_unbound)))
      data = mem.data
      data[0] = 0xDE_u8
      data[1] = 0xAD_u8
      data[0].should eq(0xDE_u8)
      data[1].should eq(0xAD_u8)
    end

    it "test memory grow" do
      store = Wasmer.default_engine.new_store
      mem = Wasmer::Memory.new(store, Wasmer::MemoryType.new(Wasmer::Limits.new(1, 10)))
      mem.size.to_u32.should eq(1_u32)
      mem.grow(Wasmer::Pages.new(2))
      mem.size.to_u32.should eq(3_u32)
      mem.data.size.should eq(3 * 65536)
    end

    it "test memory exported from module is usable" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (memory (export "mem") 1)
          (func (export "store_byte") (param $offset i32) (param $value i32)
            (i32.store8 (local.get $offset) (local.get $value)))
          (func (export "load_byte") (param $offset i32) (result i32)
            (i32.load8_u (local.get $offset))))
      WAT
      instance = Wasmer.new_instance(mod)
      mem = instance.exports.memory("mem").not_nil!
      instance.function("store_byte").not_nil!.call(0, 0xAB)
      instance.function("load_byte").not_nil!.call(0).should eq(0xAB)
      mem.data[0].should eq(0xAB_u8)
    end

    it "test memory view offset" do
      store = Wasmer.default_engine.new_store
      mem = Wasmer::Memory.new(store, Wasmer::MemoryType.new(Wasmer::Limits.new(1, Wasmer.max_unbound)))
      mem.data[100] = 0x42_u8
      mem.view(100)[0].should eq(0x42_u8)
    end

    it "test memory to_extern roundtrip" do
      store = Wasmer.default_engine.new_store
      mem = Wasmer::Memory.new(store, Wasmer::MemoryType.new(Wasmer::Limits.new(1, Wasmer.max_unbound)))
      ext = mem.to_extern
      ext.kind.should eq(Wasmer::ExternKind::Memory)
      ext.to_memory.not_nil!.size.to_u32.should eq(1_u32)
    end
  end

  describe "Module serialize/deserialize" do
    it "test roundtrip preserves functionality" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (func (export "mul") (param i32 i32) (result i32)
            local.get 0
            local.get 1
            i32.mul))
      WAT
      serialized = mod.serialize
      serialized.size.should be > 0
      deserialized = Wasmer::Module.deserialize(store, serialized).not_nil!
      instance = Wasmer.new_instance(deserialized)
      instance.function("mul").not_nil!.call(6, 7).should eq(42)
    end

    it "test deserialized module has same exports" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (func (export "f") (result i32) (i32.const 1))
          (memory (export "m") 1)
          (global (export "g") i32 (i32.const 2)))
      WAT
      serialized = mod.serialize
      deserialized = Wasmer::Module.deserialize(store, serialized).not_nil!
      names = deserialized.exports.map(&.name)
      names.should contain("f")
      names.should contain("m")
      names.should contain("g")
    end
  end

  describe "Module validate" do
    it "test valid wasm passes validation" do
      store = Wasmer.default_engine.new_store
      bytes = Wasmer.wat2wasm("(module)")
      Wasmer::Module.validate(store, bytes.to_slice).should be_true
    end

    it "test invalid bytes fail validation" do
      store = Wasmer.default_engine.new_store
      Wasmer::Module.validate(store, Bytes[0x00, 0x61, 0x73]).should be_false
    end
  end

  describe "Trap origin and trace" do
    it "test trap message is preserved" do
      wat = <<-WAT
        (module
          (func (export "boom") unreachable))
      WAT
      store = Wasmer.default_engine.new_store
      instance = Wasmer.new_instance(Wasmer::Module.new(store, wat))
      begin
        instance.function("boom").not_nil!.call
      rescue ex : Wasmer::TrapException
        ex.trap.message.should eq("unreachable")
      end
    end
  end

  describe "WASI proc_exit detection" do
    it "test wasi_exit? and wasi_exit_code" do
      wat = <<-WAT
        (module
          (import "wasi_snapshot_preview1" "proc_exit" (func $exit (param i32)))
          (memory (export "memory") 1)
          (func (export "_start") (call $exit (i32.const 42))))
      WAT
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, wat)
      env = Wasmer::Wasi::StateBuilder.builder("test", store) { with_inherit_stdout }
      instance = env.instantiate(store, mod)
      begin
        instance.exports.wasi_start_func.call
      rescue ex : Wasmer::TrapException
        ex.trap.wasi_exit?.should be_true
        ex.trap.wasi_exit_code.should eq(42)
      end
    end

    it "test non-WASI trap is not detected as exit" do
      wat = <<-WAT
        (module (func (export "boom") unreachable))
      WAT
      store = Wasmer.default_engine.new_store
      instance = Wasmer.new_instance(Wasmer::Module.new(store, wat))
      begin
        instance.function("boom").not_nil!.call
      rescue ex : Wasmer::TrapException
        ex.trap.wasi_exit?.should be_false
        ex.trap.wasi_exit_code.should be_nil
      end
    end
  end

  describe "Extern conversions" do
    it "test all extern kind conversions" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (func (export "f") (result i32) (i32.const 0))
          (global (export "g") i32 (i32.const 0))
          (memory (export "m") 1)
          (table (export "t") 1 funcref))
      WAT
      instance = Wasmer.new_instance(mod)

      instance["f"].to_function.should_not be_nil
      instance["f"].to_global.should be_nil
      instance["f"].to_memory.should be_nil
      instance["f"].to_table.should be_nil

      instance["g"].to_global.should_not be_nil
      instance["g"].to_function.should be_nil

      instance["m"].to_memory.should_not be_nil
      instance["m"].to_function.should be_nil

      instance["t"].to_table.should_not be_nil
      instance["t"].to_function.should be_nil
    end
  end

  describe "Value creation" do
    it "test Value.new auto-detects kind from type" do
      Wasmer::Value.new(42).kind.should eq(Wasmer::ValueKind::I32)
      Wasmer::Value.new(42_i64).kind.should eq(Wasmer::ValueKind::I64)
      Wasmer::Value.new(3.14_f32).kind.should eq(Wasmer::ValueKind::F32)
      Wasmer::Value.new(2.71).kind.should eq(Wasmer::ValueKind::F64)
    end
  end

  describe "ImportObject contains_namespace?" do
    it "test namespace detection" do
      imports = Wasmer::ImportObject.new
      imports.contains_namespace?("env").should be_false
      noop_fn = Wasmer::Function.new(
        Wasmer.default_engine.new_store,
        Wasmer::FunctionType.new) { [] of Wasmer::Value }
      imports.register("env", {"x" => noop_fn.as(Wasmer::WithExtern)})
      imports.contains_namespace?("env").should be_true
      imports.contains_namespace?("other").should be_false
    end
  end

  describe "Triple.from_host" do
    it "test host triple detection" do
      triple = Wasmer::Triple.from_host
      triple.to_unsafe.null?.should be_false
    end
  end

  describe "CpuFeatures.add" do
    it "test adding cpu feature" do
      cpu = Wasmer::CpuFeatures.new
      cpu.add("sse4.2")
      cpu.to_unsafe.null?.should be_false
    end
  end

  describe "Function arity" do
    it "test param_arity and result_arity" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (func (export "add") (param i32 i32) (result i32)
            local.get 0 local.get 1 i32.add)
          (func (export "nop")
            nop))
      WAT
      instance = Wasmer.new_instance(mod)
      add_fn = instance.exports.raw_function("add").not_nil!
      add_fn.param_arity.should eq(2)
      add_fn.result_arity.should eq(1)

      nop_fn = instance.exports.raw_function("nop").not_nil!
      nop_fn.param_arity.should eq(0)
      nop_fn.result_arity.should eq(0)
    end
  end

  describe "Global host creation" do
    it "test creating and using a host-side global" do
      store = Wasmer.default_engine.new_store
      gtype = Wasmer::GlobalType.new(
        Wasmer::ValueType.new(Wasmer::I32),
        Wasmer::Mutable)
      global = Wasmer::Global.new(store, gtype, Wasmer::Value.new(100))
      global.get.to_i.should eq(100)
      global.set(Wasmer::Value.new(200))
      global.get.to_i.should eq(200)
    end
  end

  describe "Exports bracket access" do
    it "test raises on missing export" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, "(module)")
      instance = Wasmer.new_instance(mod)
      raises = false
      begin
        instance.exports["missing"]
      rescue Wasmer::WasmerError
        raises = true
      end
      raises.should be_true
    end
  end

  describe "Instance without imports" do
    it "test Instance.new(mod) convenience constructor" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module (func (export "answer") (result i32) (i32.const 42)))
      WAT
      instance = Wasmer::Instance.new(mod)
      instance.function("answer").not_nil!.call.should eq(42)
    end
  end

  describe "Limits validation" do
    it "test min > max raises" do
      expect_raises(Wasmer::WasmerError) do
        Wasmer::Limits.new(10, 5)
      end
    end
  end

  describe "Wasmer.version" do
    it "test returns version string" do
      Wasmer.version.should_not be_empty
    end
  end
end
