# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="DRY and RAD for regular expressions"
HOMEPAGE="https://github.com/jordansissel/grok http://code.google.com/p/semicomplete/wiki/Grok"
SRC_URI="https://github.com/jordansissel/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

DEPEND="dev-libs/tokyocabinet
		>=dev-libs/libevent-1.3
		>=dev-libs/libpcre-7.6"

RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${PV}-*.patch
}

src_install() {
	dosym /usr/$(get_libdir)/lib${PN}.so.1 /usr/$(get_libdir)/lib${PN}.so
}