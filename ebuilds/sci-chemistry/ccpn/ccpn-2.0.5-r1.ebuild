# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

NEED_PYTHON=2.4
PYTHON_MODNAME="ccpn"

inherit python toolchain-funcs portability distutils eutils

MY_PN="${PN}mr"

SLOT="0"
LICENSE="|| ( CCPN LGPL-2.1 )"
KEYWORDS="~x86"
DESCRIPTION="The Collaborative Computing Project for NMR"
SRC_URI="http://www.bio.cam.ac.uk/ccpn/download/${MY_PN}/analysis${PV}.tar.gz"
HOMEPAGE="http://www.ccpn.ac.uk/ccpn"
IUSE="doc numpy opengl"
RESTRICT="mirror"
RDEPEND="${DEPEND}"
DEPEND="virtual/glut
	 dev-tcltk/tix
	 dev-python/numpy"
# automagic dep, so we DEPEND on it until fixed"
#	 numpy? ( dev-python/numpy )"

S="${WORKDIR}"/${MY_PN}

pkg_setup() {
	python_tkinter_exists
	python_version
}

src_unpack() {
	unpack ${A}

	epatch "${FILESDIR}"/missing-link.patch

	echo "" > "${S}"/ccpnmr2.0/c/environment.txt || die "failed to kill environment.txt"
}

src_compile() {

	local tk_ver
	local myconf

	tk_ver="$(best_version dev-lang/tk | cut -d- -f3 | cut -d. -f1,2)"

	if use opengl; then
	# specify whether or not you want to compile GL
	# use below if you want to compile GL
	#IGNORE_GL_FLAG =
	# use below if you want to ignore GL
	#IGNORE_GL_FLAG = -DIGNORE_GL

	# special GL flag, should have either USE_GL_TRUE or USE_GL_FALSE
	# (-D means this gets defined by the compiler so can be checked in source code)
	# (this relates to glXCreateContext() call in ccpnmr/global/gl_handler.c)
	# if have problems with USE_GL_TRUE then try GL_FALSE, or vice versa
	# use below for Linux?
	#GL_FLAG = -DUSE_GL_FALSE
	# use below for everything else?
	#GL_FLAG = -DUSE_GL_TRUE

	# use below if your glut does not need to be explicitly initialised
	#GLUT_NEED_INIT =
	# use below if your glut needs to be explicitly initialised
	# looks like need it for freeglut and for OSX glut
	#GLUT_NEED_INIT = -DNEED_GLUT_INIT

	# whether glut.h is GL/glut.h (normal case) or just glut.h (OSX)
	# use below if glut.h is in GL directory
	#GLUT_NOT_IN_GL =
	# use below if glut.h is not in GL directory (e.g. OSX)
	#GLUT_NOT_IN_GL = -DGLUT_IN_OWN_DIR

	# special glut flag
	#GLUT_FLAG = $(GLUT_NEED_INIT) $(GLUT_NOT_IN_GL)


	if has_version media-libs/freeglut; then
		GLUT_NEED_INIT="-DNEED_GLUT_INIT"
	else
		GLUT_NEED_INIT=""
	fi

		IGNORE_GL_FLAG=""
		GL_FLAG="-DUSE_GL_FALSE"
		GLUT_NOT_IN_GL=""
		GLUT_FLAG="\$(GLUT_NEED_INIT) \$(GLUT_NOT_IN_GL)"
		GL_DIR="/usr"
		GL_LIB="-lglut -lGLU -lGL"
		GL_INCLUDE_FLAGS="-I\$(GL_DIR)/include"
		GL_LIB_FLAGS="-L\$(GL_DIR)/$(get_libdir)"

	else
		IGNORE_GL_FLAG="-DIGNORE_GL"
		GL_FLAG="-DUSE_GL_FALSE"
		GLUT_NOT_IN_GL=""
		GLUT_FLAG="\$(GLUT_NEED_INIT) \$(GLUT_NOT_IN_GL)"
	fi

	cd ccpnmr2.0/c

	emake \
		CC="$(tc-getCC)" \
		MALLOC_FLAG= \
		FPIC_FLAG="-fPIC" \
		SHARED_FLAGS="-shared" \
		MATH_LIB="-lm" \
		X11_DIR="/usr" \
		X11_LIB="-lX11 -lXext" \
		X11_INCLUDE_FLAGS="-I\$(X11_DIR)/include" \
		X11_LIB_FLAGS="-L\$(X11_DIR)/lib" \
		TCL_DIR="/usr" \
		TCL_LIB="-ltcl${tk_ver}" \
		TCL_INCLUDE_FLAGS="-I\$(TCL_DIR)/include" \
		TCL_LIB_FLAGS="-L\$(TCL_DIR)/$(get_libdir)" \
		TK_DIR="/usr" \
		TK_LIB="-ltk${tk_ver}" \
		TK_INCLUDE_FLAGS="-I\$(TK_DIR)/include" \
		TK_LIB_FLAGS="-L\$(TK_DIR)/$(get_libdir)" \
		PYTHON_DIR="/usr" \
		PYTHON_INCLUDE_FLAGS="-I\$(PYTHON_DIR)/include/python${PYVER}" \
		CFLAGS="${CFLAGS} \$(MALLOC_FLAG) \$(FPIC_FLAG)" \
		GLUT_NEED_INIT="${GLUT_NEED_INIT}" \
		IGNORE_GL_FLAG="${IGNORE_GL_FLAG}" \
		GL_FLAG="${GL_FLAG}" \
		GLUT_NOT_IN_GL="${GLUT_NOT_IN_GL}" \
		GLUT_FLAG="${GLUT_FLAG}" \
		GL_DIR="${GL_DIR}" \
		GL_LIB="${GL_LIB}" \
		GL_INCLUDE_FLAGS="${GL_INCLUDE_FLAGS}" \
		GL_LIB_FLAGS="${GL_LIB_FLAGS}" \
	all links || \
	die "failed to compile"

}

src_install() {

	local IN_PATH
	local GENTOO_SITEDIR
	local LIBDIR
	local FILES

	IN_PATH=$(python_get_sitedir)/${PN}
	GENTOO_SITEDIR=$(python_get_sitedir)
	LIBDIR=$(get_libdir)

	for wrapper in analysis dangle dataShifter formatConverter pipe2azara; do
		sed -e "s:GENTOO_SITEDIR:${GENTOO_SITEDIR}:g" \
		    -e "s:LIBDIR:${LIBDIR}:g" \
		    "${FILESDIR}"/${wrapper} > "${T}"/${wrapper} || die "Fail fix ${wrapper}"
		dobin "${T}"/${wrapper} || die "Failed to install ${wrapper}"
	done

	use doc && treecopy $(find . -name doc) "${D}"usr/share/doc/${PF}/html/

	ebegin "Removing unneeded docs"
	find . -name doc -exec rm -rf '{}' \; 2> /dev/null
	eend

	insinto ${IN_PATH}

	ebegin "Installing main files"
	doins -r ccpnmr2.0/{data,model,python} || die "main files installation failed"
	eend

	einfo "Adjusting permissions"

	FILES="ccpnmr/c/ContourFile.so
		ccpnmr/c/ContourLevels.so
		ccpnmr/c/ContourStyle.so
		ccpnmr/c/PeakList.so
		ccpnmr/c/SliceFile.so
		ccpnmr/c/WinPeakList.so
		ccpnmr/c/AtomCoordList.so
		ccpnmr/c/AtomCoord.so
		ccpnmr/c/Bacus.so
		ccpnmr/c/CloudUtil.so
		ccpnmr/c/DistConstraintList.so
		ccpnmr/c/DistConstraint.so
		ccpnmr/c/DistForce.so
		ccpnmr/c/Dynamics.so
		ccpnmr/c/Midge.so
		ccp/c/StructAtom.so
		ccp/c/StructBond.so
		ccp/c/StructStructure.so
		ccp/c/StructUtil.so
		memops/c/BlockFile.so
		memops/c/FitMethod.so
		memops/c/GlHandler.so
		memops/c/MemCache.so
		memops/c/PdfHandler.so
		memops/c/PsHandler.so
		memops/c/ShapeFile.so
		memops/c/StoreFile.so
		memops/c/StoreHandler.so
		memops/c/TkHandler.so"

	for FILE in ${FILES}; do
		fperms 755 ${IN_PATH}/python/${FILE}
	done
}
