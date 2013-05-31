# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

NEED_PYTHON=2.4
PYTHON_MODNAME="chempy pmg_tk pymol"

inherit distutils multilib subversion

ESVN_REPO_URI="https://pymol.svn.sourceforge.net/svnroot/pymol/branches/b11/pymol"

DESCRIPTION="A Python-extensible molecular graphics system."
HOMEPAGE="http://pymol.sourceforge.net/"

LICENSE="PSF-2.2"
IUSE="apbs shaders"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-python/pmw
	dev-python/numeric
	dev-lang/tk
	media-libs/libpng
	sys-libs/zlib
	virtual/glut
	apbs? ( dev-libs/maloc
		sci-chemistry/apbs
		sci-chemistry/pdb2pqr
	)"
DEPEND="${RDEPEND}"

pkg_setup(){
	python_tkinter_exists
	python_version
}

src_unpack() {
	subversion_src_unpack

	epatch "${FILESDIR}"/${PF}-data-path.patch

	# Turn off splash screen.  Please do make a project contribution
	# if you are able though.
	[[ -z "$WANT_SPLASH" ]] && epatch "${FILESDIR}"/nosplash-gentoo.patch

	# Respect CFLAGS
	sed -i \
		-e "s:\(ext_comp_args=\).*:\1[]:g" \
		"${S}"/setup.py

	if use shaders; then
		epatch "${FILESDIR}"/${PF}-shaders.patch
	fi

	if use apbs; then
		epatch "${FILESDIR}"/apbs-070604.patch.bz2
		sed "s:LIBANDPYTHON:$(get_libdir)/python${PYVER}:g" \
			-i modules/pmg_tk/startup/apbs_tools.py || die
	fi
}

src_install() {
	distutils_src_install
	cd "${S}"

	#The following three lines probably do not do their jobs and should be
	#changed
	PYTHONPATH="${D}$(python_get_sitedir)" ${python} setup2.py

	# These environment variables should not go in the wrapper script, or else
	# it will be impossible to use the PyMOL libraries from Python.
	cat >> "${T}"/20pymol <<- EOF
	PYMOL_PATH=$(python_get_sitedir)/pymol
	PYMOL_DATA="/usr/share/pymol/data"
	PYMOL_SCRIPTS="/usr/share/pymol/scripts"
	EOF

	doenvd "${T}"/20pymol || die "Failed to install env.d file."

	# Make our own wrapper
	cat >> "${T}"/pymol <<- EOF
	#!/bin/sh
	${python} -O \${PYMOL_PATH}/__init__.py \$*
	EOF

	if ! use apbs; then
		rm "${D}"$(python_get_sitedir)/pmg_tk/startup/apbs_tools.py
	fi

	exeinto /usr/bin
	doexe "${T}"/pymol || die "Failed to install wrapper."
	dodoc DEVELOPERS || die "Failed to install docs."

	mv examples "${D}"/usr/share/doc/${PF}/ || die "Failed moving docs."

	dodir /usr/share/pymol
	mv test "${D}"/usr/share/pymol/ || die "Failed moving test files."
	mv data "${D}"/usr/share/pymol/ || die "Failed moving data files."
	mv scripts "${D}"/usr/share/pymol/ || die "Failed moving scripts."
}

pkg_postinst() {
	distutils_pkg_postinst

	# The apbs ebuild was just corrected and not bumped #213616
	if use apbs; then
		[[ -e /usr/share/apbs-0.5* ]] && \
		ewarn "You need to reemerge sci-chemistry/apbs!"
	fi
}
