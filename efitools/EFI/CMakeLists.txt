project(EFI)

set(EFI_DEPS utils-efi asn1-efi)

foreach(target HashTool HelloWorld KeyTool Loader ReadVars SetNull UpdateVars)

# *.o
add_library (${target}_O STATIC ${target}.c)
set_target_properties(
    ${target}_O 
    PROPERTIES 
        PREFIX ""
)
target_compile_definitions(${target}_O PRIVATE ${CMAKE_EFI_DEFINITIONS})
target_compile_options(${target}_O PRIVATE ${CMAKE_EFI_OPTIONS})

# *.so
add_custom_target(
    ${target} ALL
    COMMAND ${CMAKE_LINKER} -nostdlib -znocombreloc -shared -Bsymbolic -L ${EFI_CRTPATH} ${EFI_CRTLIB} -T ${EFI_LDS} $<TARGET_LINKER_FILE:${target}_O> -o ${LIBRARY_OUTPUT_PATH}/${target}.so $<TARGET_FILE:utils-efi> $<TARGET_FILE:asn1-efi> -lefi -lgnuefi
    COMMAND nm -D ${LIBRARY_OUTPUT_PATH}/${target}.so | grep " U " && exit 1 || exit 0
    VERBATIM
)
add_dependencies(${target} ${target}_O)
add_dependencies (${target} ${EFI_DEPS})

# *.efi
add_custom_target(
    ${target}_EFI ALL
    COMMAND objcopy 
                -j .text -j .sdata -j .data -j .dynamic 
                -j .dynsym -j .rel -j .rela -j .rel.* 
                -j .rela.* -j .rel* -j .rela* -j .reloc 
                --target=efi-app-${ARCHITECTURE} 
                ${LIBRARY_OUTPUT_PATH}/${target}.so ${INSTALL_DIR}/EFI/${target}.efi
    COMMENT "Building EFI"
    VERBATIM
)
set_target_properties(
    ${target}_EFI
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${INSTALL_DIR}/EFI"
)

add_dependencies(${target}_EFI ${target})

endforeach(target)