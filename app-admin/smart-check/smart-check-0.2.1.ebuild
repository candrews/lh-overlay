# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{3,4} )

inherit distutils-r1

DESCRIPTION="A smart S.M.A.R.T. check"
HOMEPAGE="https://ercpe.de/projects/smart-check"
SRC_URI="https://code.not-your-server.de/${PN}.git/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="dev-python/pyyaml[${PYTHON_USEDEP}]
		sys-apps/smartmontools"

src_install() {
	distutils-r1_src_install

	python_foreach_impl python_newscript "${S}"/src/${PN/-/}/main.py ${PN}
}
