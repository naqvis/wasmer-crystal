<div align="center">
  <a href="https://wasmer.io" target="_blank" rel="noopener noreferrer">
    <img width="300" src="https://raw.githubusercontent.com/wasmerio/wasmer/master/assets/logo.png" alt="Wasmer logo">
  </a>
  
  <h1>Wasmer Crystal</h1>
  
  <p>
    <a href="https://github.com/naqvis/wasmer-crystal/actions/workflows/ci.yml">
      <img src="https://github.com/naqvis/wasmer-crystal/actions/workflows/ci.yml/badge.svg" alt="Build Status">
    </a>
    <a href="https://github.com/naqvis/wasmer-crystal/blob/main/LICENSE">
      <img src="https://img.shields.io/github/license/naqvis/wasmer-crystal.svg" alt="License">
    </a>
    <a href="https://naqvis.github.io/wasmer-crystal/index.html">
      <img src="https://img.shields.io/badge/documentation-API-f06" alt="API Documentation">
    </a> 
  </p>

  <h3>
    <a href="https://wasmer.io/">Wasmer Website</a>
    <span> • </span>
    <a href="https://naqvis.github.io/wasmer-crystal/index.html">Shard Docs</a>
    <span> • </span>
    <a href="https://slack.wasmer.io/">Wasmer Slack Channel</a>
  </h3>
</div>

<hr/>

A complete and mature WebAssembly runtime for Crystal based on
[Wasmer](https://github.com/wasmerio/wasmer).

**Features**

  * **Easy to use**: The `wasmer` API mimics the standard WebAssembly API,
  * **Fast**: `wasmer` executes the WebAssembly modules as fast as
    possible, close to **native speed**,
  * **Safe**: All calls to WebAssembly will be fast, but more
    importantly, completely safe and sandboxed.

**Documentation**: [browse the detailed API
documentation]( https://naqvis.github.io/wasmer-crystal/)


**Examples** as tutorials: [browser the `examples/`
directory](https://github.com/naqvis/wasmer-crystal/tree/main/examples),
it's the best place for a complete introduction!

<br/>

> **_NOTE:_** 
Shard assumes you have [wasmer](https://github.com/wasmerio/wasmer) runtime installed and environment variable **`WASMER_DIR`** is setup properly, or you will encounter issues during compilation.

<br/>


# Quick Introduction

The `wasmer` package brings the required API to execute WebAssembly
modules. In a nutshell, `wasmer` compiles the WebAssembly module into
compiled code, and then executes it. `wasmer` is designed to work in
various environments and platforms. To achieve this, Wasmer (the
original runtime) provides multiple engines and multiple
compilers.

Succinctly, an _engine_ is responsible to drive the _compilation_ (by
using a _compiler_) and the _execution_ of a WebAssembly
module. Wasmer comes with many engines and compilers.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies
     wasmer:
       github: naqvis/wasmer-crystal
   ```

2. Run `shards install`

And you're ready to get fun!

## Usage

```crystal
require "wasmer"
```

## Example

We highly recommend to read the
[`examples/`](https://github.com/naqvis/wasmer-crystal/tree/main/examples)
directory, which contains a sequence of examples/tutorials. It's the
best place to learn by reading examples.

But for the most eager of you, and we know you're numerous you
mischievous, there is a quick toy program in
`examples/appendices/simple.rs`, written in Rust:

```rust
#[no_mangle]
pub extern fn sum(x: i32, y: i32) -> i32 {
    x + y
}
```

After compilation to WebAssembly, the
[`examples/appendices/simple.wasm`](https://github.com/naqvis/wasmer-crystal/tree/main/examples/appendices/simple.wasm)
binary file is generated.

Then, we can execute it in Crystal:

```crystal
require "wasmer"

# Let's define the engine, that holds the compiler.
engine = Wasmer::Engine.new 

# Let's define the store, that holds the engine, that holds the compiler.
store = Wasmer::Store.new(engine)

# Above two lines are same as invoking below helper method
# store = Wasmer.default_engine.new_store

# Let's compile the module to be able to execute it!
module_ = Wasmer::Module.new store, File.read("#{__DIR__}/simple.wasm")

# Now the module is compiled, we can instantiate it.
instance = Wasmer::Instance.new module_

# get the exported `sum` function
# function methods returns nil if it can't find the requested function. we know its there, so let's add `not_nil!` 
sum = instance.function("sum").not_nil!

# Call the exported `sum` function with Crystal standard values. The WebAssembly
# types are inferred and values are casted automatically.
result = sum.call(5, 37)

puts result # => 42
```

And then, finally, enjoy by running:

```sh
$ crystal examples/appendices/simple.cr
```

## Development
To run all tests

`crystal spec`

## What is WebAssembly?

Quoting [the WebAssembly site](https://webassembly.org/):

> WebAssembly (abbreviated Wasm) is a binary instruction format for a
> stack-based virtual machine. Wasm is designed as a portable target
> for compilation of high-level languages like C/C++/Rust, enabling
> deployment on the web for client and server applications.

About speed:

> WebAssembly aims to execute at native speed by taking advantage of
> [common hardware
> capabilities](https://webassembly.org/docs/portability/#assumptions-for-efficient-execution)
> available on a wide range of platforms.

About safety:

> WebAssembly describes a memory-safe, sandboxed [execution
> environment](https://webassembly.org/docs/semantics/#linear-memory) […].

## License

The entire project is under the MIT License. Please read [the `LICENSE` file][license].

## Contributing

1. Fork it (<https://github.com/naqvis/wasmer-crystal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ali Naqvi](https://github.com/naqvis) - creator and maintainer

[license]: https://github.com/naqvis/wasmer-crystal/blob/main/LICENSE