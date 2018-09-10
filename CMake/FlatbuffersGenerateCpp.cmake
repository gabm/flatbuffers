# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include(CMakeParseArguments)

function(flatbuffers_generate_cpp)
    cmake_parse_arguments(
        PARSED_ARGS # prefix
        "" # boolean
        "HEADER_OUTPUT_FOLDER;BFBS_OUTPUT_FOLDER" # single value
        "INPUT_FILES" # multi-value
        ${ARGN} # parser input
    )
        
    # prepare header output folder
    if (PARSED_ARGS_HEADER_OUTPUT_FOLDER)
        set(HEADER_OUTPUT_FOLDER ${PARSED_ARGS_HEADER_FOLDER})
    else()
        set(HEADER_OUTPUT_FOLDER ${CMAKE_BINARY_DIR}/flatc_headers)
    endif()
    file(MAKE_DIRECTORY ${HEADER_OUTPUT_FOLDER})
    
    # prepare bfbs output folder
    if (PARSED_ARGS_BFBS_OUTPUT_FOLDER)
        set(BFBS_OUTPUT_FOLDER ${PARSED_ARGS_BFBS_OUTPUT_FOLDER})
    else()
        set(BFBS_OUTPUT_FOLDER ${CMAKE_BINARY_DIR}/flatc_bfbs)
    endif()
    file(MAKE_DIRECTORY ${BFBS_OUTPUT_FOLDER})

    
    # set output folder
    set(TMP_OUTPUT_FOLDER ${CMAKE_BINARY_DIR}/tmp)
    
    foreach(INPUT_FILE ${PARSED_ARGS_INPUT_FILES})
        _flatbuffers_generate_single_cpp(HEADER_FILE BFBS_FILE ${HEADER_OUTPUT_FOLDER} ${BFBS_OUTPUT_FOLDER} ${TMP_OUTPUT_FOLDER} ${INPUT_FILE})
        list(APPEND HEADER_FILES ${HEADER_FILE})
        list(APPEND BFBS_FILES ${BFBS_FILE})
    endforeach()
    
    # export results
    set(FLATBUFFERS_GENERATED_SOURCES ${HEADER_FILES} PARENT_SCOPE)
    set(FLATBUFFERS_GENERATED_INCLUDE_DIRS ${HEADER_OUTPUT_FOLDER} PARENT_SCOPE)
    set(FLATBUFFERS_GENERATED_BFBS ${BFBS_FILES} PARENT_SCOPE)
endfunction()

function(_flatbuffers_generate_single_cpp HEADER_FILE_OUT BFBS_FILE_OUT HEADER_FOLDER BFBS_FOLDER TMP_FOLDER INPUT_FILE)
    # get absolute fbs filename
    get_filename_component(INPUT_FILE_ABS ${INPUT_FILE} ABSOLUTE)
    
    # get pure fbs filename without extensions
    get_filename_component(FBS_FILE_WE ${INPUT_FILE} NAME_WE)
    
    # set generated filenames
    set(TMP_GENERATED_HDR ${TMP_FOLDER}/${FBS_FILE_WE}_generated.h)
    set(TMP_GENERATED_BFBS ${TMP_FOLDER}/${FBS_FILE_WE}.bfbs)
    
    set(FINAL_GENERATED_HDR ${HEADER_FOLDER}/${FBS_FILE_WE}_generated.h)
    set(FINAL_GENERATED_BFBS ${BFBS_FOLDER}/${FBS_FILE_WE}.bfbs)
    
    # command to generate
    add_custom_command(
            OUTPUT "${FINAL_GENERATED_HDR}" "${FINAL_GENERATED_BFBS}"
            COMMAND  flatc -b --schema --cpp --gen-object-api -o ${TMP_FOLDER} ${INPUT_FILE_ABS}
            COMMAND ${CMAKE_COMMAND} -E rename ${TMP_GENERATED_HDR} ${FINAL_GENERATED_HDR}
            COMMAND ${CMAKE_COMMAND} -E rename ${TMP_GENERATED_BFBS} ${FINAL_GENERATED_BFBS}
            DEPENDS ${INPUT_FILE_ABS}
            COMMENT "Running C++ flatbuffers buffer compiler on ${INPUT_FILE}"
            VERBATIM )
    
    # set source file propterty
    set_source_files_properties(${FINAL_GENERATED_HDR} PROPERTIES GENERATED TRUE)
    set_source_files_properties(${FINAL_GENERATED_BFBS} PROPERTIES GENERATED TRUE)

    # return generated files
    set(${HEADER_FILE_OUT} ${FINAL_GENERATED_HDR} PARENT_SCOPE)
    set(${BFBS_FILE_OUT} ${FINAL_GENERATED_BFBS} PARENT_SCOPE)
endfunction()
