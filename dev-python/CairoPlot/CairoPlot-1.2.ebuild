# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1

DESCRIPTION="Plot graphics in an easy and intuitive way"
HOMEPAGE="
	https://launchpad.net/cairoplot/
	http://linil.wordpress.com/2008/09/16/cairoplot-11/
	http://cairoplot.sourceforge.net/index.html
	"
SRC_URI="https://github.com/rodrigoaraujo01/cairoplot/archive/1.2.tar.gz -> ${P}.tgz"

SLOT="0"
LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-python/pycairo[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"

S="${WORKDIR}"/cairoplot-${PV}/trunk

python_test() {
	${EPYTHON} tests.py || die
	${EPYTHON} seriestests.py || die
}
