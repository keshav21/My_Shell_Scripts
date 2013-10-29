#!/usr/bin/env bash

set -x -e

_SOURCE_CODES_DIR="${__SOURCE_CODES_PART__}/Source_Codes"

_WD="${_SOURCE_CODES_DIR}/Firmware/UEFI/TianoCore_Sourceforge"

_MAIN_BRANCH="jljusten/ovmf-nvvars"

source "${_WD}/tianocore_uefi_common.sh"

_UDK_BUILD_OUTER_DIR="${_UDK_DIR}/Build/OvmfX64/"
_UDK_BUILD_DIR="${_UDK_BUILD_OUTER_DIR}/RELEASE_GCC47/"

_OVMFPKG_BUILD_DIR="${_BACKUP_BUILDS_DIR}/OVMFPKG_BUILD"

_COMPILE_OVMFPKG() {
	
	echo
	
	_UDK_BUILD_CLEAN
	
	echo
	
	cd "${_UDK_DIR}/"
	git checkout "${_MAIN_BRANCH}"
	
	echo
	
	# _COPY_BUILDTOOLS_BASETOOLS
	
	echo
	
	_SET_PYTHON2
	
	echo
	
	_APPLY_PATCHES
	
	echo
	
	_APPLY_CHANGES
	
	echo
	
	cd "${_UDK_DIR}/OvmfPkg"
	"${_UDK_DIR}/OvmfPkg/build.sh" -a "X64" -b "RELEASE" -t "GCC47" -D "SECURE_BOOT_ENABLE=TRUE" -D "BUILD_NEW_SHELL"
	
	echo
	
	cp -rf "${_UDK_BUILD_DIR}" "${_OVMFPKG_BUILD_DIR}"
	
	echo
	
	_UDK_BUILD_CLEAN
	
	echo
	
	# _SET_PYTHON3
	
	echo
	
}

echo

_COMPILE_OVMFPKG

echo

unset _SOURCE_CODES_DIR
unset _WD
unset _UDK_DIR
unset _UDK_BUILD_TOOLS_DIR
unset _UDK_C_SOURCE_DIR
unset EDK_TOOLS_PATH
unset _OVMFPKG_BUILD_DIR
unset _BACKUP_BUILDS_DIR
unset _MAIN_BRANCH

set +x +e
