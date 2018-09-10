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


function(flatbuffers_generate_cpp OUTPUT_FOLDER GENERATED_SRCS)    
    # set output folder
    set(THIS_OUTPUT_FOLDER ${CMAKE_CURRENT_BINARY_DIR}/flatc_generated)
    file(MAKE_DIRECTORY ${OUTPUT_FOLDER})
    
    foreach(INPUT_FILE ${ARGN})
        flatbuffers_generate_single_cpp(SRC ${THIS_OUTPUT_FOLDER} ${INPUT_FILE})
        list(APPEND SRCS ${SRC})
    endforeach()

    set(${GENERATED_SRCS} ${SRCS} PARENT_SCOPE)
    set(${OUTPUT_FOLDER} ${THIS_OUTPUT_FOLDER} PARENT_SCOPE)
endfunction()

function(flatbuffers_generate_single_cpp SRC OUTPUT_FOLDER INPUT_FILE)
    # get absolute fbs filename
    get_filename_component(INPUT_FILE_ABS ${INPUT_FILE} ABSOLUTE)
    
    # get pure fbs filename without extensions
    get_filename_component(FBS_FILE_WE ${INPUT_FILE} NAME_WE)
    
    
    # set generated filenames
    set(GENERATED_HDR ${OUTPUT_FOLDER}/${FBS_FILE_WE}_generated.h)
    set(GENERATED_BFBS ${OUTPUT_FOLDER}/${FBS_FILE_WE}.bfbs)
    
    # command to generate
    add_custom_command(
            OUTPUT "${GENERATED_HDR}" "${GENERATED_BFBS}"
            COMMAND  flatc
            ARGS -b --schema --cpp --gen-object-api -o ${OUTPUT_FOLDER} ${INPUT_FILE_ABS}
            DEPENDS ${INPUT_FILE_ABS}
            COMMENT "Running C++ flatbuffers buffer compiler on ${INPUT_FILE}"
            VERBATIM )
    
    # set source file propterty
    set_source_files_properties(${GENERATED_HDR} PROPERTIES GENERATED TRUE)
    
    # return generated files
    set(${SRC} ${GENERATED_HDR} PARENT_SCOPE)
endfunction()

