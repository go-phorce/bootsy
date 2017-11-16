project(utils)

set(SOURCES
    simple_file.c
    pecoff.c
    guid.c
    sha256.c
    console.c
    execute.c
    configtable.c
    shell.c
    security_policy.c
    shim_protocol.c
    pkcs7verify.c
)

set(LIB_SOURCES
    ${SOURCES}
    kernel_efivars.c
)

set(EFILIB_SOURCES
    ${SOURCES}
    variables.c
)

add_library (utils ${LIB_SOURCES})

add_library (utils-efi ${EFILIB_SOURCES})
target_compile_definitions(utils-efi PRIVATE ${CMAKE_EFI_DEFINITIONS})
target_compile_options(utils-efi PRIVATE ${CMAKE_EFI_OPTIONS})
