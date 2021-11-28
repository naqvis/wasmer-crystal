require "../prelude"

# Let's define the engine, that holds the compiler.
engine = Wasmer::Engine.new

# Let's define the store, that holds the engine, that holds the compiler.
store = Wasmer::Store.new(engine)

# Above two lines are same as invoking below helper method
# store = Wasmer.default_engine.new_store

# Let's compile the module to be able to execute it!
module_ = Wasmer::Module.new(store, File.read("#{__DIR__}/greet.wasm"))

# Now the module is compiled, we can instantiate it.
instance = Wasmer::Instance.new(module_)

# Set the subject to greet
subject = "Wasmer 💎"
bytesize = subject.bytesize

# Allocate memory for the subject, and get a pointer to it
in_ptr = instance.function("allocate").not_nil!.call(bytesize)
# Write the subject into memory
memory = instance.memory("memory").not_nil!
write_ptr = memory.view(in_ptr.as(Int32))
write_ptr.copy_from(subject.to_unsafe, bytesize)

# Run the greet function.
out_ptr = instance.function("greet").not_nil!.call in_ptr.as(Int32)
output = memory.view(out_ptr.as(Int32))
size =
  output.each_with_index do |v, i|
    break i if v == '\0'.ord
  end

output = String.new(output[...size])
puts output

# Deallocate the subject, and the output.
dealloc = instance.function("deallocate").not_nil!
dealloc.call(in_ptr.as(Int32), bytesize)
dealloc.call(out_ptr.as(Int32), size || 0)
