require "mutex"
require "./lib"
require "./value"
require "./extern"
require "./engine"
require "./store"
require "./trap"

module Wasmer
  # FunctionType classifies the signature of functions, mapping a
  # vector of parameters to a vector of results. They are also used to
  # classify the inputs and outputs of instructions.
  #
  # See also
  #
  # Specification: https://webassembly.github.io/spec/core/syntax/types.html#function-types
  class FunctionType
    include WithExternType

    # Instantiates a new FunctionType from two `ValueType` arrays: parameters and the results
    # ```
    # params = Wasmer.value_types
    # results = Wasmer.value_types(Wasmer::I32)
    # function_type = Wasmer::FunctionType.new(params, results)
    # ```
    def initialize(params : Array(ValueType), results : Array(ValueType))
      params_v2c = Wasmer.valuetypes_to_c(params)
      results_v2c = Wasmer.valuetypes_to_c(results)

      @ptr = LibWasmer.wasm_functype_new(pointerof(params_v2c),
        pointerof(results_v2c))
    end

    def self.new
      no_p = [] of ValueType
      new(no_p, no_p)
    end

    protected def initialize(@ptr : LibWasmer::WasmFunctypeT)
    end

    # Returns the parameters definitions from the FunctionType as
    # a `ValueType` array
    def params : Array(ValueType)
      Wasmer.c_to_valuetypes(LibWasmer.wasm_functype_params(self).value)
    end

    # Returns the results definitions from the FunctionType as
    # a `ValueType` array
    def results : Array(ValueType)
      Wasmer.c_to_valuetypes(LibWasmer.wasm_functype_results(self).value)
    end

    def to_externtype : ExternType
      val = LibWasmer.wasm_functype_as_externtype_const(self)
      ExternType.new(val)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end

  alias Types = Int32 | Int64 | Float32 | Float64
  alias FuncProc = Array(Value) -> Array(Value)
  alias FuncEnvProc = UserEnv, Array(Value) -> Array(Value)
  alias HostFunction = FuncProc | FuncEnvProc
  alias UserEnv = Pointer(Void)

  # Function is a WebAssembly function instance
  #
  # A function instance is the runtime representation of a function.
  # It effectively is a closure of the original function (defined in either
  # the host or the WebAssembly module) over the runtime `Instance` of its
  # originating `Module`.
  #
  # The module instance is used to resolve references to other definitions
  # during execution of the function.
  #
  # Spec: <https://webassembly.github.io/spec/core/exec/runtime.html#function-instances>
  class Function
    include WithExtern

    @@func_store = HostFuncs.new
    @lazy_native : Native? = nil

    # Instantiates a new `Function` in the given `Store`.
    # It takes three arguments, the `Store`, the `FunctionType` and the
    # definition for the Function.
    #
    # The function definition must be a native Crystal function with a `Value` array
    # as its single argument. The function must return a `Value` array or
    # raise an exception for abnormal conditions.
    #
    # Note: Even if the function does not take any argument (or use any argument)
    # it must receive a `Value` array as its single argument. At runtime, this array will be empty.
    # The same applies to the result.
    def self.new(store : Store, type : FunctionType, &func : FuncProc)
      new(store, type, UserEnv.null, func)
    end

    # Instantiates a new `Function` in the given `Store`.
    # It takes four arguments, the `Store`, the `FunctionType`,
    # host environment and the definition for the Function.
    # environment can be anything. It is `Pointer(Void)`
    #
    # The function definition must be a native Crystal function with a `Value` array
    # as its single argument. The function must return a `Value` array or
    # raise an exception for abnormal conditions.
    #
    # Note: Even if the function does not take any argument (or use any argument)
    # it must receive a `Value` array as its single argument. At runtime, this array will be empty.
    # The same applies to the result.
    def self.new(store : Store, type : FunctionType, env : UserEnv, &func : FuncEnvProc)
      new(store, type, env, func)
    end

    private def initialize(store : Store, type : FunctionType, env : UserEnv, func : HostFunction)
      host = HostFunc.new(store, func, env)
      @env = FuncEnv.new(@@func_store.store(host))
      @ptr = LibWasmer.wasm_func_new_with_env(store, type,
        ->Function.trampoline, Box(FuncEnv).box(@env), ->Function.env_finalizer)
    end

    # :nodoc:
    protected def initialize(@ptr : LibWasmer::WasmFuncT, @env : FuncEnv?)
    end

    def to_extern : Extern
      p = LibWasmer.wasm_func_as_extern(self)
      Extern.new(p)
    end

    def type : FunctionType
      p = LibWasmer.wasm_func_type(self)
      FunctionType.new(p)
    end

    # Returns the number of arguments the Function expects as per its definition
    def param_arity : UInt32
      LibWasmer.wasm_func_param_arity(self).to_u32
    end

    # Returns the number of results the function will return
    def result_arity : UInt32
      LibWasmer.wasm_func_result_arity(self).to_u32
    end

    # call the Function and return its result as native Crystal values.
    def call(*params : Number)
      self.native.call(*params)
    end

    # turn the `Function` into a native Crystal function that can be called.
    def native : Native
      @lazy_native ||= Native.new(self)
    end

    # :nodoc:
    protected def self.trampoline(penv : Void*, pargs : LibWasmer::WasmValVecT*,
                                  pres : LibWasmer::WasmValVecT*) : LibWasmer::WasmTrapT
      env = Box(FuncEnv).unbox(penv)
      host_func = @@func_store[env.store_index]
      begin
        args = Wasmer.c_to_valuelist(pargs.value)
        func = host_func.func
        results = if func.arity == 1
                    func.as(FuncProc).call(args)
                  else
                    func.as(FuncEnvProc).call(host_func.env, args)
                  end
      rescue ex : Exception
        trap = Trap.new(host_func.store, ex.message || "")
        return trap.to_unsafe
      end
      res = Wasmer.values_to_c(results)
      pres.value = res
      Pointer(Int64).null
    end

    # :nodoc:
    protected def self.env_finalizer(val : Void*) : Nil
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end

    # :nodoc:
    def finalize
      if env = @env
        @@func_store.remove(env.store_index)
      end

      return if @ptr.null?
      LibWasmer.wasm_func_delete(@ptr)
    end

    private class HostFunc
      getter store : Store
      getter func : HostFunction # FuncProc | FuncEnvProc
      getter env : UserEnv

      def initialize(@store, @func, @env)
      end
    end

    private class FuncEnv
      getter store_index : Int32

      def initialize(@store_index)
      end
    end

    private class HostFuncs
      def initialize
        @lock = Mutex.new
        @functions = Hash(Int32, HostFunc?).new
      end

      def [](index : Int32) : HostFunc
        @lock.synchronize {
          if h = @functions[index]?
            return h
          end
        }
        raise WasmerError.new("Host function '#{index}' does not exist")
      end

      def store(func : HostFunc) : Int32
        index = @functions.size
        @lock.synchronize {
          index = @functions.size
          @functions.each do |k, v|
            if v.nil?
              index = k
              break
            end
          end
          @functions[index] = func
        }
        index
      end

      def remove(index : Int32)
        @lock.synchronize {
          @functions[index] = nil
        }
      end
    end

    private class Native
      def initialize(@type : Function)
      end

      # :nodoc:
      def to_unsafe
        @type.to_unsafe
      end

      def call(*params)
        params.each do |v|
          raise "invalid type for arg : #{v}, type: #{typeof(v)}" unless v.is_a?(Number)
        end
        run(params.to_a)
      end

      def run(params : Array(Number))
        ty = @type.type
        exp_params = ty.params
        rcount = params.size
        ecount = exp_params.size
        diff = ecount - rcount
        raise WasmerError.new("Missing #{diff.abs} argument(s) when calling the function; expected #{ecount} arguments, received #{rcount}") if diff > 0
        raise WasmerError.new("Given #{diff.abs} extra argument(s) when calling the function; expected #{ecount} arguments, received #{rcount}") if diff < 0

        all_args = Array(LibWasmer::WasmValT).new(rcount)
        params.each_with_index do |p, i|
          all_args << Value.new(p, exp_params[i].kind).to_unsafe
        end
        LibWasmer.wasm_val_vec_new_uninitialized(out results, ty.results.size)
        args = LibWasmer::WasmValVecT.new
        begin
          LibWasmer.wasm_val_vec_new(pointerof(args),
            rcount, all_args.to_unsafe) if rcount > 0

          trap = LibWasmer.wasm_func_call(self, pointerof(args), pointerof(results))
          raise TrapException.new(Trap.new(trap)) unless trap.null?
          case results.size
          when 0 then nil
          when 1 then Value.new(results.data.value).unwrap
          else
            arr = Array(Types).new(results.size)
            first_ptr = results.data
            0.upto(results.size.to_i - 1) do |i|
              arr << Value.new(first_ptr[i]).unwrap
            end
            arr
          end
        ensure
          LibWasmer.wasm_val_vec_delete(pointerof(results))
          LibWasmer.wasm_val_vec_delete(pointerof(args))
        end
      end

      def run(params : Array(NoReturn))
        run([] of Int32)
      end

      def run(params)
        raise "Invalid argument type passed. #{typeof(params)}"
      end
    end
  end
end
