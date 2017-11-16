cmake_minimum_required(VERSION 3.5)
project(efitools)

set(CMAKE_VERBOSE_MAKEFILE ON)

if(NOT CMAKE_BUILD_TYPE)
set(CMAKE_BUILD_TYPE "Release")
endif()

if(NOT CMAKE_INSTALL_PREFIX)
set(CMAKE_INSTALL_PREFIX "/usr")
endif()

if(CMAKE_VERSION VERSION_GREATER "3.3")
cmake_policy(SET CMP0063 NEW)
endif()

set(LIBPATHS "/lib /lib64 /lib/efi /lib64/efi /usr/lib /usr/lib64 /usr/lib/efi /usr/lib64/efi")
execute_process (COMMAND uname -m COMMAND tr -d '\n' OUTPUT_VARIABLE ARCHITECTURE )
message( STATUS "Architecture: ${ARCHITECTURE}" )

execute_process (COMMAND gcc -print-libgcc-file-name COMMAND tr -d '\n' OUTPUT_VARIABLE LIBGCC_FILE)
message( STATUS "libgcc: ${LIBGCC_FILE}" )

set(EFI_CRTOBJ crt0-efi-${ARCHITECTURE}.o)
# EFI_CRTPATH
execute_process (
    COMMAND bash -c "for f in ${LIBPATHS} ; do if [ -e $f/${EFI_CRTOBJ} ]; then echo $f; break; fi; done"
    COMMAND tr -d '\n'
    OUTPUT_VARIABLE EFI_CRTPATH
)
message( STATUS "EFI_CRTPATH: ${EFI_CRTPATH}" )

set(EFI_CRTLIB ${EFI_CRTPATH}/${EFI_CRTOBJ})
message( STATUS "ctr0-efi: ${EFI_CRTLIB}" )

set(EFI_LDS ${EFI_CRTPATH}/elf_${ARCHITECTURE}_efi.lds)
message( STATUS "efi-lds: ${EFI_LDS}" )

set(CMAKE_CXX_FLAGS "-fpic -Wall -mno-red-zone -fshort-wchar -fno-strict-aliasing -fno-merge-constants -fno-stack-protector -ffreestanding -fno-stack-check")
set(CMAKE_C_FLAGS "-fpic -Wall -mno-red-zone -fshort-wchar -fno-strict-aliasing -fno-merge-constants -fno-stack-protector -ffreestanding -fno-stack-check")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -O2")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS} -O2")

set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_C_VISIBILITY_PRESET hidden)

set(CMAKE_EFI_OPTIONS -fno-toplevel-reorder -fpic -Wall -mno-red-zone -fshort-wchar -fno-strict-aliasing -fno-merge-constants -fno-stack-protector -ffreestanding -fno-stack-check)
set(CMAKE_EFI_DEFINITIONS -DBUILD_EFI -DEFI_FUNCTION_WRAPPER)

set(INSTALL_DIR ${CMAKE_BINARY_DIR}/install)
set(INSTALL_BIN_DIR ${CMAKE_BINARY_DIR}/install/bin)
set(INSTALL_EFI_DIR ${CMAKE_BINARY_DIR}/install/EFI)
set(INSTALL_SCRIPTS_DIR ${CMAKE_BINARY_DIR}/install/scripts)
# set(TOOLS_DIR ${CMAKE_BINARY_DIR}/tools)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib)

file(MAKE_DIRECTORY ${INSTALL_EFI_DIR})
file(MAKE_DIRECTORY ${INSTALL_BIN_DIR})
file(MAKE_DIRECTORY ${INSTALL_SCRIPTS_DIR})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${INSTALL_EFI_DIR})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${INSTALL_BIN_DIR})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${INSTALL_SCRIPTS_DIR})

# CMAKE_REQUIRED_LIBRARIES = crypto
# CMAKE_REQUIRED_INCLUDES = "efi/efi.h"

include_directories(
    ./include 
    /usr/include/efi
    /usr/include/efi/protocol
    /usr/include/efi/${ARCHITECTURE}
    )

add_definitions(-DGNU_EFI_USE_MS_ABI -DEFI_FUNCTION_WRAPPER)

# Libraries
add_subdirectory (utils)
add_subdirectory (asn1)

# Tools folder
add_subdirectory (tools)

set(TOOLS_DEPS utils asn1)
add_dependencies (cert-to-efi-hash-list ${TOOLS_DEPS})
add_dependencies (cert-to-efi-sig-list ${TOOLS_DEPS})
add_dependencies (efi-keytool ${TOOLS_DEPS})
add_dependencies (efi-readvar ${TOOLS_DEPS})
add_dependencies (efi-updatevar ${TOOLS_DEPS})
add_dependencies (flash-var ${TOOLS_DEPS})
add_dependencies (hash-to-efi-sig-list ${TOOLS_DEPS})
add_dependencies (sig-list-to-certs ${TOOLS_DEPS})
add_dependencies (sign-efi-sig-list ${TOOLS_DEPS})

set_target_properties(
    cert-to-efi-hash-list
    cert-to-efi-sig-list
    efi-keytool
    efi-readvar
    efi-updatevar
    flash-var
    hash-to-efi-sig-list
    sig-list-to-certs
    sign-efi-sig-list
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${INSTALL_BIN_DIR}"
)

# EFI folder
add_subdirectory (EFI)

# Scripts folder
add_subdirectory (scripts)

#
# Installation
#
install(PROGRAMS 
            "${INSTALL_BIN_DIR}/cert-to-efi-hash-list"
            "${INSTALL_BIN_DIR}/cert-to-efi-sig-list"
            "${INSTALL_BIN_DIR}/efi-keytool"
            "${INSTALL_BIN_DIR}/efi-readvar"
            "${INSTALL_BIN_DIR}/efi-updatevar"
            "${INSTALL_BIN_DIR}/flash-var"
            "${INSTALL_BIN_DIR}/hash-to-efi-sig-list"
            "${INSTALL_BIN_DIR}/sig-list-to-certs"
            "${INSTALL_BIN_DIR}/sign-efi-sig-list"
        DESTINATION bin
)

install(DIRECTORY 
            "${INSTALL_EFI_DIR}/" 
            "${INSTALL_SCRIPTS_DIR}/"
        DESTINATION "${CMAKE_INSTALL_PREFIX}/share/bootsy"
        DIRECTORY_PERMISSIONS 
            OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ 
        PATTERN "*.efi"
            PERMISSIONS OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ 
        PATTERN "*.sh"
            PERMISSIONS OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ 
)
