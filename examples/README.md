# Examples

This directory contains a collection of examples. This isn't an
exhaustive collection though, if one is missing, please ask, or contribute. PRs are welcome

The examples are written in a difficulty/discovery order. Concepts
that are explained in an example is not necessarily re-explained in a
next example.

## Basics

1. [**Instantiating a module**][instance], explains the basics of
   using Wasmer and how to create an instance out of a WebAssembly
   module.
   
   _Keywords_: instance, module.
   
   <details>
   <summary><em>Execute the example</em></summary>

   ```shell
   $ crystal examples/instance.cr
   ```

   </details>

## Engines

2. [**JIT engine**][engine-jit], explains what an engine is, what the
   JIT engine is, and how to set it up. The example completes itself
   with the compilation of the Wasm module, its instantiation, and
   finally, by calling an exported function.
   
   _Keywords_: JIT, engine, in-memory, executable code.
   
   <details>
   <summary><em>Execute the example</em></summary>

   ```shell
   $ crystal examples/engine_jit.cr
   ```

   </details>

## Compilers

3. [**Cranelift compiler**][compiler-cranelift], explains how to use
   the `wasmer-compiler-cranelift` compiler.
   
   _Keywords_: compiler, cranelift.

   <details>
   <summary><em>Execute the example</em></summary>

   ```shell
   $ crystal examples/compiler_cranelift.cr
   ```

   </details>

## Exports
   
4. [**Exported function**][exported-function], explains how to get and
   how to call an exported function.
   
   _Keywords_: export, function.

   <details>
   <summary><em>Execute the example</em></summary>

   ```shell
   $ crystal examples/exports_function.cr
   ```

   </details>

5. [**Exported memory**][exported-memory], explains how to read from
   and write into an exported memory.

   _Keywords_: export, function.

   <details>
   <summary><em>Execute the example</em></summary>

   ```shell
   $ crystal examples/exports_memory.cr
   ```

   </details>

6. [**Exported global**][exported-global], explains how to work with
   exported globals: get/set their value, have information about
   their type.

   _Keywords_: export, global.

   <details>
   <summary><em>Execute the example</em></summary>

   ```shell
   $ crystal examples/exports_global.cr
   ```

   </details>

## Imports

7. [**Imported function**][imported-function], aka _host function_,
   explains how to use a Crystal function inside a WebAssembly module.

   _Keywords_: import, function.

   <details>
   <summary><em>Execute the example</em></summary>

   ```shell
   $ crystal examples/imports_function.cr
   ```

   </details>

8. [**Early exit**][imported-function-early-exit], explains how to
   early exit from a host function, and how to catch the error later.

   _Keywords_: import, function, error.

   <details>
   <summary><em>Execute the example</em></summary>

   ```shell
   $ crystal examples/imports_function_early_exit.cr
   ```

   </details>

## Integrations

9. [**WASI**][wasi], explains how to use the [WebAssembly System
   Interface][WASI] (WASI).
  
   _Keywords_: wasi, system, interface

   <details>
   <summary><em>Execute the example</em></summary>

   ```shell
   $ crystal examples/wasi.cr
   ```

   </details>

[instance]: ./instance.cr
[engine-jit]: ./engine_jit.cr
[compiler-cranelift]: ./compiler_cranelift.cr
[exported-function]: ./exports_function.cr
[exported-memory]: ./exports_memory.cr
[exported-global]: ./exports_global.cr
[imported-function]: ./imports_function.cr
[imported-function-early-exit]: ./imports_function_early_exit.cr
[wasi]: ./wasi.cr
