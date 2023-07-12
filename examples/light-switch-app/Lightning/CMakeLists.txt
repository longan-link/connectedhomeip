#
#    Copyright (c) 2021 Project CHIP Authors
#    All rights reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

# The following lines of boilerplate have to be in your project's
# CMakeLists in this exact order for cmake to work correctly
cmake_minimum_required(VERSION 3.5)
set(CHIP_SERIAL ln882h)

set(LN_SDK_ROOT ${CMAKE_CURRENT_LIST_DIR}/third_party/connectedhomeip/third_party/lightning/ln882h)
set(PROJECT_VER "v1.0")
set(PROJECT_VER_NUMBER 1)

set(VENDOR_SDK_ADAPTED 1)

set(USER_PROJECT Matter-light-switch-app)

set(PROJ_DIR ${CMAKE_CURRENT_LIST_DIR})
set(COMMOM_PUBLIC_DIR ${PROJ_DIR}/../../platform/lightning)

####### PROJECT_CFG_DIR need configured as lwip in sdk needs it ############
set(PROJECT_CFG_DIR ${PROJ_DIR}/cfg)

#set(ENV{LD_LIBRARY_PATH} "${LN_SDK_ROOT}:$ENV{LD_LIBRARY_PATH}")
#set(ENV{LD_LIBRARY_PATH} ${LN_SDK_ROOT})


set(CMAKE_VERBOSE_MAKEFILE    ON)
#-----------------------------   output path   -----------------------------
set(EXECUTABLE_OUTPUT_PATH    ${PROJ_DIR}/bin)
set(LIBRARY_OUTPUT_PATH       ${PROJ_DIR}/lib)

############################################################################
#######################  set up cross compiler toolchain  ##################
############################################################################
include(${COMMOM_PUBLIC_DIR}/gcc/gcc-toolchain-setup.cmake)

# message(STATUS  "COMMOM_PUBLIC_DIR = ${COMMOM_PUBLIC_DIR}")

include(${COMMOM_PUBLIC_DIR}/gcc/gcc-compiler-flags.cmake)

message(STATUS "<GET> USER_PROJECT= ${USER_PROJECT}")
message(STATUS "----------------------------------------------------------")
message(STATUS "-----------  LN SDK Configuring  -----------")
message(STATUS "----------------------------------------------------------")

################################################################################
##########################   default module selection   ########################
#-------------------------- library built within LN software team  -------------
option(COMP_WIFI_SUPPORT        "LN WiFi firmware."                         OFF)
option(COMP_BLE_SUPPORT         "LN BLE  firmware."                         OFF)

#----------------------------  library  choosen by customer  -------------------
option(COMP_DHCPD_SUPPORT       "DHCP client."                              ON)
option(COMP_LWIP_SUPPORT        "Light weight TCP/IP stack."                ON)

################################################################################
###########################   define module top dir   ##########################
################################################################################
set(MCU_LN882X_DIR              ${LN_SDK_ROOT}/mcu)
set(COMP_BLE_DIR                ${LN_SDK_ROOT}/components/ble)
set(COMP_FOTA_DIR               ${LN_SDK_ROOT}/components/fota)
set(COMP_KV_DIR                 ${LN_SDK_ROOT}/components/fs/kv)
set(COMP_NVDS_DIR               ${LN_SDK_ROOT}/components/fs/nvds)
set(COMP_PARTMGR_DIR            ${LN_SDK_ROOT}/components/fs/partition_mgr)
set(COMP_KERNEL_DIR             ${LN_SDK_ROOT}/components/kernel)
set(COMP_LNAT_DIR               ${LN_SDK_ROOT}/components/ln_at)
set(COMP_LNAT_CMD_DIR           ${LN_SDK_ROOT}/components/ln_at_cmd)
set(COMP_DHCPD_DIR              ${LN_SDK_ROOT}/components/net/dhcpd)
set(COMP_IPERF_DIR              ${LN_SDK_ROOT}/components/net/iperf)
set(COMP_PING_DIR               ${LN_SDK_ROOT}/components/net/ping)
set(COMP_HTTPSCLIENT_DIR        ${LN_SDK_ROOT}/components/net/httpsclient)
set(COMP_MBEDTLS_DIR            ${LN_SDK_ROOT}/components/net/mbedtls)
set(COMP_SERIAL_DIR             ${LN_SDK_ROOT}/components/serial)
set(COMP_UTILS_DIR              ${LN_SDK_ROOT}/components/utils)
set(COMP_LIBC_STUB_DIR          ${LN_SDK_ROOT}/components/libc)
set(COMP_WIFI_DIR               ${LN_SDK_ROOT}/components/wifi)

if(DEFINED THIRD_PARTY_LWIP AND (THIRD_PARTY_LWIP))
message(STATUS "LwIP: third-party provided.")
else()
message(STATUS "LwIP: LN SDK provided.")
set(COMP_LWIP_DIR           ${LN_SDK_ROOT}/components/net/lwip-2.1.3/src)
endif()
################################################################################
#############################    user project    ###############################
################################################################################

set(EXTRA_COMPONENT_DIRS
    "${CMAKE_CURRENT_LIST_DIR}/third_party/connectedhomeip/config/lightning"
    "${CMAKE_CURRENT_LIST_DIR}/../../common/QRCode"
)

project(chip-light-switch-app)

include(${PROJ_DIR}/ProjModuleCollect.cmake)

set(PROJ_ALL_SRC
    src/main.c
    src/usr_app.c
    #src/usr_ble_app.c
    bsp/serial_hw.c
    bsp/serial_h4tl_driver.c
    # bsp/drv_adc_measure.c
    ${COMMOM_PUBLIC_DIR}/startup/startup_${CHIP_SERIAL}_gcc.c
    ${MODULE_SRC}
)



message(STATUS  "COMP_DHCPD_SUPPORT = ${COMP_DHCPD_SUPPORT}")
message(STATUS  "COMP_LWIP_SUPPORT = ${COMP_LWIP_SUPPORT}")


#----------------------------   project output elf   ---------------------------
set(TARGET_ELF_NAME                         ${USER_PROJECT})
set(pro_executable_target                   ${TARGET_ELF_NAME}.elf)
add_executable(${pro_executable_target}     ${PROJ_ALL_SRC})

target_link_libraries(${pro_executable_target}
    PUBLIC
    ${CHIP_SERIAL}_ble_controller_stack_nim
    lwip
    ${CHIP_SERIAL}_wifi
    -lc -lm -lnosys

    PRIVATE
    -T${LINKER_SCRIPT}
    ${EXTRA_LINK_FLAGS}
)

target_link_directories(${pro_executable_target}
    PRIVATE
    ${LN_SDK_ROOT}/lib/gcclib
)

target_include_directories(${pro_executable_target}
    PRIVATE
    app
    bsp
    cfg
    include
)

include(${CMAKE_CURRENT_LIST_DIR}/../../platform/lightning/gcc/gcc-custom-build-stage.cmake)
add_subdirectory(${LN_SDK_ROOT}/components)