ARG MKVTOOLNIX_BIN=mkvmerge

###################Stage 0: ######################
FROM ubuntu:focal AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN \
	apt-get update && \
	apt-get -y upgrade && \
	apt-get install -y build-essential wget curl make rake xz-utils bzip2 binutils-i686-linux-gnu gcc-10-i686-linux-gnu g++-10-i686-linux-gnu binutils-x86-64-linux-gnu g++-10-x86-64-linux-gnu binutils gcc-10 g++-10 pkg-config texinfo m4 zip autoconf libtool ninja-build meson

ENV BUILD=x86_64-unknown-linux-gnu

ENV SRC=/opt/_src/

ENV MKVTOOLNIX_VER=66.0.0

ENV XZ_VER=5.2.5
ENV BZIP2_VER=1.0.8
ENV ZLIB_VER=1.2.11
ENV EXPAT_VER=2.4.7
ENV LIBICONV_VER=1.16
ENV BOOST_VER=1.78.0
ENV OGG_VER=1.3.5
ENV VORBIS_VER=1.3.7
ENV FLAC_VER=1.3.4
ENV FILE_VER=5.41
ENV PUGIXML_VER=1.12.1
ENV FMT_VER=8.1.1
ENV LIBEBML_VER=1.4.2
ENV LIBMATROSKA_VER=1.6.3
ENV GETTEXT_VER=0.21
ENV NLOHMANN_VER=3.10.5
ENV GMP_VER=6.2.1
ENV QT_VER=6.2.4
ENV CMAKE_VER=3.22.3

RUN wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VER/cmake-$CMAKE_VER-linux-x86_64.sh && \
	mv cmake-$CMAKE_VER-linux-x86_64.sh /opt/ && \
	chmod +x /opt/cmake-$CMAKE_VER-linux-x86_64.sh && \
	mkdir /opt/cmake-$CMAKE_VER-linux-x86_64 && \
	/opt/cmake-$CMAKE_VER-linux-x86_64.sh --skip-license --prefix=/opt/cmake-$CMAKE_VER-linux-x86_64 && \
	ln -s /opt/cmake-$CMAKE_VER-linux-x86_64/bin/* /usr/bin

RUN apt-get install -y libxslt-dev xsltproc docbook-xsl \
\
	&& mkdir -p $SRC && cd $SRC \
    && curl -L -O https://mkvtoolnix.download/sources/mkvtoolnix-$MKVTOOLNIX_VER.tar.xz \
\
	&& curl -L -O https://sourceforge.net/projects/lzmautils/files/xz-$XZ_VER.tar.bz2 \
	&& curl -L -O https://sourceware.org/pub/bzip2/bzip2-$BZIP2_VER.tar.gz \
	&& curl -L -O https://zlib.net/zlib-$ZLIB_VER.tar.xz \
	&& curl -L -O https://sourceforge.net/projects/expat/files/expat/$EXPAT_VER/expat-$EXPAT_VER.tar.bz2 \
	&& curl -L -O https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$LIBICONV_VER.tar.gz \
	&& curl -L -o boost-$BOOST_VER.tar.bz2 https://sourceforge.net/projects/boost/files/boost/$BOOST_VER/boost_$(echo $BOOST_VER|sed 's/\./_/g').tar.bz2 \
	&& curl -L -O https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-$OGG_VER.tar.xz \
	&& curl -L -O https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-$VORBIS_VER.tar.xz \
	&& curl -L -O https://ftp.osuosl.org/pub/xiph/releases/flac/flac-$FLAC_VER.tar.xz \
	&& curl -L -o file-$FILE_VER.tar.gz https://github.com/file/file/archive/FILE$(echo $FILE_VER|sed 's/\./_/g').tar.gz \
	&& curl -L -O https://github.com/zeux/pugixml/releases/download/v$PUGIXML_VER/pugixml-$PUGIXML_VER.tar.gz \
	&& curl -L -o fmt-$FMT_VER.tar.gz https://github.com/fmtlib/fmt/archive/$FMT_VER.tar.gz \
	&& curl -L -O https://dl.matroska.org/downloads/libebml/libebml-$LIBEBML_VER.tar.xz \
	&& curl -L -O https://dl.matroska.org/downloads/libmatroska/libmatroska-$LIBMATROSKA_VER.tar.xz \
	&& curl -L -O https://ftp.gnu.org/pub/gnu/gettext/gettext-$GETTEXT_VER.tar.gz \
	&& curl -L -o nlohmann-json-$NLOHMANN_VER.zip https://github.com/nlohmann/json/releases/download/v$NLOHMANN_VER/include.zip \
	&& curl -L -O https://gmplib.org/download/gmp/gmp-$GMP_VER.tar.xz \
	&& curl -L -o qt-$QT_VER.tar.xz https://download.qt.io/official_releases/qt/6.2/$QT_VER/single/qt-everywhere-src-$QT_VER.tar.xz \
\
	&& /bin/bash -c \
	'\
	cd $SRC; pkgs=$(ls|grep -e "\.gz$\|\.xz$\|\.bz2$\|\.zip$"); \
	for pkg in $pkgs; \
	do \
	    pkg_name=$(echo $pkg|sed -n "s/\(.\+\)\(\.tar\.gz\|\.tar\.xz\|\.tar\.bz2\|\.zip\)$/\1/p"); \
	    mkdir -p $pkg_name; \
	    case $pkg in \
	        *\.gz) \
	        tar zxvf $pkg -C $pkg_name --strip-components=1;; \
	        *\.xz) \
	        tar Jxvf $pkg -C $pkg_name --strip-components=1;; \
	        *\.bz2) \
	        tar jxvf $pkg -C $pkg_name --strip-components=1;; \
	        *\.zip) \
	        unzip $pkg -d $pkg_name;; \
	    esac; \
	done; \
	' \
	&& ln -s mkvtoolnix-$MKVTOOLNIX_VER mkvtoolnix

##################Stage 1: ######################
FROM builder AS build_x86_64

ARG MKVTOOLNIX_BIN

ENV COMPILER_PREFIX=

ENV CC ${COMPILER_PREFIX}gcc-10
ENV CXX ${COMPILER_PREFIX}g++-10
ENV AR ${COMPILER_PREFIX}ar
ENV RANLIB ${COMPILER_PREFIX}ranlib
ENV STRIP ${COMPILER_PREFIX}strip
ENV LD ${COMPILER_PREFIX}ld
ENV OBJDUMP ${COMPILER_PREFIX}objdump
ENV AS ${COMPILER_PREFIX}as
ENV NM ${COMPILER_PREFIX}nm

ARG HOST=x86_64-unknown-linux-gnu

ARG CFLAGS="-m64 -fstack-protector-strong"
ARG CXXFLAGS="-m64 -fstack-protector-strong"
ARG CPPFLAGS="-D_FILE_OFFSET_BITS=64"
ARG LDFLAGS="-m64 -fstack-protector-strong"

ARG BUILDROOT=/opt/linux
ARG PREFIX=$BUILDROOT/$HOST-build

ARG PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/

ARG CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
ARG LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

RUN	mkdir -p $PREFIX $PKG_CONFIG_PATH

RUN	mkdir -p $BUILDROOT/xz-$XZ_VER && cd $BUILDROOT/xz-$XZ_VER \
	&& $SRC/xz-$XZ_VER/configure --prefix=$PREFIX --host=$HOST --build=$BUILD --enable-static=yes \
	&& make -C src/liblzma -j $(($(nproc) + 3)) install

RUN	mkdir -p $BUILDROOT/bzip2-$BZIP2_VER && cd $BUILDROOT/bzip2-$BZIP2_VER \
	&& sed -i 's/sys\\stat\.h/sys\/stat\.h/' $SRC/bzip2-$BZIP2_VER/bzip2.c \
	&& make -C $SRC/bzip2-$BZIP2_VER -j $(($(nproc) + 3)) PREFIX=$PREFIX CC=$CC AR=$AR RANLIB=$RANLIB CFLAGS="${CFLAGS} -Wall -Winline -O2 -D_FILE_OFFSET_BITS=64" libbz2.a \
	&& install -d $PREFIX/include $PREFIX/lib && install -m644 $SRC/bzip2-$BZIP2_VER/bzlib.h $PREFIX/include/ && install -m644 $SRC/bzip2-$BZIP2_VER/libbz2.a $PREFIX/lib/

RUN	mkdir -p $BUILDROOT/zlib-$ZLIB_VER && cd $BUILDROOT/zlib-$ZLIB_VER \
	&& $SRC/zlib-$ZLIB_VER/configure --prefix=$PREFIX --static \
	&& make -j $(($(nproc) + 3)) && make install

RUN	mkdir -p $BUILDROOT/expat-$EXPAT_VER && cd $BUILDROOT/expat-$EXPAT_VER \
	&& $SRC/expat-$EXPAT_VER/configure --prefix=$PREFIX --host=$HOST --enable-static=yes --enable-shared=no --without-docbook \
	&& make -j $(($(nproc) + 3)) && make install

RUN	mkdir -p $BUILDROOT/libiconv-$LIBICONV_VER && cd $BUILDROOT/libiconv-$LIBICONV_VER \
	&& $SRC/libiconv-$LIBICONV_VER/configure --prefix=$PREFIX --host=$HOST --build=$BUILD --enable-static=yes --enable-shared=no --disable-nls \
	&& make -j $(($(nproc) + 3)) && make install

RUN	cd $SRC/boost-$BOOST_VER \
	&& echo "using gcc : : ${COMPILER_PREFIX}g++ : <archiver>${COMPILER_PREFIX}ar <ranlib>${COMPILER_PREFIX}ranlib <cxxflags>\"${CXXFLAGS}\" <linkflags>\"${LDFLAGS}\" ;" > user-config.jam \
	&& cd tools/build && CXX=g++ CXXFLAGS= LDFLAGS= ./bootstrap.sh \
	&& cd ../../ && ./tools/build/b2 \
        -a \
        -q \
        -j $(($(nproc) + 3)) \
        --ignore-site-config \
        --user-config=user-config.jam \
		-sBOOST_ROOT=$SRC/boost-$BOOST_VER \
        abi=sysv \
        address-model=64 \
        architecture=x86 \
        binary-format=elf \
        link=static \
        target-os=linux \
        threadapi=pthread \
        threading=multi \
		runtime-link=static \
        variant=release \
        toolset=gcc \
        optimization=speed \
        --layout=tagged \
        --disable-icu \
		boost.locale.iconv=on \
        --without-mpi \
        --without-python \
        --prefix=$PREFIX \
        --exec-prefix=$PREFIX/bin \
        --libdir=$PREFIX/lib \
        --includedir=$PREFIX/include \
        -sEXPAT_INCLUDE=$PREFIX/include \
        -sEXPAT_LIBPATH=$PREFIX/lib \
		-sZLIB_INCLUDE=$PREFIX/include \
		-sZLIB_LIBPATH=$PREFIX/lib \
		-sBZIP2_INCLUDE=$PREFIX/include \
		-sBZIP2_LIBPATH=$PREFIX/lib \
		-sLZMA_INCLUDE=$PREFIX/include \
		-sLZMA_LIBPATH=$PREFIX/lib \
		-sICONV_PATH=$PREFIX \
        install

RUN	mkdir -p $BUILDROOT/libogg-$OGG_VER && cd $BUILDROOT/libogg-$OGG_VER \
	&& $SRC/libogg-$OGG_VER/configure --prefix=$PREFIX --host=$HOST --enable-static=yes --enable-shared=no \
	&& make -j $(($(nproc) + 3)) && make install

RUN	mkdir -p $BUILDROOT/libvorbis-$VORBIS_VER && cd $BUILDROOT/libvorbis-$VORBIS_VER \
	&& $SRC/libvorbis-$VORBIS_VER/configure --prefix=$PREFIX --host=$HOST --enable-static=yes --enable-shared=no \
		--with-ogg=$PREFIX --enable-docs=no \
	&& make -j $(($(nproc) + 3)) && make install

RUN	mkdir -p $BUILDROOT/flac-$FLAC_VER && cd $BUILDROOT/flac-$FLAC_VER \
	&& $SRC/flac-$FLAC_VER/configure --prefix=$PREFIX --host=$HOST --enable-static=yes --enable-shared=no \
		--enable-ogg --with-ogg=$PREFIX --disable-doxygen-docs --disable-xmms-plugin \
	&& make -j $(($(nproc) + 3)) && make install

RUN	mkdir -p $BUILDROOT/file-$FILE_VER && cd $BUILDROOT/file-$FILE_VER \
	&& autoreconf -if $SRC/file-$FILE_VER \
	&& $SRC/file-$FILE_VER/configure --prefix=$PREFIX --host=$HOST --build=$BUILD --enable-static=yes --disable-silent-rules --disable-shared \
	&& make -j $(($(nproc) + 3)) && make install

RUN	mkdir -p $BUILDROOT/pugixml-$PUGIXML_VER && cd $BUILDROOT/pugixml-$PUGIXML_VER \
	&& cmake -G "Unix Makefiles" -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_INSTALL_PREFIX=$PREFIX $SRC/pugixml-$PUGIXML_VER \
	&& make -j $(($(nproc) + 3)) && make install

RUN	mkdir -p $BUILDROOT/fmt-$FMT_VER && cd $BUILDROOT/fmt-$FMT_VER \
	&& cmake -G "Unix Makefiles" -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_INSTALL_PREFIX=$PREFIX -DFMT_DOC=OFF -DFMT_TEST=OFF $SRC/fmt-$FMT_VER \
	&& make -j $(($(nproc) + 3)) && make install

RUN	mkdir -p $BUILDROOT/libebml-$LIBEBML_VER && cd $BUILDROOT/libebml-$LIBEBML_VER \
	&& cmake -G "Unix Makefiles" -DCMAKE_SYSTEM_NAME=Linux -DWIN32=OFF -DENABLE_WIN32_IO=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX $SRC/libebml-$LIBEBML_VER \
	&& make -j $(($(nproc) + 3)) && make install

RUN	mkdir -p $BUILDROOT/libmatroska-$LIBMATROSKA_VER && cd $BUILDROOT/libmatroska-$LIBMATROSKA_VER \
	&& cmake -G "Unix Makefiles" -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_INSTALL_PREFIX=$PREFIX  -DCMAKE_PREFIX_PATH=$BUILDROOT $SRC/libmatroska-$LIBMATROSKA_VER \
	&& make -j $(($(nproc) + 3)) && make install

RUN	mkdir -p $BUILDROOT/gettext-$GETTEXT_VER && cd $BUILDROOT/gettext-$GETTEXT_VER \
	&& $SRC/gettext-$GETTEXT_VER/gettext-runtime/configure --prefix=$PREFIX --host=$HOST --build=$BUILD --enable-static=yes --enable-shared=no --enable-threads=posix \
	&& make -C intl -j $(($(nproc) + 3)) install

RUN	cd $SRC/nlohmann-json-$NLOHMANN_VER \
	&& CC=gcc CXX=g++ AR=ar STRIP=strip CXXFLAGS= LDFLAGS= meson --prefix=$PREFIX --libdir=lib builddir \
	&& ninja -C builddir install

RUN	mkdir -p $BUILDROOT/gmp-$GMP_VER && cd $BUILDROOT/gmp-$GMP_VER \
	&& $SRC/gmp-$GMP_VER/configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared \
	&& make -j $(($(nproc) + 3)) && make install

RUN	mkdir -p $BUILDROOT/qt-$QT_VER && cd $BUILDROOT/qt-$QT_VER \
	&& $SRC/qt-$QT_VER/configure --release --static --opensource --confirm-license --no-opengl -skip qtwebengine -nomake examples -nomake tests -skip qt3d -skip qtactiveqt -skip qtcanvas3d -skip qtconnectivity -skip qtdatavis3d -skip qtdoc -skip qtgamepad -skip qtlocation -skip qtnetworkauth -skip qtpurchasing -skip qtremoteobjects -skip qtscxml -skip qtsensors -skip qtserialbus -skip qtserialport -skip qtspeech -skip qtquick3d -skip qtvirtualkeyboard -skip qtwebview -skip qtscript --prefix=$PREFIX \
	&& cmake --build . --parallel && cmake --install .


RUN	cd $SRC/mkvtoolnix \
	&& ./configure --disable-gui --enable-update-check=no --enable-static=yes --with-qmake6=$PREFIX/bin/qmake6 \
		--with-boost=$PREFIX --host=$HOST \
	&& rake apps:strip

###################Stage 2: ######################
FROM mkvtoolnix

ARG MKVTOOLNIX_BIN

COPY --from=build_x86_64 /opt/_src/mkvtoolnix-$MKVTOOLNIX_VER/src/$MKVTOOLNIX_BIN /x86_64/
