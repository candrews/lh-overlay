# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils eutils

DESCRIPTION="A graphical and console tool for exploring the size of directories"
HOMEPAGE="http://guichaz.free.fr/pysize/"
SRC_URI="http://guichaz.free.fr/${PN}/files/${P}.tar.bz2"

LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="gtk ncurses psyco"
DEPEND="gtk? ( dev-python/pygtk )
	ncurses? ( sys-libs/ncurses )
	psyco? ( dev-python/psyco )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	if ! use gtk; then
		sed -e '/^from pysize.ui.gtk/d' \
		    -e "s~'gtk': ui_gtk.run,~~g" \
		    -e 's:ui_gtk.run,::g' \
		    -i pysize/main.py || die
		rm -rf pysize/ui/gtk || die
	fi

	if ! use ncurses; then
		sed -e '/^from pysize.ui.curses/d' \
		    -e "s~'curses': ui_curses.run,~~g" \
		    -e 's:ui_curses.run,::g' \
		    -i pysize/main.py || die
		rm -rf pysize/ui/curses || die
	fi

	use psyco && epatch "${FILESDIR}"/psyco-dep.patch
}


src_install() {
	distutils_src_install

	dobin bin/${PN} || die
}
