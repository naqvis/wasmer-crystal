require "./lib"
require "./store"

module Wasmer
  # Trap stores trace message with backtrace when an error happened.
  class Trap
    def initialize(store : Store, message : String)
      msg = LibWasmer::WasmMessageT.new
      msg.size = message.bytesize
      msg.data = message.to_unsafe
      @ptr = LibWasmer.wasm_trap_new(store, pointerof(msg))
    end

    # :nodoc:
    protected def initialize(@ptr : LibWasmer::WasmTrapT)
    end

    # Returns the message attached to the current `Trap`
    def message
      LibWasmer.wasm_trap_message(self, out msg)
      res = String.new(msg.data)[...msg.size]
      LibWasmer.wasm_byte_vec_delete(pointerof(msg))
      res
    end

    # Returns the top frame of WebAssembly stack responsible for this trap.
    def origin : Frame?
      frame = LibWasmer.wasm_trap_origin(self)
      return nil unless frame
      Frame.new(frame)
    end

    # Returns the trace of WebAssembly frames for this trap
    def trace : Trace
      Trace.new(self)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end

  # Frame represents a frame of a WebAssembly stack trace.
  class Frame
    # :nodoc:
    protected def initialize(@ptr : LibWasmer::WasmFrameT)
    end

    # Returns the function index in the original WebAssembly module that
    # this frame corresponds to
    def function_index
      LibWasmer.wasm_frame_func_index(self)
    end

    # Returns the byte offset from the beginning of the
    # function in the original WebAssembly file to the instruction this
    # frame points to
    def function_offset
      LibWasmer.wasm_frame_func_offset(self)
    end

    # Returns the byte offset from the beginning of the
    # original WebAssembly file to the instruction this frame points to.
    def module_offset
      LibWasmer.wasm_frame_module_offset(self)
    end

    # TODO: See https://github.com/wasmerio/wasmer/blob/6fbc903ea32774c830fd9ee86140d1406ac5d745/lib/c-api/src/wasm_c_api/types/frame.rs#L31-L34
    def instance
      raise "Not implemented by Wasmer"
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end

    # :nodoc:
    def finalize
      return if @ptr.null?
      LibWasmer.wasm_frame_delete(self)
    end
  end

  # Trace represents a WebAssembly trap
  class Trace
    getter frames : Array(Frame)

    # :nodoc:
    protected def initialize(trap : Trap)
      LibWasmer.wasm_trap_trace(trap, out @ptr)
      @frames = Array(Frame).new(@ptr.size)

      frame = @ptr.data
      0.upto(@ptr.size.to_i - 1) do |n|
        cfp = frame[n]
        @frames << Frame.new(cfp)
      end
    end

    # :nodoc:
    def to_unsafe
      pointerof(@ptr)
    end

    forward_missing_to @frames
  end
end
