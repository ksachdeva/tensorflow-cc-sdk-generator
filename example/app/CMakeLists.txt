set(SAMPLE_APP_NAME "example")

set(APP_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(APP_SRC_PATH  "${APP_MODULE_PATH}/src" )

file(GLOB APP_SOURCE_FILES "${APP_SRC_PATH}/main.cc")

add_executable(
    ${SAMPLE_APP_NAME}
    ${APP_SOURCE_FILES}
)

target_include_directories(
    ${SAMPLE_APP_NAME}
    PRIVATE    
)

target_link_libraries(
    ${SAMPLE_APP_NAME}         
    PRIVATE        
    third-party::tensorflow-cc
)

enable_testing ()
