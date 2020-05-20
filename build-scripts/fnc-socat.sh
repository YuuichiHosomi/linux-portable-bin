#!/bin/sh

# shellcheck disable=SC2120
_build_musl_socat() {  # 1 - output, 2 - dependencies
	_out="out"; [ -n "$1" ] && _out="$1"; _out="${BUILD_DIR}/${_out}"
	_dep="dep"; [ -n "$2" ] && _dep="$2"; _dep="${BUILD_DIR}/${_dep}"
	_fetch_and_extract "socat" "${SOCAT_VERSION}" "http://www.dest-unreach.org/socat/download/"
	if _has_opt "${SOCAT_OPT}" "ssl" || _has_opt "${SOCAT_OPT}" "weak-ssl"; then
		# patch to use openssl+zlib
		sed -i'' 's/ -lcrypto"/ -lcrypto -lz"/g' configure || _err "patch"
	fi
	CC='gcc -static' CFLAGS='-fPIC' \
	CPPFLAGS="-I${_dep}/include" \
	LDFLAGS="-L${_dep}/lib" \
	./configure --host "${MUSL_ARCH}" --prefix="${_out}" || _err "configure"
	make || _err "make"
	strip --strip-all socat filan procan 2>/dev/null >/dev/null
	make install || _err "make install"
	"${_out}/bin/socat" -V 
}

