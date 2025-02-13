################################################################################
#####################   update flash partition table first  ####################
################################################################################
set(FLASH_PYTHON_SCRIPT   ${LN_SDK_ROOT}/tools/python_scripts/before_build_gcc.py)
set(FLASH_PART_CFG_JSON   ${PROJ_DIR}/cfg/flash_partition_cfg.json)
set(FLASH_PART_TABLE_FILE ${PROJ_DIR}/cfg/flash_partition_table.h)

execute_process(COMMAND python3 ${FLASH_PYTHON_SCRIPT} -p ${FLASH_PART_CFG_JSON} -o ${FLASH_PART_TABLE_FILE}
  WORKING_DIRECTORY ${PROJ_DIR}/cfg
)

################################################################################
###########################   update linker script  ############################
################################################################################
set(REWRITE_LINKERSCRIPT  ${LN_SDK_ROOT}/tools/python_scripts/rewrite_ln882x_linker_script.py)
set(LINKER_PATH           ${COMMOM_PUBLIC_DIR}/gcc/${CHIP_SERIAL}.ld)
message(STATUS "LINKER_PATH ${LINKER_PATH}")


execute_process(COMMAND python3 ${REWRITE_LINKERSCRIPT} ${FLASH_PART_CFG_JSON} ${LINKER_PATH}
  WORKING_DIRECTORY ${COMMOM_PUBLIC_DIR}/gcc
)

################################################################################
################################   make image  #################################
################################################################################
add_custom_target(MakeImage ALL
  COMMAND  python3   ${LN_MKIMAGE}   --sdkroot_dir ${LN_SDK_ROOT}  --userproj_dir  ${PROJ_DIR} --buildout_dir  ${EXECUTABLE_OUTPUT_PATH}  --buildout_name  ${TARGET_ELF_NAME}  --output flashimage.bin
  DEPENDS  ${pro_executable_target}
  WORKING_DIRECTORY  ${EXECUTABLE_OUTPUT_PATH}
)
