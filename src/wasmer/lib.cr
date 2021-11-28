module Wasmer
  @[Link(ldflags: "-Wl,-rpath,`$WASMER_DIR/bin/wasmer config --libdir`")]
  @[Link(ldflags: "`$WASMER_DIR/bin/wasmer config --libs`")]
  lib LibWasmer
    WASMER_VERSION_MAJOR = 2
    WASMER_VERSION_MINOR = 0
    WASMER_VERSION_PATCH = 0

    alias IntPtr = LibC::Long*
    alias ByteT = LibC::Char
    alias WasmByteT = ByteT

    alias WasmMemorytypeT = IntPtr
    alias WasmExterntypeT = IntPtr
    alias WasmExternkindT = UInt8
    alias WasmImporttypeT = IntPtr
    alias WasmExporttypeT = IntPtr
    alias WasmRefT = IntPtr
    alias WasmFrameT = IntPtr
    alias WasmInstanceT = IntPtr
    alias WasmTrapT = IntPtr
    alias WasmMessageT = WasmNameT
    alias WasmForeignT = IntPtr
    alias WasmModuleT = IntPtr
    alias WasmSharedModuleT = IntPtr
    alias WasmFuncT = IntPtr
    alias WasmFuncCallbackT = (WasmValVecT*, WasmValVecT* -> WasmTrapT)
    alias WasmFuncCallbackWithEnvT = (Void*, WasmValVecT*, WasmValVecT* -> WasmTrapT)
    alias WasmerMeteringCostFunctionT = (WasmerParserOperatorT -> LibC::ULong)

    alias WasmGlobalT = IntPtr

    alias WasmNameT = WasmByteVecT
    alias WasmConfigT = IntPtr
    alias WasmEngineT = IntPtr
    alias WasmStoreT = IntPtr

    alias WasmTableT = IntPtr
    alias WasmTableSizeT = LibC::UInt
    alias WasmMemoryT = IntPtr
    alias WasmMemoryPagesT = LibC::UInt
    alias WasmExternT = IntPtr
    alias WasiConfigT = IntPtr
    alias WasiEnvT = IntPtr
    alias WasmerCpuFeaturesT = IntPtr
    alias WasmerFeaturesT = IntPtr
    alias WasmerMeteringT = IntPtr
    alias WasmerMiddlewareT = IntPtr
    alias WasmerNamedExternT = IntPtr
    alias WasmerTargetT = IntPtr
    alias WasmerTripleT = IntPtr

    struct WasmByteVecT
      size : LibC::SizeT
      data : WasmByteT*
    end

    fun wasm_byte_vec_new_empty(out : WasmByteVecT*)
    fun wasm_byte_vec_new_uninitialized(out : WasmByteVecT*, x1 : LibC::SizeT)
    fun wasm_byte_vec_new(out : WasmByteVecT*, x1 : LibC::SizeT, x2 : WasmByteT*)
    fun wasm_byte_vec_copy(out : WasmByteVecT*, x1 : WasmByteVecT*)
    fun wasm_byte_vec_delete(x0 : WasmByteVecT*)
    fun wasm_name_new_from_string(out : WasmNameT*, s : LibC::Char*)

    fun wasm_name_new_from_string_nt(out : WasmNameT*, s : LibC::Char*)
    fun wasm_config_delete(x0 : WasmConfigT)

    fun wasm_config_new : WasmConfigT

    fun wasm_engine_delete(x0 : WasmEngineT)
    fun wasm_engine_new : WasmEngineT
    fun wasm_engine_new_with_config(x0 : WasmConfigT) : WasmEngineT
    fun wasm_store_delete(x0 : WasmStoreT)

    fun wasm_store_new(x0 : WasmEngineT) : WasmStoreT

    struct WasmLimitsT
      min : LibC::UInt
      max : LibC::UInt
    end

    alias WasmValtypeT = IntPtr
    alias WasmValkindT = UInt8
    alias WasmFunctypeT = IntPtr
    alias WasmGlobaltypeT = IntPtr
    alias WasmMutabilityT = UInt8
    alias WasmTabletypeT = IntPtr

    fun wasm_valtype_delete(x0 : WasmValtypeT)

    struct WasmValtypeVecT
      size : LibC::SizeT
      data : WasmValtypeT*
    end

    fun wasm_valtype_vec_new_empty(out : WasmValtypeVecT*)
    fun wasm_valtype_vec_new_uninitialized(out : WasmValtypeVecT*, x1 : LibC::SizeT)
    fun wasm_valtype_vec_new(out : WasmValtypeVecT*, x1 : LibC::SizeT, x2 : WasmValtypeT*)
    fun wasm_valtype_vec_copy(out : WasmValtypeVecT*, x1 : WasmValtypeVecT*)
    fun wasm_valtype_vec_delete(x0 : WasmValtypeVecT*)
    fun wasm_valtype_copy(x0 : WasmValtypeT) : WasmValtypeT
    fun wasm_valtype_new(x0 : WasmValkindT) : WasmValtypeT

    fun wasm_valtype_kind(x0 : WasmValtypeT) : WasmValkindT
    fun wasm_valkind_is_num(k : WasmValkindT) : Bool
    fun wasm_valkind_is_ref(k : WasmValkindT) : Bool
    fun wasm_valtype_is_num(t : WasmValtypeT) : Bool
    fun wasm_valtype_is_ref(t : WasmValtypeT) : Bool
    fun wasm_functype_delete(x0 : WasmFunctypeT)

    struct WasmFunctypeVecT
      size : LibC::SizeT
      data : WasmFunctypeT
    end

    fun wasm_functype_vec_new_empty(out : WasmFunctypeVecT*)
    fun wasm_functype_vec_new_uninitialized(out : WasmFunctypeVecT*, x1 : LibC::SizeT)
    fun wasm_functype_vec_new(out : WasmFunctypeVecT*, x1 : LibC::SizeT, x2 : WasmFunctypeT*)
    fun wasm_functype_vec_copy(out : WasmFunctypeVecT*, x1 : WasmFunctypeVecT*)
    fun wasm_functype_vec_delete(x0 : WasmFunctypeVecT*)
    fun wasm_functype_copy(x0 : WasmFunctypeT) : WasmFunctypeT
    fun wasm_functype_new(params : WasmValtypeVecT*, results : WasmValtypeVecT*) : WasmFunctypeT
    fun wasm_functype_params(x0 : WasmFunctypeT) : WasmValtypeVecT*
    fun wasm_functype_results(x0 : WasmFunctypeT) : WasmValtypeVecT*
    fun wasm_globaltype_delete(x0 : WasmGlobaltypeT)

    struct WasmGlobaltypeVecT
      size : LibC::SizeT
      data : WasmGlobaltypeT*
    end

    fun wasm_globaltype_vec_new_empty(out : WasmGlobaltypeVecT*)
    fun wasm_globaltype_vec_new_uninitialized(out : WasmGlobaltypeVecT*, x1 : LibC::SizeT)
    fun wasm_globaltype_vec_new(out : WasmGlobaltypeVecT*, x1 : LibC::SizeT, x2 : WasmGlobaltypeT*)
    fun wasm_globaltype_vec_copy(out : WasmGlobaltypeVecT*, x1 : WasmGlobaltypeVecT*)
    fun wasm_globaltype_vec_delete(x0 : WasmGlobaltypeVecT*)
    fun wasm_globaltype_copy(x0 : WasmGlobaltypeT) : WasmGlobaltypeT
    fun wasm_globaltype_new(x0 : WasmValtypeT, x1 : WasmMutabilityT) : WasmGlobaltypeT
    fun wasm_globaltype_content(x0 : WasmGlobaltypeT) : WasmValtypeT
    fun wasm_globaltype_mutability(x0 : WasmGlobaltypeT) : WasmMutabilityT
    fun wasm_tabletype_delete(x0 : WasmTabletypeT)

    struct WasmTabletypeVecT
      size : LibC::SizeT
      data : WasmTabletypeT*
    end

    fun wasm_tabletype_vec_new_empty(out : WasmTabletypeVecT*)
    fun wasm_tabletype_vec_new_uninitialized(out : WasmTabletypeVecT*, x1 : LibC::SizeT)
    fun wasm_tabletype_vec_new(out : WasmTabletypeVecT*, x1 : LibC::SizeT, x2 : WasmTabletypeT*)
    fun wasm_tabletype_vec_copy(out : WasmTabletypeVecT*, x1 : WasmTabletypeVecT*)
    fun wasm_tabletype_vec_delete(x0 : WasmTabletypeVecT*)
    fun wasm_tabletype_copy(x0 : WasmTabletypeT) : WasmTabletypeT
    fun wasm_tabletype_new(x0 : WasmValtypeT, x1 : WasmLimitsT*) : WasmTabletypeT
    fun wasm_tabletype_element(x0 : WasmTabletypeT) : WasmValtypeT
    fun wasm_tabletype_limits(x0 : WasmTabletypeT) : WasmLimitsT*

    fun wasm_memorytype_delete(x0 : WasmMemorytypeT)

    struct WasmMemorytypeVecT
      size : LibC::SizeT
      data : WasmMemorytypeT*
    end

    fun wasm_memorytype_vec_new_empty(out : WasmMemorytypeVecT*)
    fun wasm_memorytype_vec_new_uninitialized(out : WasmMemorytypeVecT*, x1 : LibC::SizeT)
    fun wasm_memorytype_vec_new(out : WasmMemorytypeVecT*, x1 : LibC::SizeT, x2 : WasmMemorytypeT*)
    fun wasm_memorytype_vec_copy(out : WasmMemorytypeVecT*, x1 : WasmMemorytypeVecT*)
    fun wasm_memorytype_vec_delete(x0 : WasmMemorytypeVecT*)
    fun wasm_memorytype_copy(x0 : WasmMemorytypeT) : WasmMemorytypeT
    fun wasm_memorytype_new(x0 : WasmLimitsT*) : WasmMemorytypeT
    fun wasm_memorytype_limits(x0 : WasmMemorytypeT) : WasmLimitsT*

    fun wasm_externtype_delete(x0 : WasmExterntypeT)

    struct WasmExterntypeVecT
      size : LibC::SizeT
      data : WasmExterntypeT*
    end

    fun wasm_externtype_vec_new_empty(out : WasmExterntypeVecT*)
    fun wasm_externtype_vec_new_uninitialized(out : WasmExterntypeVecT*, x1 : LibC::SizeT)
    fun wasm_externtype_vec_new(out : WasmExterntypeVecT*, x1 : LibC::SizeT, x2 : WasmExterntypeT*)
    fun wasm_externtype_vec_copy(out : WasmExterntypeVecT*, x1 : WasmExterntypeVecT*)
    fun wasm_externtype_vec_delete(x0 : WasmExterntypeVecT*)
    fun wasm_externtype_copy(x0 : WasmExterntypeT) : WasmExterntypeT
    fun wasm_externtype_kind(x0 : WasmExterntypeT) : WasmExternkindT

    fun wasm_functype_as_externtype(x0 : WasmFunctypeT) : WasmExterntypeT
    fun wasm_globaltype_as_externtype(x0 : WasmGlobaltypeT) : WasmExterntypeT
    fun wasm_tabletype_as_externtype(x0 : WasmTabletypeT) : WasmExterntypeT
    fun wasm_memorytype_as_externtype(x0 : WasmMemorytypeT) : WasmExterntypeT
    fun wasm_externtype_as_functype(x0 : WasmExterntypeT) : WasmFunctypeT
    fun wasm_externtype_as_globaltype(x0 : WasmExterntypeT) : WasmGlobaltypeT
    fun wasm_externtype_as_tabletype(x0 : WasmExterntypeT) : WasmTabletypeT
    fun wasm_externtype_as_memorytype(x0 : WasmExterntypeT) : WasmMemorytypeT
    fun wasm_functype_as_externtype_const(x0 : WasmFunctypeT) : WasmExterntypeT
    fun wasm_globaltype_as_externtype_const(x0 : WasmGlobaltypeT) : WasmExterntypeT
    fun wasm_tabletype_as_externtype_const(x0 : WasmTabletypeT) : WasmExterntypeT
    fun wasm_memorytype_as_externtype_const(x0 : WasmMemorytypeT) : WasmExterntypeT
    fun wasm_externtype_as_functype_const(x0 : WasmExterntypeT) : WasmFunctypeT
    fun wasm_externtype_as_globaltype_const(x0 : WasmExterntypeT) : WasmGlobaltypeT
    fun wasm_externtype_as_tabletype_const(x0 : WasmExterntypeT) : WasmTabletypeT
    fun wasm_externtype_as_memorytype_const(x0 : WasmExterntypeT) : WasmMemorytypeT

    fun wasm_importtype_delete(x0 : WasmImporttypeT)

    struct WasmImporttypeVecT
      size : LibC::SizeT
      data : WasmImporttypeT*
    end

    fun wasm_importtype_vec_new_empty(out : WasmImporttypeVecT*)
    fun wasm_importtype_vec_new_uninitialized(out : WasmImporttypeVecT*, x1 : LibC::SizeT)
    fun wasm_importtype_vec_new(out : WasmImporttypeVecT*, x1 : LibC::SizeT, x2 : WasmImporttypeT*)
    fun wasm_importtype_vec_copy(out : WasmImporttypeVecT*, x1 : WasmImporttypeVecT*)
    fun wasm_importtype_vec_delete(x0 : WasmImporttypeVecT*)
    fun wasm_importtype_copy(x0 : WasmImporttypeT) : WasmImporttypeT
    fun wasm_importtype_new(module : WasmNameT*, name : WasmNameT*, x2 : WasmExterntypeT) : WasmImporttypeT
    fun wasm_importtype_module(x0 : WasmImporttypeT) : WasmNameT*
    fun wasm_importtype_name(x0 : WasmImporttypeT) : WasmNameT*
    fun wasm_importtype_type(x0 : WasmImporttypeT) : WasmExterntypeT

    fun wasm_exporttype_delete(x0 : WasmExporttypeT)

    struct WasmExporttypeVecT
      size : LibC::SizeT
      data : WasmExporttypeT*
    end

    fun wasm_exporttype_vec_new_empty(out : WasmExporttypeVecT*)
    fun wasm_exporttype_vec_new_uninitialized(out : WasmExporttypeVecT*, x1 : LibC::SizeT)
    fun wasm_exporttype_vec_new(out : WasmExporttypeVecT*, x1 : LibC::SizeT, x2 : WasmExporttypeT*)
    fun wasm_exporttype_vec_copy(out : WasmExporttypeVecT*, x1 : WasmExporttypeVecT*)
    fun wasm_exporttype_vec_delete(x0 : WasmExporttypeVecT*)
    fun wasm_exporttype_copy(x0 : WasmExporttypeT) : WasmExporttypeT
    fun wasm_exporttype_new(x0 : WasmNameT*, x1 : WasmExterntypeT) : WasmExporttypeT
    fun wasm_exporttype_name(x0 : WasmExporttypeT) : WasmNameT*
    fun wasm_exporttype_type(x0 : WasmExporttypeT) : WasmExterntypeT

    struct WasmValT
      kind : WasmValkindT
      of : WasmValTOf
    end

    union WasmValTOf
      i32 : LibC::Int
      i64 : LibC::Long
      f32 : LibC::Float
      f64 : LibC::Double
      ref : WasmRefT
    end

    fun wasm_val_delete(v : WasmValT*)
    fun wasm_val_copy(out : WasmValT*, x1 : WasmValT*)

    struct WasmValVecT
      size : LibC::SizeT
      data : WasmValT*
    end

    fun wasm_val_vec_new_empty(out : WasmValVecT*)
    fun wasm_val_vec_new_uninitialized(out : WasmValVecT*, x1 : LibC::SizeT)
    fun wasm_val_vec_new(out : WasmValVecT*, x1 : LibC::SizeT, x2 : WasmValT*)
    fun wasm_val_vec_copy(out : WasmValVecT*, x1 : WasmValVecT*)
    fun wasm_val_vec_delete(x0 : WasmValVecT*)
    fun wasm_ref_delete(x0 : WasmRefT)
    fun wasm_ref_copy(x0 : WasmRefT) : WasmRefT
    fun wasm_ref_same(x0 : WasmRefT, x1 : WasmRefT) : Bool
    fun wasm_ref_get_host_info(x0 : WasmRefT) : Void*
    fun wasm_ref_set_host_info(x0 : WasmRefT, x1 : Void*)
    fun wasm_ref_set_host_info_with_finalizer(x0 : WasmRefT, x1 : Void*, x2 : (Void* -> Void))

    fun wasm_frame_delete(x0 : WasmFrameT)

    struct WasmFrameVecT
      size : LibC::SizeT
      data : WasmFrameT*
    end

    fun wasm_frame_vec_new_empty(out : WasmFrameVecT*)
    fun wasm_frame_vec_new_uninitialized(out : WasmFrameVecT*, x1 : LibC::SizeT)
    fun wasm_frame_vec_new(out : WasmFrameVecT*, x1 : LibC::SizeT, x2 : WasmFrameT)
    fun wasm_frame_vec_copy(out : WasmFrameVecT*, x1 : WasmFrameVecT*)
    fun wasm_frame_vec_delete(x0 : WasmFrameVecT*)
    fun wasm_frame_copy(x0 : WasmFrameT) : WasmFrameT

    fun wasm_frame_instance(x0 : WasmFrameT) : WasmInstanceT
    fun wasm_frame_func_index(x0 : WasmFrameT) : LibC::UInt
    fun wasm_frame_func_offset(x0 : WasmFrameT) : LibC::SizeT
    fun wasm_frame_module_offset(x0 : WasmFrameT) : LibC::SizeT

    fun wasm_trap_delete(x0 : WasmTrapT)
    fun wasm_trap_copy(x0 : WasmTrapT) : WasmTrapT
    fun wasm_trap_same(x0 : WasmTrapT, x1 : WasmTrapT) : Bool
    fun wasm_trap_get_host_info(x0 : WasmTrapT) : Void*
    fun wasm_trap_set_host_info(x0 : WasmTrapT, x1 : Void*)
    fun wasm_trap_set_host_info_with_finalizer(x0 : WasmTrapT, x1 : Void*, x2 : (Void* -> Void))
    fun wasm_trap_as_ref(x0 : WasmTrapT) : WasmRefT
    fun wasm_ref_as_trap(x0 : WasmRefT) : WasmTrapT
    fun wasm_trap_as_ref_const(x0 : WasmTrapT) : WasmRefT
    fun wasm_ref_as_trap_const(x0 : WasmRefT) : WasmTrapT
    fun wasm_trap_new(store : WasmStoreT, x1 : WasmMessageT*) : WasmTrapT

    fun wasm_trap_message(x0 : WasmTrapT, out : WasmMessageT*)
    fun wasm_trap_origin(x0 : WasmTrapT) : WasmFrameT
    fun wasm_trap_trace(x0 : WasmTrapT, out : WasmFrameVecT*)
    fun wasm_foreign_delete(x0 : WasmForeignT)
    fun wasm_foreign_copy(x0 : WasmForeignT) : WasmForeignT
    fun wasm_foreign_same(x0 : WasmForeignT, x1 : WasmForeignT) : Bool
    fun wasm_foreign_get_host_info(x0 : WasmForeignT) : Void*
    fun wasm_foreign_set_host_info(x0 : WasmForeignT, x1 : Void*)
    fun wasm_foreign_set_host_info_with_finalizer(x0 : WasmForeignT, x1 : Void*, x2 : (Void* -> Void))
    fun wasm_foreign_as_ref(x0 : WasmForeignT) : WasmRefT
    fun wasm_ref_as_foreign(x0 : WasmRefT) : WasmForeignT
    fun wasm_foreign_as_ref_const(x0 : WasmForeignT) : WasmRefT
    fun wasm_ref_as_foreign_const(x0 : WasmRefT) : WasmForeignT
    fun wasm_foreign_new(x0 : WasmStoreT) : WasmForeignT

    fun wasm_module_delete(x0 : WasmModuleT)
    fun wasm_module_copy(x0 : WasmModuleT) : WasmModuleT
    fun wasm_module_same(x0 : WasmModuleT, x1 : WasmModuleT) : Bool
    fun wasm_module_get_host_info(x0 : WasmModuleT) : Void*
    fun wasm_module_set_host_info(x0 : WasmModuleT, x1 : Void*)
    fun wasm_module_set_host_info_with_finalizer(x0 : WasmModuleT, x1 : Void*, x2 : (Void* -> Void))
    fun wasm_module_as_ref(x0 : WasmModuleT) : WasmRefT
    fun wasm_ref_as_module(x0 : WasmRefT) : WasmModuleT
    fun wasm_module_as_ref_const(x0 : WasmModuleT) : WasmRefT
    fun wasm_ref_as_module_const(x0 : WasmRefT) : WasmModuleT

    fun wasm_shared_module_delete(x0 : WasmSharedModuleT)
    fun wasm_module_share(x0 : WasmModuleT) : WasmSharedModuleT
    fun wasm_module_obtain(x0 : WasmStoreT, x1 : WasmSharedModuleT) : WasmModuleT
    fun wasm_module_new(x0 : WasmStoreT, binary : WasmByteVecT*) : WasmModuleT
    fun wasm_module_validate(x0 : WasmStoreT, binary : WasmByteVecT*) : Bool
    fun wasm_module_imports(x0 : WasmModuleT, out : WasmImporttypeVecT*)
    fun wasm_module_exports(x0 : WasmModuleT, out : WasmExporttypeVecT*)
    fun wasm_module_serialize(x0 : WasmModuleT, out : WasmByteVecT*)
    fun wasm_module_deserialize(x0 : WasmStoreT, x1 : WasmByteVecT*) : WasmModuleT
    fun wasm_func_delete(x0 : WasmFuncT)
    fun wasm_func_copy(x0 : WasmFuncT) : WasmFuncT
    fun wasm_func_same(x0 : WasmFuncT, x1 : WasmFuncT) : Bool
    fun wasm_func_get_host_info(x0 : WasmFuncT) : Void*
    fun wasm_func_set_host_info(x0 : WasmFuncT, x1 : Void*)
    fun wasm_func_set_host_info_with_finalizer(x0 : WasmFuncT, x1 : Void*, x2 : (Void* -> Void))
    fun wasm_func_as_ref(x0 : WasmFuncT) : WasmRefT
    fun wasm_ref_as_func(x0 : WasmRefT) : WasmFuncT
    fun wasm_func_as_ref_const(x0 : WasmFuncT) : WasmRefT
    fun wasm_ref_as_func_const(x0 : WasmRefT) : WasmFuncT
    fun wasm_func_new(x0 : WasmStoreT, x1 : WasmFunctypeT, x2 : WasmFuncCallbackT) : WasmFuncT
    fun wasm_func_new_with_env(x0 : WasmStoreT, type : WasmFunctypeT, x2 : WasmFuncCallbackWithEnvT, env : Void*, finalizer : (Void* -> Void)) : WasmFuncT
    fun wasm_func_type(x0 : WasmFuncT) : WasmFunctypeT
    fun wasm_func_param_arity(x0 : WasmFuncT) : LibC::SizeT
    fun wasm_func_result_arity(x0 : WasmFuncT) : LibC::SizeT
    fun wasm_func_call(x0 : WasmFuncT, args : WasmValVecT*, results : WasmValVecT*) : WasmTrapT
    fun wasm_global_delete(x0 : WasmGlobalT)
    fun wasm_global_copy(x0 : WasmGlobalT) : WasmGlobalT
    fun wasm_global_same(x0 : WasmGlobalT, x1 : WasmGlobalT) : Bool
    fun wasm_global_get_host_info(x0 : WasmGlobalT) : Void*
    fun wasm_global_set_host_info(x0 : WasmGlobalT, x1 : Void*)
    fun wasm_global_set_host_info_with_finalizer(x0 : WasmGlobalT, x1 : Void*, x2 : (Void* -> Void))
    fun wasm_global_as_ref(x0 : WasmGlobalT) : WasmRefT
    fun wasm_ref_as_global(x0 : WasmRefT) : WasmGlobalT
    fun wasm_global_as_ref_const(x0 : WasmGlobalT) : WasmRefT
    fun wasm_ref_as_global_const(x0 : WasmRefT) : WasmGlobalT
    fun wasm_global_new(x0 : WasmStoreT, x1 : WasmGlobaltypeT, x2 : WasmValT*) : WasmGlobalT
    fun wasm_global_type(x0 : WasmGlobalT) : WasmGlobaltypeT
    fun wasm_global_get(x0 : WasmGlobalT, out : WasmValT*)
    fun wasm_global_set(x0 : WasmGlobalT, x1 : WasmValT*)

    fun wasm_table_delete(x0 : WasmTableT)
    fun wasm_table_copy(x0 : WasmTableT) : WasmTableT
    fun wasm_table_same(x0 : WasmTableT, x1 : WasmTableT) : Bool
    fun wasm_table_get_host_info(x0 : WasmTableT) : Void*
    fun wasm_table_set_host_info(x0 : WasmTableT, x1 : Void*)
    fun wasm_table_set_host_info_with_finalizer(x0 : WasmTableT, x1 : Void*, x2 : (Void* -> Void))
    fun wasm_table_as_ref(x0 : WasmTableT) : WasmRefT
    fun wasm_ref_as_table(x0 : WasmRefT) : WasmTableT
    fun wasm_table_as_ref_const(x0 : WasmTableT) : WasmRefT
    fun wasm_ref_as_table_const(x0 : WasmRefT) : WasmTableT
    fun wasm_table_new(x0 : WasmStoreT, x1 : WasmTabletypeT, init : WasmRefT) : WasmTableT
    fun wasm_table_type(x0 : WasmTableT) : WasmTabletypeT
    fun wasm_table_get(x0 : WasmTableT, index : WasmTableSizeT) : WasmRefT

    fun wasm_table_set(x0 : WasmTableT, index : WasmTableSizeT, x2 : WasmRefT) : Bool
    fun wasm_table_size(x0 : WasmTableT) : WasmTableSizeT
    fun wasm_table_grow(x0 : WasmTableT, delta : WasmTableSizeT, init : WasmRefT) : Bool

    fun wasm_memory_delete(x0 : WasmMemoryT)
    fun wasm_memory_copy(x0 : WasmMemoryT) : WasmMemoryT
    fun wasm_memory_same(x0 : WasmMemoryT, x1 : WasmMemoryT) : Bool
    fun wasm_memory_get_host_info(x0 : WasmMemoryT) : Void*
    fun wasm_memory_set_host_info(x0 : WasmMemoryT, x1 : Void*)
    fun wasm_memory_set_host_info_with_finalizer(x0 : WasmMemoryT, x1 : Void*, x2 : (Void* -> Void))
    fun wasm_memory_as_ref(x0 : WasmMemoryT) : WasmRefT
    fun wasm_ref_as_memory(x0 : WasmRefT) : WasmMemoryT
    fun wasm_memory_as_ref_const(x0 : WasmMemoryT) : WasmRefT
    fun wasm_ref_as_memory_const(x0 : WasmRefT) : WasmMemoryT
    fun wasm_memory_new(x0 : WasmStoreT, x1 : WasmMemorytypeT) : WasmMemoryT
    fun wasm_memory_type(x0 : WasmMemoryT) : WasmMemorytypeT
    fun wasm_memory_data(x0 : WasmMemoryT) : ByteT*
    fun wasm_memory_data_size(x0 : WasmMemoryT) : LibC::SizeT
    fun wasm_memory_size(x0 : WasmMemoryT) : WasmMemoryPagesT
    fun wasm_memory_grow(x0 : WasmMemoryT, delta : WasmMemoryPagesT) : Bool

    fun wasm_extern_delete(x0 : WasmExternT)
    fun wasm_extern_copy(x0 : WasmExternT) : WasmExternT
    fun wasm_extern_same(x0 : WasmExternT, x1 : WasmExternT) : Bool
    fun wasm_extern_get_host_info(x0 : WasmExternT) : Void*
    fun wasm_extern_set_host_info(x0 : WasmExternT, x1 : Void*)
    fun wasm_extern_set_host_info_with_finalizer(x0 : WasmExternT, x1 : Void*, x2 : (Void* -> Void))
    fun wasm_extern_as_ref(x0 : WasmExternT) : WasmRefT
    fun wasm_ref_as_extern(x0 : WasmRefT) : WasmExternT
    fun wasm_extern_as_ref_const(x0 : WasmExternT) : WasmRefT
    fun wasm_ref_as_extern_const(x0 : WasmRefT) : WasmExternT

    struct WasmExternVecT
      size : LibC::SizeT
      data : WasmExternT*
    end

    fun wasm_extern_vec_new_empty(out : WasmExternVecT*)
    fun wasm_extern_vec_new_uninitialized(out : WasmExternVecT*, x1 : LibC::SizeT)
    fun wasm_extern_vec_new(out : WasmExternVecT*, x1 : LibC::SizeT, x2 : WasmExternT*)
    fun wasm_extern_vec_copy(out : WasmExternVecT*, x1 : WasmExternVecT*)
    fun wasm_extern_vec_delete(x0 : WasmExternVecT*)
    fun wasm_extern_kind(x0 : WasmExternT) : WasmExternkindT
    fun wasm_extern_type(x0 : WasmExternT) : WasmExterntypeT
    fun wasm_func_as_extern(x0 : WasmFuncT) : WasmExternT
    fun wasm_global_as_extern(x0 : WasmGlobalT) : WasmExternT
    fun wasm_table_as_extern(x0 : WasmTableT) : WasmExternT
    fun wasm_memory_as_extern(x0 : WasmMemoryT) : WasmExternT
    fun wasm_extern_as_func(x0 : WasmExternT) : WasmFuncT
    fun wasm_extern_as_global(x0 : WasmExternT) : WasmGlobalT
    fun wasm_extern_as_table(x0 : WasmExternT) : WasmTableT
    fun wasm_extern_as_memory(x0 : WasmExternT) : WasmMemoryT
    fun wasm_func_as_extern_const(x0 : WasmFuncT) : WasmExternT
    fun wasm_global_as_extern_const(x0 : WasmGlobalT) : WasmExternT
    fun wasm_table_as_extern_const(x0 : WasmTableT) : WasmExternT
    fun wasm_memory_as_extern_const(x0 : WasmMemoryT) : WasmExternT
    fun wasm_extern_as_func_const(x0 : WasmExternT) : WasmFuncT
    fun wasm_extern_as_global_const(x0 : WasmExternT) : WasmGlobalT
    fun wasm_extern_as_table_const(x0 : WasmExternT) : WasmTableT
    fun wasm_extern_as_memory_const(x0 : WasmExternT) : WasmMemoryT
    fun wasm_instance_delete(x0 : WasmInstanceT)

    fun wasm_instance_copy(x0 : WasmInstanceT) : WasmInstanceT
    fun wasm_instance_same(x0 : WasmInstanceT, x1 : WasmInstanceT) : Bool
    fun wasm_instance_get_host_info(x0 : WasmInstanceT) : Void*
    fun wasm_instance_set_host_info(x0 : WasmInstanceT, x1 : Void*)
    fun wasm_instance_set_host_info_with_finalizer(x0 : WasmInstanceT, x1 : Void*, x2 : (Void* -> Void))
    fun wasm_instance_as_ref(x0 : WasmInstanceT) : WasmRefT
    fun wasm_ref_as_instance(x0 : WasmRefT) : WasmInstanceT
    fun wasm_instance_as_ref_const(x0 : WasmInstanceT) : WasmRefT
    fun wasm_ref_as_instance_const(x0 : WasmRefT) : WasmInstanceT
    fun wasm_instance_new(x0 : WasmStoreT, x1 : WasmModuleT, imports : WasmExternVecT*, x3 : WasmTrapT*) : WasmInstanceT
    fun wasm_instance_exports(x0 : WasmInstanceT, out : WasmExternVecT*)
    fun wasm_valtype_new_i32 : WasmValtypeT
    fun wasm_valtype_new_i64 : WasmValtypeT
    fun wasm_valtype_new_f32 : WasmValtypeT
    fun wasm_valtype_new_f64 : WasmValtypeT
    fun wasm_valtype_new_anyref : WasmValtypeT
    fun wasm_valtype_new_funcref : WasmValtypeT
    fun wasm_functype_new_0_0 : WasmFunctypeT
    fun wasm_functype_new_1_0(p : WasmValtypeT) : WasmFunctypeT
    fun wasm_functype_new_2_0(p1 : WasmValtypeT, p2 : WasmValtypeT) : WasmFunctypeT
    fun wasm_functype_new_3_0(p1 : WasmValtypeT, p2 : WasmValtypeT, p3 : WasmValtypeT) : WasmFunctypeT
    fun wasm_functype_new_0_1(r : WasmValtypeT) : WasmFunctypeT
    fun wasm_functype_new_1_1(p : WasmValtypeT, r : WasmValtypeT) : WasmFunctypeT
    fun wasm_functype_new_2_1(p1 : WasmValtypeT, p2 : WasmValtypeT, r : WasmValtypeT) : WasmFunctypeT
    fun wasm_functype_new_3_1(p1 : WasmValtypeT, p2 : WasmValtypeT, p3 : WasmValtypeT, r : WasmValtypeT) : WasmFunctypeT
    fun wasm_functype_new_0_2(r1 : WasmValtypeT, r2 : WasmValtypeT) : WasmFunctypeT
    fun wasm_functype_new_1_2(p : WasmValtypeT, r1 : WasmValtypeT, r2 : WasmValtypeT) : WasmFunctypeT
    fun wasm_functype_new_2_2(p1 : WasmValtypeT, p2 : WasmValtypeT, r1 : WasmValtypeT, r2 : WasmValtypeT) : WasmFunctypeT
    fun wasm_functype_new_3_2(p1 : WasmValtypeT, p2 : WasmValtypeT, p3 : WasmValtypeT, r1 : WasmValtypeT, r2 : WasmValtypeT) : WasmFunctypeT
    fun wasm_val_init_ptr(out : WasmValT*, p : Void*)
    fun wasm_val_ptr(val : WasmValT*) : Void*

    struct WasmerNamedExternVecT
      size : LibC::ULong
      data : WasmerNamedExternT*
    end

    fun wasi_config_arg(config : WasiConfigT, arg : LibC::Char*)
    fun wasi_config_capture_stderr(config : WasiConfigT)
    fun wasi_config_capture_stdout(config : WasiConfigT)
    fun wasi_config_env(config : WasiConfigT, key : LibC::Char*, value : LibC::Char*)
    fun wasi_config_inherit_stderr(config : WasiConfigT)
    fun wasi_config_inherit_stdin(config : WasiConfigT)
    fun wasi_config_inherit_stdout(config : WasiConfigT)
    fun wasi_config_mapdir(config : WasiConfigT, alias : LibC::Char*, dir : LibC::Char*) : Bool
    fun wasi_config_new(program_name : LibC::Char*) : WasiConfigT
    fun wasi_config_preopen_dir(config : WasiConfigT, dir : LibC::Char*) : Bool
    fun wasi_env_delete(_state : WasiEnvT)
    fun wasi_env_new(config : WasiConfigT) : WasiEnvT
    fun wasi_env_read_stderr(env : WasiEnvT, buffer : LibC::Char*, buffer_len : LibC::ULong) : LibC::Long

    fun wasi_env_read_stdout(env : WasiEnvT, buffer : LibC::Char*, buffer_len : LibC::ULong) : LibC::Long
    fun wasi_get_imports(store : WasmStoreT, module : WasmModuleT, wasi_env : WasiEnvT, imports : WasmExternVecT*) : Bool
    fun wasi_get_start_function(instance : WasmInstanceT) : WasmFuncT
    fun wasi_get_unordered_imports(store : WasmStoreT, module : WasmModuleT, wasi_env : WasiEnvT, imports : WasmerNamedExternVecT*) : Bool
    fun wasi_get_wasi_version(module : WasmModuleT) : WasiVersionT
    enum WasiVersionT
      InvalidVersion = -1
      Latest         =  0
      Snapshot0      =  1
      Snapshot1      =  2
    end
    fun wasm_config_canonicalize_nans(config : WasmConfigT, enable : Bool)
    fun wasm_config_push_middleware(config : WasmConfigT, middleware : WasmerMiddlewareT)
    fun wasm_config_set_compiler(config : WasmConfigT, compiler : WasmerCompilerT)
    enum WasmerCompilerT
      Cranelift  = 0
      Llvm       = 1
      Singlepass = 2
    end
    fun wasm_config_set_engine(config : WasmConfigT, engine : WasmerEngineT)
    enum WasmerEngineT
      Universal = 0
      Dylib     = 1
      Staticlib = 2
    end
    fun wasm_config_set_features(config : WasmConfigT, features : WasmerFeaturesT)
    fun wasm_config_set_target(config : WasmConfigT, target : WasmerTargetT)
    fun wasmer_cpu_features_add(cpu_features : WasmerCpuFeaturesT, feature : WasmNameT*) : Bool
    fun wasmer_cpu_features_delete(_cpu_features : WasmerCpuFeaturesT)
    fun wasmer_cpu_features_new : WasmerCpuFeaturesT
    fun wasmer_features_bulk_memory(features : WasmerFeaturesT, enable : Bool) : Bool
    fun wasmer_features_delete(_features : WasmerFeaturesT)
    fun wasmer_features_memory64(features : WasmerFeaturesT, enable : Bool) : Bool
    fun wasmer_features_module_linking(features : WasmerFeaturesT, enable : Bool) : Bool
    fun wasmer_features_multi_memory(features : WasmerFeaturesT, enable : Bool) : Bool
    fun wasmer_features_multi_value(features : WasmerFeaturesT, enable : Bool) : Bool
    fun wasmer_features_new : WasmerFeaturesT
    fun wasmer_features_reference_types(features : WasmerFeaturesT, enable : Bool) : Bool
    fun wasmer_features_simd(features : WasmerFeaturesT, enable : Bool) : Bool
    fun wasmer_features_tail_call(features : WasmerFeaturesT, enable : Bool) : Bool
    fun wasmer_features_threads(features : WasmerFeaturesT, enable : Bool) : Bool
    fun wasmer_is_compiler_available(compiler : WasmerCompilerT) : Bool
    fun wasmer_is_engine_available(engine : WasmerEngineT) : Bool
    fun wasmer_is_headless : Bool
    fun wasmer_last_error_length : LibC::Int
    fun wasmer_last_error_message(buffer : LibC::Char*, length : LibC::Int) : LibC::Int
    fun wasmer_metering_as_middleware(metering : WasmerMeteringT) : WasmerMiddlewareT
    fun wasmer_metering_delete(_metering : WasmerMeteringT)
    fun wasmer_metering_get_remaining_points(instance : WasmInstanceT) : LibC::ULong

    fun wasmer_metering_new(initial_limit : LibC::ULong, cost_function : WasmerMeteringCostFunctionT) : WasmerMeteringT

    fun wasmer_metering_points_are_exhausted(instance : WasmInstanceT) : Bool
    fun wasmer_metering_set_remaining_points(instance : WasmInstanceT, new_limit : LibC::ULong)
    fun wasmer_module_name(module : WasmModuleT, out : WasmNameT*)
    fun wasmer_module_set_name(module : WasmModuleT, name : WasmNameT*) : Bool
    fun wasmer_named_extern_module(named_extern : WasmerNamedExternT) : WasmNameT*
    fun wasmer_named_extern_name(named_extern : WasmerNamedExternT) : WasmNameT*
    fun wasmer_named_extern_unwrap(named_extern : WasmerNamedExternT) : WasmExternT
    fun wasmer_named_extern_vec_copy(out_ptr : WasmerNamedExternVecT*, in_ptr : WasmerNamedExternVecT*)
    fun wasmer_named_extern_vec_delete(ptr : WasmerNamedExternVecT*)
    fun wasmer_named_extern_vec_new(out : WasmerNamedExternVecT*, length : LibC::ULong, init : WasmerNamedExternT*)
    fun wasmer_named_extern_vec_new_empty(out : WasmerNamedExternVecT*)
    fun wasmer_named_extern_vec_new_uninitialized(out : WasmerNamedExternVecT*, length : LibC::ULong)
    fun wasmer_target_delete(_target : WasmerTargetT)
    fun wasmer_target_new(triple : WasmerTripleT, cpu_features : WasmerCpuFeaturesT) : WasmerTargetT
    fun wasmer_triple_delete(_triple : WasmerTripleT)
    fun wasmer_triple_new(triple : WasmNameT*) : WasmerTripleT
    fun wasmer_triple_new_from_host : WasmerTripleT
    fun wasmer_version : LibC::Char*
    fun wasmer_version_major : UInt8
    fun wasmer_version_minor : UInt8
    fun wasmer_version_patch : UInt8
    fun wasmer_version_pre : LibC::Char*

    WASM_LIMITS_MAX_DEFAULT = 0xffffffff_u32

    fun wat2wasm(wat : WasmByteVecT*, out : WasmByteVecT*)

    enum WasmerParserOperatorT
      Unreachable               =   0
      Nop                       =   1
      Block                     =   2
      Loop                      =   3
      If                        =   4
      Else                      =   5
      Try                       =   6
      Catch                     =   7
      CatchAll                  =   8
      Delegate                  =   9
      Throw                     =  10
      Rethrow                   =  11
      Unwind                    =  12
      End                       =  13
      Br                        =  14
      BrIf                      =  15
      BrTable                   =  16
      Return                    =  17
      Call                      =  18
      CallIndirect              =  19
      ReturnCall                =  20
      ReturnCallIndirect        =  21
      Drop                      =  22
      Select                    =  23
      TypedSelect               =  24
      LocalGet                  =  25
      LocalSet                  =  26
      LocalTee                  =  27
      GlobalGet                 =  28
      GlobalSet                 =  29
      I32Load                   =  30
      I64Load                   =  31
      F32Load                   =  32
      F64Load                   =  33
      I32Load8S                 =  34
      I32Load8U                 =  35
      I32Load16S                =  36
      I32Load16U                =  37
      I64Load8S                 =  38
      I64Load8U                 =  39
      I64Load16S                =  40
      I64Load16U                =  41
      I64Load32S                =  42
      I64Load32U                =  43
      I32Store                  =  44
      I64Store                  =  45
      F32Store                  =  46
      F64Store                  =  47
      I32Store8                 =  48
      I32Store16                =  49
      I64Store8                 =  50
      I64Store16                =  51
      I64Store32                =  52
      MemorySize                =  53
      MemoryGrow                =  54
      I32Const                  =  55
      I64Const                  =  56
      F32Const                  =  57
      F64Const                  =  58
      RefNull                   =  59
      RefIsNull                 =  60
      RefFunc                   =  61
      I32Eqz                    =  62
      I32Eq                     =  63
      I32Ne                     =  64
      I32LtS                    =  65
      I32LtU                    =  66
      I32GtS                    =  67
      I32GtU                    =  68
      I32LeS                    =  69
      I32LeU                    =  70
      I32GeS                    =  71
      I32GeU                    =  72
      I64Eqz                    =  73
      I64Eq                     =  74
      I64Ne                     =  75
      I64LtS                    =  76
      I64LtU                    =  77
      I64GtS                    =  78
      I64GtU                    =  79
      I64LeS                    =  80
      I64LeU                    =  81
      I64GeS                    =  82
      I64GeU                    =  83
      F32Eq                     =  84
      F32Ne                     =  85
      F32Lt                     =  86
      F32Gt                     =  87
      F32Le                     =  88
      F32Ge                     =  89
      F64Eq                     =  90
      F64Ne                     =  91
      F64Lt                     =  92
      F64Gt                     =  93
      F64Le                     =  94
      F64Ge                     =  95
      I32Clz                    =  96
      I32Ctz                    =  97
      I32Popcnt                 =  98
      I32Add                    =  99
      I32Sub                    = 100
      I32Mul                    = 101
      I32DivS                   = 102
      I32DivU                   = 103
      I32RemS                   = 104
      I32RemU                   = 105
      I32And                    = 106
      I32Or                     = 107
      I32Xor                    = 108
      I32Shl                    = 109
      I32ShrS                   = 110
      I32ShrU                   = 111
      I32Rotl                   = 112
      I32Rotr                   = 113
      I64Clz                    = 114
      I64Ctz                    = 115
      I64Popcnt                 = 116
      I64Add                    = 117
      I64Sub                    = 118
      I64Mul                    = 119
      I64DivS                   = 120
      I64DivU                   = 121
      I64RemS                   = 122
      I64RemU                   = 123
      I64And                    = 124
      I64Or                     = 125
      I64Xor                    = 126
      I64Shl                    = 127
      I64ShrS                   = 128
      I64ShrU                   = 129
      I64Rotl                   = 130
      I64Rotr                   = 131
      F32Abs                    = 132
      F32Neg                    = 133
      F32Ceil                   = 134
      F32Floor                  = 135
      F32Trunc                  = 136
      F32Nearest                = 137
      F32Sqrt                   = 138
      F32Add                    = 139
      F32Sub                    = 140
      F32Mul                    = 141
      F32Div                    = 142
      F32Min                    = 143
      F32Max                    = 144
      F32Copysign               = 145
      F64Abs                    = 146
      F64Neg                    = 147
      F64Ceil                   = 148
      F64Floor                  = 149
      F64Trunc                  = 150
      F64Nearest                = 151
      F64Sqrt                   = 152
      F64Add                    = 153
      F64Sub                    = 154
      F64Mul                    = 155
      F64Div                    = 156
      F64Min                    = 157
      F64Max                    = 158
      F64Copysign               = 159
      I32WrapI64                = 160
      I32TruncF32S              = 161
      I32TruncF32U              = 162
      I32TruncF64S              = 163
      I32TruncF64U              = 164
      I64ExtendI32S             = 165
      I64ExtendI32U             = 166
      I64TruncF32S              = 167
      I64TruncF32U              = 168
      I64TruncF64S              = 169
      I64TruncF64U              = 170
      F32ConvertI32S            = 171
      F32ConvertI32U            = 172
      F32ConvertI64S            = 173
      F32ConvertI64U            = 174
      F32DemoteF64              = 175
      F64ConvertI32S            = 176
      F64ConvertI32U            = 177
      F64ConvertI64S            = 178
      F64ConvertI64U            = 179
      F64PromoteF32             = 180
      I32ReinterpretF32         = 181
      I64ReinterpretF64         = 182
      F32ReinterpretI32         = 183
      F64ReinterpretI64         = 184
      I32Extend8S               = 185
      I32Extend16S              = 186
      I64Extend8S               = 187
      I64Extend16S              = 188
      I64Extend32S              = 189
      I32TruncSatF32S           = 190
      I32TruncSatF32U           = 191
      I32TruncSatF64S           = 192
      I32TruncSatF64U           = 193
      I64TruncSatF32S           = 194
      I64TruncSatF32U           = 195
      I64TruncSatF64S           = 196
      I64TruncSatF64U           = 197
      MemoryInit                = 198
      DataDrop                  = 199
      MemoryCopy                = 200
      MemoryFill                = 201
      TableInit                 = 202
      ElemDrop                  = 203
      TableCopy                 = 204
      TableFill                 = 205
      TableGet                  = 206
      TableSet                  = 207
      TableGrow                 = 208
      TableSize                 = 209
      MemoryAtomicNotify        = 210
      MemoryAtomicWait32        = 211
      MemoryAtomicWait64        = 212
      AtomicFence               = 213
      I32AtomicLoad             = 214
      I64AtomicLoad             = 215
      I32AtomicLoad8U           = 216
      I32AtomicLoad16U          = 217
      I64AtomicLoad8U           = 218
      I64AtomicLoad16U          = 219
      I64AtomicLoad32U          = 220
      I32AtomicStore            = 221
      I64AtomicStore            = 222
      I32AtomicStore8           = 223
      I32AtomicStore16          = 224
      I64AtomicStore8           = 225
      I64AtomicStore16          = 226
      I64AtomicStore32          = 227
      I32AtomicRmwAdd           = 228
      I64AtomicRmwAdd           = 229
      I32AtomicRmw8AddU         = 230
      I32AtomicRmw16AddU        = 231
      I64AtomicRmw8AddU         = 232
      I64AtomicRmw16AddU        = 233
      I64AtomicRmw32AddU        = 234
      I32AtomicRmwSub           = 235
      I64AtomicRmwSub           = 236
      I32AtomicRmw8SubU         = 237
      I32AtomicRmw16SubU        = 238
      I64AtomicRmw8SubU         = 239
      I64AtomicRmw16SubU        = 240
      I64AtomicRmw32SubU        = 241
      I32AtomicRmwAnd           = 242
      I64AtomicRmwAnd           = 243
      I32AtomicRmw8AndU         = 244
      I32AtomicRmw16AndU        = 245
      I64AtomicRmw8AndU         = 246
      I64AtomicRmw16AndU        = 247
      I64AtomicRmw32AndU        = 248
      I32AtomicRmwOr            = 249
      I64AtomicRmwOr            = 250
      I32AtomicRmw8OrU          = 251
      I32AtomicRmw16OrU         = 252
      I64AtomicRmw8OrU          = 253
      I64AtomicRmw16OrU         = 254
      I64AtomicRmw32OrU         = 255
      I32AtomicRmwXor           = 256
      I64AtomicRmwXor           = 257
      I32AtomicRmw8XorU         = 258
      I32AtomicRmw16XorU        = 259
      I64AtomicRmw8XorU         = 260
      I64AtomicRmw16XorU        = 261
      I64AtomicRmw32XorU        = 262
      I32AtomicRmwXchg          = 263
      I64AtomicRmwXchg          = 264
      I32AtomicRmw8XchgU        = 265
      I32AtomicRmw16XchgU       = 266
      I64AtomicRmw8XchgU        = 267
      I64AtomicRmw16XchgU       = 268
      I64AtomicRmw32XchgU       = 269
      I32AtomicRmwCmpxchg       = 270
      I64AtomicRmwCmpxchg       = 271
      I32AtomicRmw8CmpxchgU     = 272
      I32AtomicRmw16CmpxchgU    = 273
      I64AtomicRmw8CmpxchgU     = 274
      I64AtomicRmw16CmpxchgU    = 275
      I64AtomicRmw32CmpxchgU    = 276
      V128Load                  = 277
      V128Store                 = 278
      V128Const                 = 279
      I8x16Splat                = 280
      I8x16ExtractLaneS         = 281
      I8x16ExtractLaneU         = 282
      I8x16ReplaceLane          = 283
      I16x8Splat                = 284
      I16x8ExtractLaneS         = 285
      I16x8ExtractLaneU         = 286
      I16x8ReplaceLane          = 287
      I32x4Splat                = 288
      I32x4ExtractLane          = 289
      I32x4ReplaceLane          = 290
      I64x2Splat                = 291
      I64x2ExtractLane          = 292
      I64x2ReplaceLane          = 293
      F32x4Splat                = 294
      F32x4ExtractLane          = 295
      F32x4ReplaceLane          = 296
      F64x2Splat                = 297
      F64x2ExtractLane          = 298
      F64x2ReplaceLane          = 299
      I8x16Eq                   = 300
      I8x16Ne                   = 301
      I8x16LtS                  = 302
      I8x16LtU                  = 303
      I8x16GtS                  = 304
      I8x16GtU                  = 305
      I8x16LeS                  = 306
      I8x16LeU                  = 307
      I8x16GeS                  = 308
      I8x16GeU                  = 309
      I16x8Eq                   = 310
      I16x8Ne                   = 311
      I16x8LtS                  = 312
      I16x8LtU                  = 313
      I16x8GtS                  = 314
      I16x8GtU                  = 315
      I16x8LeS                  = 316
      I16x8LeU                  = 317
      I16x8GeS                  = 318
      I16x8GeU                  = 319
      I32x4Eq                   = 320
      I32x4Ne                   = 321
      I32x4LtS                  = 322
      I32x4LtU                  = 323
      I32x4GtS                  = 324
      I32x4GtU                  = 325
      I32x4LeS                  = 326
      I32x4LeU                  = 327
      I32x4GeS                  = 328
      I32x4GeU                  = 329
      I64x2Eq                   = 330
      I64x2Ne                   = 331
      I64x2LtS                  = 332
      I64x2GtS                  = 333
      I64x2LeS                  = 334
      I64x2GeS                  = 335
      F32x4Eq                   = 336
      F32x4Ne                   = 337
      F32x4Lt                   = 338
      F32x4Gt                   = 339
      F32x4Le                   = 340
      F32x4Ge                   = 341
      F64x2Eq                   = 342
      F64x2Ne                   = 343
      F64x2Lt                   = 344
      F64x2Gt                   = 345
      F64x2Le                   = 346
      F64x2Ge                   = 347
      V128Not                   = 348
      V128And                   = 349
      V128AndNot                = 350
      V128Or                    = 351
      V128Xor                   = 352
      V128Bitselect             = 353
      V128AnyTrue               = 354
      I8x16Abs                  = 355
      I8x16Neg                  = 356
      I8x16AllTrue              = 357
      I8x16Bitmask              = 358
      I8x16Shl                  = 359
      I8x16ShrS                 = 360
      I8x16ShrU                 = 361
      I8x16Add                  = 362
      I8x16AddSatS              = 363
      I8x16AddSatU              = 364
      I8x16Sub                  = 365
      I8x16SubSatS              = 366
      I8x16SubSatU              = 367
      I8x16MinS                 = 368
      I8x16MinU                 = 369
      I8x16MaxS                 = 370
      I8x16MaxU                 = 371
      I8x16Popcnt               = 372
      I16x8Abs                  = 373
      I16x8Neg                  = 374
      I16x8AllTrue              = 375
      I16x8Bitmask              = 376
      I16x8Shl                  = 377
      I16x8ShrS                 = 378
      I16x8ShrU                 = 379
      I16x8Add                  = 380
      I16x8AddSatS              = 381
      I16x8AddSatU              = 382
      I16x8Sub                  = 383
      I16x8SubSatS              = 384
      I16x8SubSatU              = 385
      I16x8Mul                  = 386
      I16x8MinS                 = 387
      I16x8MinU                 = 388
      I16x8MaxS                 = 389
      I16x8MaxU                 = 390
      I16x8ExtAddPairwiseI8x16S = 391
      I16x8ExtAddPairwiseI8x16U = 392
      I32x4Abs                  = 393
      I32x4Neg                  = 394
      I32x4AllTrue              = 395
      I32x4Bitmask              = 396
      I32x4Shl                  = 397
      I32x4ShrS                 = 398
      I32x4ShrU                 = 399
      I32x4Add                  = 400
      I32x4Sub                  = 401
      I32x4Mul                  = 402
      I32x4MinS                 = 403
      I32x4MinU                 = 404
      I32x4MaxS                 = 405
      I32x4MaxU                 = 406
      I32x4DotI16x8S            = 407
      I32x4ExtAddPairwiseI16x8S = 408
      I32x4ExtAddPairwiseI16x8U = 409
      I64x2Abs                  = 410
      I64x2Neg                  = 411
      I64x2AllTrue              = 412
      I64x2Bitmask              = 413
      I64x2Shl                  = 414
      I64x2ShrS                 = 415
      I64x2ShrU                 = 416
      I64x2Add                  = 417
      I64x2Sub                  = 418
      I64x2Mul                  = 419
      F32x4Ceil                 = 420
      F32x4Floor                = 421
      F32x4Trunc                = 422
      F32x4Nearest              = 423
      F64x2Ceil                 = 424
      F64x2Floor                = 425
      F64x2Trunc                = 426
      F64x2Nearest              = 427
      F32x4Abs                  = 428
      F32x4Neg                  = 429
      F32x4Sqrt                 = 430
      F32x4Add                  = 431
      F32x4Sub                  = 432
      F32x4Mul                  = 433
      F32x4Div                  = 434
      F32x4Min                  = 435
      F32x4Max                  = 436
      F32x4PMin                 = 437
      F32x4PMax                 = 438
      F64x2Abs                  = 439
      F64x2Neg                  = 440
      F64x2Sqrt                 = 441
      F64x2Add                  = 442
      F64x2Sub                  = 443
      F64x2Mul                  = 444
      F64x2Div                  = 445
      F64x2Min                  = 446
      F64x2Max                  = 447
      F64x2PMin                 = 448
      F64x2PMax                 = 449
      I32x4TruncSatF32x4S       = 450
      I32x4TruncSatF32x4U       = 451
      F32x4ConvertI32x4S        = 452
      F32x4ConvertI32x4U        = 453
      I8x16Swizzle              = 454
      I8x16Shuffle              = 455
      V128Load8Splat            = 456
      V128Load16Splat           = 457
      V128Load32Splat           = 458
      V128Load32Zero            = 459
      V128Load64Splat           = 460
      V128Load64Zero            = 461
      I8x16NarrowI16x8S         = 462
      I8x16NarrowI16x8U         = 463
      I16x8NarrowI32x4S         = 464
      I16x8NarrowI32x4U         = 465
      I16x8ExtendLowI8x16S      = 466
      I16x8ExtendHighI8x16S     = 467
      I16x8ExtendLowI8x16U      = 468
      I16x8ExtendHighI8x16U     = 469
      I32x4ExtendLowI16x8S      = 470
      I32x4ExtendHighI16x8S     = 471
      I32x4ExtendLowI16x8U      = 472
      I32x4ExtendHighI16x8U     = 473
      I64x2ExtendLowI32x4S      = 474
      I64x2ExtendHighI32x4S     = 475
      I64x2ExtendLowI32x4U      = 476
      I64x2ExtendHighI32x4U     = 477
      I16x8ExtMulLowI8x16S      = 478
      I16x8ExtMulHighI8x16S     = 479
      I16x8ExtMulLowI8x16U      = 480
      I16x8ExtMulHighI8x16U     = 481
      I32x4ExtMulLowI16x8S      = 482
      I32x4ExtMulHighI16x8S     = 483
      I32x4ExtMulLowI16x8U      = 484
      I32x4ExtMulHighI16x8U     = 485
      I64x2ExtMulLowI32x4S      = 486
      I64x2ExtMulHighI32x4S     = 487
      I64x2ExtMulLowI32x4U      = 488
      I64x2ExtMulHighI32x4U     = 489
      V128Load8x8S              = 490
      V128Load8x8U              = 491
      V128Load16x4S             = 492
      V128Load16x4U             = 493
      V128Load32x2S             = 494
      V128Load32x2U             = 495
      V128Load8Lane             = 496
      V128Load16Lane            = 497
      V128Load32Lane            = 498
      V128Load64Lane            = 499
      V128Store8Lane            = 500
      V128Store16Lane           = 501
      V128Store32Lane           = 502
      V128Store64Lane           = 503
      I8x16RoundingAverageU     = 504
      I16x8RoundingAverageU     = 505
      I16x8Q15MulrSatS          = 506
      F32x4DemoteF64x2Zero      = 507
      F64x2PromoteLowF32x4      = 508
      F64x2ConvertLowI32x4S     = 509
      F64x2ConvertLowI32x4U     = 510
      I32x4TruncSatF64x2SZero   = 511
      I32x4TruncSatF64x2UZero   = 512
    end
  end
end
