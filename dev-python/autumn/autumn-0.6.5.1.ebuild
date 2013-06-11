# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} )

inherit distutils-r1

MY_P="${PN}2-${PV}"

DESCRIPTION="A super-lightweight Object-relational mapper (ORM) for Python"
HOMEPAGE="https://pypi.python.org/pypi/autumn2/"
SRC_URI="mirror://pypi/a/autumn2/${MY_P}.tar.gz"

SLOT="0"
LICENSE="MIT"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}"/${MY_P}
