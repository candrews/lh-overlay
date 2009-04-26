# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $


inherit eutils

SLOT="0"
LICENSE="as-is"
KEYWORDS="~x86"
DESCRIPTION="Automatic dump of an SVN repository"
SRC_URI="http://gentoo.j-schmitz.net/private-overlay/distfiles/app-admin/rsync-update/${P}.tar.bz2"
HOMEPAGE="http://www.j-schmitz.net"
IUSE=""
RESTRICT="primaryuri"

src_install(){
	exeinto /usr/lib/rsync-update
	doexe rsync-update.sh

	insinto /etc/
	doins rsync-update.conf

	dosym /usr/lib/rsync-update/rsync-update.sh /usr/bin/rsync-update
}
