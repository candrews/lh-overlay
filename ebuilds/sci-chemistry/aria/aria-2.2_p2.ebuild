# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

NEED_PYTHON=2.3

inherit python eutils

MY_P="${PN}${PV}"
SLOT="0"
LICENSE="cns"
KEYWORDS="~x86"
DESCRIPTION="Software for automated NOE assignment and NMR structure calculation."
SRC_URI="http://aria.pasteur.fr/archives/${MY_P}.tar.gz"
HOMEPAGE="http://aria.pasteur.fr/"
IUSE="examples"
RESTRICT="fetch"
DEPEND="sci-chemistry/cns[aria]
	|| ( dev-python/numpy dev-python/numeric )
	>=dev-python/scientificpython-2.7.3
	>=dev-lang/tk-8.3
	>=dev-tcltk/tix-8.1.4
	>=sci-chemistry/ccpn-2.0.5
	dev-python/matplotlib[tk]"
RDEPEND=""

S="${WORKDIR}/${PN}2.2"

pkg_nofetch(){
	einfo "Go to ${HOMEPAGE}, download ${A}"
	einfo "and place it in ${DISTDIR}"
}

pkg_setup(){
	python_version
	python_tkinter_exists
}

src_unpack(){
	unpack ${A}
	epatch "${FILESDIR}"/sa_ls_cool2.patch
}

src_test(){
	export CCPNMR_TOP_DIR=$(python_get_sitedir)
        export PYTHONPATH=.:${CCPNMR_TOP_DIR}/ccpn/python
	${python} check.py || die
}

src_install(){
	insinto "$(python_get_sitedir)/${PN}"
	doins -r src aria2.py || die "failed to install ${PN}"
	insinto "$(python_get_sitedir)/${PN}"/cns
	doins -r cns/{protocols,toppar,src/helplib} || die "failed to install cns part"

	if use examples; then
		insinto /usr/share/${P}/
		doins -r examples
	fi

# ENV
	cat >> "${T}"/20aria <<- EOF
	ARIA2="$(python_get_sitedir)/${PN}"
	EOF

	doenvd "${T}"/20aria

# Launch Wrapper
	cat >> "${T}"/aria <<- EOF
	#!/bin/sh
	export CCPNMR_TOP_DIR=$(python_get_sitedir)
	export PYTHONPATH=.:${CCPNMR_TOP_DIR}/ccpn/python
	exec "${python}" -O "\${ARIA2}"/aria2.py \$@
	EOF

	dobin "${T}"/aria || die "failed to install wrapper"
	dosym aria /usr/bin/aria2

	dodoc COPYRIGHT README
}
