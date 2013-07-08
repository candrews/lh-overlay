# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils java-pkg-2 java-ant-2 

MY_P="${P}-src"
UPSTREAM_R="r1499"

DESCRIPTION="A tool for creating a project schedule by means of Gantt chart and resource load chart."
HOMEPAGE="http://ganttproject.sourceforge.net/"
SRC_URI="https://${PN}.googlecode.com/files/${P}-${UPSTREAM_R}-src.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

CDEPEND="
	dev-java/commons-codec
	dev-java/commons-io
	dev-java/commons-logging
	dev-java/commons-net
	dev-java/httpcomponents-client
	dev-java/httpcomponents-core
	dev-java/slf4j[simple]
	dev-java/jcommander
	dev-java/jdom
	dev-java/jgoodies-common
	dev-java/jgoodies-looks:2.0
	dev-java/eclipsito
"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.5"
DEPEND="${CDEPEND}
	app-arch/unzip
	>=virtual/jdk-1.5"


S="${WORKDIR}/${P}-${UPSTREAM_R}-src"

EANT_BUILD_XML="${PN}-builder/build.xml"
EANT_BUILD_TARGET="build"
EANT_GENTOO_CLASSPATH="
	commons-codec
	commons-io-1
	commons-logging
	commons-net
	eclipsito
	httpcomponents-client
	httpcomponents-core
	jcommander
	jdom-1.0
	jgoodies-common
	jgoodies-looks-2.0
"
JAVA_ANT_REWRITE_CLASSPATH="yes"

# TODO: UNBUNDLE: fop, poi and itext

MODULES="biz.ganttproject.core biz.ganttproject.impex.msproject2 ganttproject \
		org.ganttproject.chart.pert org.ganttproject.impex.htmlpdf"

src_prepare() {
	# The build.xml files in the component subdirs contain a references to the 
	# build-user.xml files as a reference in a comment which gets removed if we use the 
	# ant xml rewriting. Plus, the build-user.xml don't contain a full build.xml but
	# only the content of the <project> node. So we build a new build.xml file 
	# and let the magic begin
	for mod in ${MODULES}; do
		grep "<project" ${mod}/build.xml >> ${mod}/build-new.xml || die
		cat ${mod}/build-user.xml >> ${mod}/build-new.xml || die
		echo '</project>' >> ${mod}/build-new.xml || die
		mv ${mod}/build-new.xml ${mod}/build.xml || die
	done

	sed -i -e 's/.*eclipsito\.jar.*//g' "${S}"/${PN}/build.xml || die
	
	rm "${S}"/${PN}/lib/core/{eclipsito,httpclient,httpcore,jdom,slf4j,jgoodies,jcommander}*.jar || die
	rm "${S}"/${PN}/lib/core/commons-{codec,io,logging,net}*.jar || die
}

src_install() {
	insinto "/usr/share/${PN}/"
	doins "${S}"/${PN}-builder/${PN}-eclipsito-config.xml
	java-pkg_addcp "/usr/share/${PN}/"

	prefix="${S}"/${PN}-builder/dist-bin/plugins/
	pbase="/usr/share/${PN}/lib/plugins"
	
	_ins_mod() {
		dest="${pbase}/${1}/"
		insinto ${dest}
		doins ${prefix}/${1}/plugin.xml
		java-pkg_jarinto ${dest}
		java-pkg_dojar ${prefix}/${1}/${2}
	}
	
	_ins_mod "org.ganttproject.chart.pert" "pert.jar"
	_ins_mod "biz.ganttproject.impex.msproject2" "ganttproject-msproject2.jar"
	_ins_mod "org.ganttproject.impex.htmlpdf" "ganttproject-htmlpdf.jar"
	_ins_mod "net.sourceforge.ganttproject" "ganttproject.jar"
	_ins_mod "biz.ganttproject.core" "ganttproject-core.jar"
	
	## needed in .../lib due to eclipsito
	insinto "${pbase}/net.sourceforge.ganttproject/data/"
	doins -r ${prefix}/net.sourceforge.ganttproject/data/*

	for mod in ${MODULES} net.sourceforge.ganttproject; do
		libdir="lib"
		[ -d ${prefix}/${mod}/lib/core ] && libdir="lib/core"
		srcdir="${prefix}/${mod}/${libdir}"
		if [ -d ${srcdir} ]; then
			for lib in ${srcdir}/*.jar; do
				insinto "${pbase}/${mod}/${libdir}"
				doins ${prefix}/${mod}/${libdir}/$(basename ${lib})
			done
		fi
	done

	java-pkg_dolauncher ${PN} --main "org.bardsoftware.eclipsito.Boot" \
		--pkg_args "/usr/share/${PN}/lib/ganttproject-eclipsito-config.xml"
}
