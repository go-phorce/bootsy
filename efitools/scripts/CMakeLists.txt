project(scripts)

add_custom_target(
    scripts ALL
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/scripts/*.sh ${INSTALL_SCRIPTS_DIR}
)
