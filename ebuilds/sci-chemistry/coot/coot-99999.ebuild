# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools eutils subversion

DESCRIPTION="Crystallographic Object-Oriented Toolkit for model building, completion and validation"
HOMEPAGE="http://www.ysbl.york.ac.uk/~emsley/coot/"
ESVN_REPO_URI="http://coot.googlecode.com/svn/trunk/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 -*"
IUSE=""
RDEPEND=">=sci-libs/gsl-1.3
	>=x11-libs/gtk+-2.2
	gnome-base/libgnomecanvas
	=x11-libs/guile-gtk-2*
	x11-libs/gtkglext
	virtual/glut
	virtual/opengl
	sci-chemistry/ccp4
	dev-lang/python
	dev-scheme/guile-gui
	dev-scheme/net-http
	dev-scheme/goosh
	dev-scheme/guile-www
	sci-libs/coot-data
	sci-chemistry/reduce
	sci-chemistry/probe
	>=sci-libs/clipper-20070907
	<sci-libs/mmdb-1.0.10"
# These are still required to run autoreconf
RDEPEND="${RDEPEND}
	=dev-libs/glib-1.2*
	=x11-libs/gtkglarea-1.2*"
DEPEND="${RDEPEND}
	dev-lang/swig"
S="${WORKDIR}"

src_unpack() {
	subversion_src_unpack
	cd "${S}"

	# To send upstream
#	epatch "${FILESDIR}"/0.5_pre1-gcc-4.3.patch

#	epatch "${FILESDIR}"/${PV}-as-needed.patch.bz2
#	epatch "${FILESDIR}"/${PV}-include-ccp4mg-utils.patch
	epatch "${FILESDIR}"/0.4.1-link-against-guile-gtk-properly.patch
	epatch "${FILESDIR}"/0.4.1-fix-namespace-error.patch

	# Link against single-precision fftw
	sed -i \
		-e "s:lfttw:lsfttw:g" \
		-e "s:lrfttw:lsrfttw:g" \
		"${S}"/macros/clipper.m4

	# Fix where it looks for some binaries
	sed -i \
		-e "s:/y/people/emsley/coot/Linux/bin/probe.2.11.050121.linux.RH9:/usr/bin/probe:g" \
		-e "s:/y/people/emsley/coot/Linux/bin/reduce.2.21.030604:/usr/bin/reduce:g" \
		"${S}"/scheme/group-settings.scm

	# Look for clipper slotted with '-2' suffix
	sed -i \
		-e "s~\(-lclipper[[:alnum:]-]*\)~\1-2~g" \
		"${S}"/macros/clipper.m4 \
		|| die "sed to find -2 slotted libraries failed"
	grep 'include.*clipper' -rl . \
		| xargs sed -i \
			-e "s~\(include.*clipper\)/~\1-2/~g" \
			|| die "sed to find -2 slotted headers failed"

	cd "${S}"
	AT_M4DIR="macros" eautoreconf
}

src_compile() {
	# All the --with's are used to activate various parts.
	# Yes, this is broken behavior.
	econf \
		--includedir='${prefix}/include/coot' \
		--with-gtkcanvas-prefix=/usr \
		--with-clipper-prefix=/usr \
		--with-mmdb-prefix=/usr \
		--with-ssmlib-prefix=/usr \
		--with-guile=/usr \
		--with-python=/usr \
		--with-pygtk=/usr \
		--with-guile-gtk \
		--with-gtk2 \
		|| die "econf failed"

	# Regenerate wrappers, otherwise at least gtk-2 build fails
	pushd src
	rm -f coot_wrap_python.cc coot_wrap_python_pre.cc \
		&& emake coot_wrap_python.cc \
		|| die "failed to regenerate python wrapper"

	rm -f coot_wrap_guile.cc coot_wrap_guile_pre.cc \
		&& emake coot_wrap_guile.cc \
		||die "failed to regenerate guile wrapper"
	popd

	# Parallel build's broken
	emake -j1 || die "emake failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "install failed"

	# Install misses this
	insinto /usr/share/coot/python
	doins "${S}"/src/coot.py
}
