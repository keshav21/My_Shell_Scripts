#!/usr/bin/env bash

_PROCESS_CONTINUE_UEFI='FALSE'
_PROCESS_CONTINUE_BIOS='FALSE'

_SOURCE_CODES_DIR="${__SOURCE_CODES_PART__}/Source_Codes/"

_GRUB_SCRIPTS_DIR="${_SOURCE_CODES_DIR}/My_Shell_Scripts/grub/"
_BOOTLOADER_CONFIG_FILES_DIR="${_SOURCE_CODES_DIR}/My_Files/Bootloader_Config_Files/"
_GRUB_DIR_OUTER="${_SOURCE_CODES_DIR}/Boot_Managers/ALL/grub/"

if [[ \
	"${1}" == '' || \
	"${1}" == '-h' || \
	"${1}" == '-u' || \
	"${1}" == '-help' || \
	"${1}" == '-usage' || \
	"${1}" == '--help' || \
	"${1}" == '--usage' \
	]]
then
	echo
	echo '1 for UEFI-MAINLINE'
	echo '2 for UEFI-EXPERIMENTAL'
	echo '3 for BIOS-MAINLINE'
	echo '4 for BIOS-EXPERIMENTAL'
	echo
	export _PROCESS_CONTINUE_UEFI='FALSE'
	export _PROCESS_CONTINUE_BIOS='FALSE'
fi

_DO="${1}"

if [[ "${_DO}" == '1' ]] || [[ "${_DO}" == '2' ]]; then
	export _GRUB_UEFI_SRCDIR='grub_GIT'
	export _PROCESS_CONTINUE_UEFI='TRUE'
fi

if [[ "${_DO}" == '3' ]] || [[ "${_DO}" == '4' ]]; then
	export _GRUB_BIOS_SRCDIR='grub_GIT'
	export _PROCESS_CONTINUE_BIOS='TRUE'
	
fi

echo

_APPLY_PATCHES() {
	
	patch -Np1 -i "${_GRUB_DIR_OUTER}/archlinux_grub_mkconfig_fixes.patch"
	echo
	
}

_CLEAN_GRUB_SRCDIR() {
	
	echo
	
	cd "${_GRUB_DIR_OUTER}/${_GRUB_SRCDIR}/"
	
	git clean -x -d -f
	echo
	
	git reset --hard
	echo
	
	git checkout master
	echo
	
}

_COMPILE_GRUB() {
	
	_CLEAN_GRUB_SRCDIR
	echo
	
	cp -rf "${_GRUB_DIR_OUTER}/grub_extras__GIT_BZR" "${_GRUB_DIR_OUTER}/${_GRUB_SRCDIR}/grub_extras__GIT_BZR" || true
	echo
	
	if [[ "${_GRUB_PLATFORM}" == "uefi" ]]; then
		# rm -rf "${_GRUB_DIR_OUTER}/${_GRUB_SRCDIR}/grub_extras__GIT_BZR/lua" || true
		rm -rf "${_GRUB_DIR_OUTER}/${_GRUB_SRCDIR}/grub_extras__GIT_BZR/gpxe" || true
		echo
	fi
	
	if [[ "${_GRUB_PLATFORM}" == "bios" ]]; then
		# rm -rf "${_GRUB_DIR_OUTER}/${_GRUB_SRCDIR}/grub_extras__GIT_BZR/lua" || true
		# rm -rf "${_GRUB_DIR_OUTER}/${_GRUB_SRCDIR}/grub_extras__GIT_BZR/915resolution" || true
		# rm -rf "${_GRUB_DIR_OUTER}/${_GRUB_SRCDIR}/grub_extras__GIT_BZR/ntldr-img" || true
		rm -rf "${_GRUB_DIR_OUTER}/${_GRUB_SRCDIR}/grub_extras__GIT_BZR/gpxe" || true
		echo
	fi
	
	_APPLY_PATCHES
	echo
	
	cp --verbose "${_GRUB_SCRIPTS_DIR}/grub_${_GRUB_PLATFORM}.sh" "${_GRUB_SCRIPTS_DIR}/grub_${_GRUB_PLATFORM}_linux_my.sh" "${_GRUB_DIR_OUTER}/${_GRUB_SRCDIR}/"
	cp --verbose "${_GRUB_DIR_OUTER}/xman_dos2unix.sh" "${_GRUB_DIR_OUTER}/grub.default" "${_GRUB_DIR_OUTER}/${_GRUB_SRCDIR}/" || true
	cp --verbose "${_BOOTLOADER_CONFIG_FILES_DIR}/grub_uefi.cfg" "${_GRUB_DIR_OUTER}/${_GRUB_SRCDIR}/grub.cfg" || true
	echo
	
	# "${_GRUB_DIR_OUTER}/xman_dos2unix.sh" * || true
	
	"${PWD}/grub_${_GRUB_PLATFORM}_linux_my.sh"
	echo
	
}

if [[ "${_PROCESS_CONTINUE_UEFI}" == 'TRUE' ]]; then
	
	set -x -e
	
	echo
	
	_GRUB_PLATFORM="uefi"
	_GRUB_SRCDIR="${_GRUB_UEFI_SRCDIR}"
	_COMPILE_GRUB
	
	echo
	
	cp -rf "${_GRUB_DIR_OUTER}/${_GRUB_SRCDIR}/GRUB_UEFI_BUILD_DIR_x86_64" "${_GRUB_DIR_OUTER}/GRUB_UEFI_BUILD_DIR_x86_64" || true
	rm -rf "${_GRUB_DIR_OUTER}/${_GRUB_SRCDIR}/GRUB_UEFI_BUILD_DIR_x86_64" || true
	
	echo
	
	_CLEAN_GRUB_SRCDIR
	
	echo
	
	set +x +e
	
fi

if [[ "${_PROCESS_CONTINUE_BIOS}" == 'TRUE' ]]; then
	
	set -x -e
	
	echo
	
	_GRUB_PLATFORM="bios"
	_GRUB_SRCDIR="${_GRUB_BIOS_SRCDIR}"
	_COMPILE_GRUB
	
	echo
	
	cp -rf "${_GRUB_DIR_OUTER}/${_GRUB_BIOS_SRCDIR}/GRUB_BIOS_BUILD_DIR" "${_GRUB_DIR_OUTER}/GRUB_BIOS_BUILD_DIR" || true
	rm -rf "${_GRUB_DIR_OUTER}/${_GRUB_BIOS_SRCDIR}/GRUB_BIOS_BUILD_DIR" || true
	
	echo
	
	_CLEAN_GRUB_SRCDIR
	
	echo
	
	set +x +e
	
fi

unset _PROCESS_CONTINUE_UEFI
unset _PROCESS_CONTINUE_BIOS
unset _GRUB_SCRIPTS_DIR
unset _BOOTLOADER_CONFIG_FILES_DIR
unset _GRUB_DIR_OUTER
unset _GRUB_UEFI
unset _GRUB_BIOS
unset _GRUB_SRCDIR
unset _GRUB_UEFI_SRCDIR
unset _GRUB_BIOS_SRCDIR
unset _X86_32_CHROOT
