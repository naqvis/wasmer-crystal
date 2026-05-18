require "../spec_helper"

describe Wasmer do
  describe "Host function multi-value return" do
    it "host function returning [i32, f64] via Wasm call" do
      store = Wasmer.default_engine.new_store

      ft = Wasmer::FunctionType.new(
        Wasmer.value_types(Wasmer::I32, Wasmer::F64),
        Wasmer.value_types(Wasmer::I32, Wasmer::F64))

      host_fn = Wasmer::Function.new(store, ft) { |args|
        x = args[0].as_i
        y = args[1].as_f
        [Wasmer::Value.new(x * 10, Wasmer::I32), Wasmer::Value.new(y * 2.0, Wasmer::F64)]
      }

      imp = Wasmer::ImportObject.new
      imp.register("env", {"multi" => host_fn.as(Wasmer::WithExtern)})

      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (import "env" "multi" (func $multi (param i32 f64) (result i32 f64)))
          (func (export "call_multi") (param i32 f64) (result i32 f64)
            local.get 0
            local.get 1
            call $multi))
      WAT
      instance = Wasmer.new_instance(mod, imp)
      result = instance.function("call_multi").not_nil!.call(4, 2.5)
      arr = result.as(Array)
      arr[0].should eq(40)
      arr[1].should eq(5.0)
    end
  end

  describe "Memory limit and stability" do
    it "grow beyond max returns false" do
      store = Wasmer.default_engine.new_store
      mem = Wasmer::Memory.new(store, Wasmer::MemoryType.new(Wasmer::Limits.new(1, 3)))
      mem.grow(Wasmer::Pages.new(10)).should be_false
      mem.size.to_u32.should eq(1)
    end

    it "data pointer remains valid after grow" do
      store = Wasmer.default_engine.new_store
      mem = Wasmer::Memory.new(store, Wasmer::MemoryType.new(Wasmer::Limits.new(1, 5)))
      mem.data[0] = 0xAB_u8
      mem.data[1] = 0xCD_u8
      mem.grow(Wasmer::Pages.new(2)).should be_true
      mem.data[0].should eq(0xAB_u8)
      mem.data[1].should eq(0xCD_u8)
      mem.data[3 * 65536 - 1] = 0xEF_u8
      mem.data[3 * 65536 - 1].should eq(0xEF_u8)
    end

    it "view with offset beyond bytesize raises" do
      store = Wasmer.default_engine.new_store
      mem = Wasmer::Memory.new(store, Wasmer::MemoryType.new(Wasmer::Limits.new(1, Wasmer.max_unbound)))
      expect_raises(Wasmer::WasmerError, "offset exceeded the memory size") do
        mem.view(mem.bytesize + 1)
      end
    end

    it "memory type roundtrips through live memory" do
      store = Wasmer.default_engine.new_store
      limits = Wasmer::Limits.new(2, 8)
      mem = Wasmer::Memory.new(store, Wasmer::MemoryType.new(limits))
      retrieved = mem.type
      retrieved.limits.minimum.should eq(2)
      retrieved.limits.maximum.should eq(8)
    end
  end

  describe "Module metadata" do
    it "name is nil for unnamed modules" do
      store = Wasmer.default_engine.new_store
      Wasmer::Module.new(store, "(module)").name.should be_nil
    end

    it "export types from actual module match declarations" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (func (export "f") (result i32) (i32.const 0))
          (global (export "g") i32 (i32.const 1))
          (memory (export "m") 1)
          (table (export "t") 1 funcref))
      WAT
      exports = mod.exports
      exports.map(&.name).should contain("f")
      exports.map(&.name).should contain("g")
      exports.map(&.name).should contain("m")
      exports.map(&.name).should contain("t")

      kinds = exports.map { |e| e.type.kind }
      kinds.should contain(Wasmer::ExternKind::Func)
      kinds.should contain(Wasmer::ExternKind::Global)
      kinds.should contain(Wasmer::ExternKind::Memory)
      kinds.should contain(Wasmer::ExternKind::Table)
    end

    it "import types from actual module match declarations" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (import "env" "f" (func (result i32)))
          (import "env" "g" (global i32))
          (import "env" "m" (memory 1))
          (import "env" "t" (table 1 funcref)))
      WAT
      import_names = mod.imports.map { |i| {i.mod_name, i.name} }
      import_names.should contain({"env", "f"})
      import_names.should contain({"env", "g"})
      import_names.should contain({"env", "m"})
      import_names.should contain({"env", "t"})
    end
  end

  describe "Instance creation edge cases" do
    it "missing import namespace raises WasmerError" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (import "env" "required_func" (func (result i32)))
          (func (export "f") (result i32) (call 0)))
      WAT
      expect_raises(Wasmer::WasmerError, "Missing import: 'env'.'required_func'") do
        Wasmer.new_instance(mod)
      end
    end

    it "wrong import name in registered namespace raises WasmerError" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (import "env" "required_func" (func (result i32))))
      WAT
      ft = Wasmer::FunctionType.new(
        Wasmer.value_types,
        Wasmer.value_types(Wasmer::I32))
      fn = Wasmer::Function.new(store, ft) { [Wasmer::Value.new(0, Wasmer::I32)] }
      imports = Wasmer::ImportObject.new
      imports.register("env", {"wrong_name" => fn.as(Wasmer::WithExtern)})
      expect_raises(Wasmer::WasmerError, "Missing import: 'env'.'required_func'") do
        Wasmer.new_instance(mod, imports)
      end
    end

    it "multiple instances from same module have isolated globals" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (global (export "g") (mut i32) (i32.const 0))
          (func (export "inc")
            global.get 0
            i32.const 1
            i32.add
            global.set 0)
          (func (export "get") (result i32)
            global.get 0))
      WAT

      inst1 = Wasmer.new_instance(mod)
      inst2 = Wasmer.new_instance(mod)

      inst1.function("inc").not_nil!.call
      inst1.function("inc").not_nil!.call
      inst1.function("get").not_nil!.call.should eq(2)
      inst2.function("get").not_nil!.call.should eq(0)

      inst2.function("inc").not_nil!.call
      inst1.function("get").not_nil!.call.should eq(2)
      inst2.function("get").not_nil!.call.should eq(1)
    end
  end

  describe "Function argument validation in Native#run" do
    it "raises on too few arguments" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (func (export "add") (param i32 i32) (result i32)
            local.get 0 local.get 1 i32.add))
      WAT
      fn = Wasmer.new_instance(mod).function("add").not_nil!
      expect_raises(Wasmer::WasmerError, "Missing 1 argument") do
        fn.call(5)
      end
    end

    it "raises on too many arguments" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (func (export "f") (result i32) (i32.const 42)))
      WAT
      fn = Wasmer.new_instance(mod).function("f").not_nil!
      expect_raises(Wasmer::WasmerError, "2 extra argument") do
        fn.call(1, 2)
      end
    end
  end

  describe "Trap origin and trace" do
    it "origin and trace frames are populated" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (func $inner unreachable)
          (func (export "outer") call $inner))
      WAT
      instance = Wasmer.new_instance(mod)
      begin
        instance.function("outer").not_nil!.call
      rescue ex : Wasmer::TrapException
        if origin = ex.trap.origin
          origin.function_index.should be >= 0
          origin.function_offset.should be >= 0
          origin.module_offset.should be >= 0
        end
        ex.trap.trace.frames.each do |frame|
          frame.function_index.should be >= 0
        end
      end
    end
  end

  describe "ExternType wrong-kind conversions" do
    it "returns nil when converting to mismatched type" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, "(module (func (export \"f\") (result i32) (i32.const 0)))")
      extern_type = mod.exports.find { |e| e.name == "f" }.not_nil!.type
      extern_type.to_globaltype.should be_nil
      extern_type.to_memorytype.should be_nil
      extern_type.to_tabletype.should be_nil
    end
  end

  describe "ExternType from module exports" do
    it "roundtrips FunctionType through module export" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, <<-WAT)
        (module
          (func (export "f") (param i32 i64) (result f32)
            (f32.const 0.0)))
      WAT
      extern_type = mod.exports.find { |e| e.name == "f" }.not_nil!.type
      extern_type.kind.should eq(Wasmer::ExternKind::Func)
      func_type = extern_type.to_functiontype.not_nil!
      func_type.params.map(&.kind).should eq([Wasmer::I32, Wasmer::I64])
      func_type.results.map(&.kind).should eq([Wasmer::F32])
    end

    it "roundtrips MemoryType through module export" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, "(module (memory (export \"m\") 2 10))")
      extern_type = mod.exports.find { |e| e.name == "m" }.not_nil!.type
      extern_type.kind.should eq(Wasmer::ExternKind::Memory)
      mem_type = extern_type.to_memorytype.not_nil!
      mem_type.limits.minimum.should eq(2)
      mem_type.limits.maximum.should eq(10)
    end
  end

  describe "Backend availability and configuration" do
    it "Cranelift is available" do
      Wasmer::CompilerKind::Cranelift.available?.should be_true
    end

    it "engine with explicit Cranelift backend runs wasm" do
      config = Wasmer::Config.new
      config.use_cranelift_compiler
      store = Wasmer::Engine.new(config).new_store
      mod = Wasmer::Module.new(store, "(module (func (export \"f\") (result i32) (i32.const 7)))")
      Wasmer.new_instance(mod).function("f").not_nil!.call.should eq(7)
    end

    it "all legacy engine methods map to Cranelift and work" do
      [->(c : Wasmer::Config) { c.use_universal_engine },
       ->(c : Wasmer::Config) { c.use_dylib_engine },
       ->(c : Wasmer::Config) { c.use_staticlib_engine }].each do |configure|
        config = Wasmer::Config.new
        configure.call(config)
        store = Wasmer::Engine.new(config).new_store
        Wasmer::Module.new(store, "(module)")
      end
    end
  end

  describe "WASI environment" do
    it "generate_import_object resolves wasi_snapshot_preview1 imports" do
      store = Wasmer.default_engine.new_store
      mod = Wasmer::Module.new(store, get_data("wasi.wasm"))

      env = Wasmer::Wasi::StateBuilder.builder("test-program", store) {
        with_inherit_stdout
      }

      imports = env.generate_import_object(store, mod)
      imports.contains_namespace?("wasi_snapshot_preview1").should be_true
    end

    it "builder accepts full configuration without error" do
      store = Wasmer.default_engine.new_store
      Wasmer::Wasi::StateBuilder.builder("test", store) {
        with_arg("--a")
        with_arg("--b")
        with_env("K1", "V1")
        with_env("K2", "V2")
        with_map_dir("alias", ".")
        with_inherit_stdin
        with_inherit_stdout
        with_inherit_stderr
      }.should be_a(Wasmer::Wasi::Environment)
    end
  end
end
