project(asn1)

set(SOURCES
    src/asn1.c 
    src/asn1_parser.c 
    src/enumerator.c 
    src/chunk.c 
    src/oid.c 
    src/identification.c  
    src/x509.c
)

add_library (asn1 ${SOURCES})
target_include_directories(asn1 PRIVATE include)

add_library (asn1-efi ${SOURCES})
target_include_directories(asn1-efi PRIVATE include)
target_compile_definitions(asn1-efi PRIVATE ${CMAKE_EFI_DEFINITIONS})
target_compile_options(asn1-efi PRIVATE ${CMAKE_EFI_OPTIONS})

add_executable(test_x509_to_str src/test_x509_to_str.c)
add_test(test_x509_to_str test_x509_to_str)
target_include_directories(test_x509_to_str PRIVATE include)
target_link_libraries (test_x509_to_str asn1)