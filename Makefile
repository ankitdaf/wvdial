
prefix=/usr/local
WVSTREAMS_INC=
WVSTREAMS_LIB=
WVSTREAMS_BIN=$(prefix)/bin
WVSTREAMS_SRC=.

PC_CFLAGS=$(shell pkg-config --cflags libwvstreams)
ifeq ($(PC_CFLAGS),)
 $(error WvStreams does not appear to be installed)
endif
CPPFLAGS+=$(PC_CFLAGS)

PC_LIBS=$(shell pkg-config --libs libwvstreams)
ifeq ($(PC_LIBS),)
 $(error WvStreams does not appear to be installed)
endif
LIBS+=$(PC_LIBS)

BINDIR=${prefix}/bin
MANDIR=${prefix}/share/man
PPPDIR=/etc/ppp/peers

include wvrules.mk
include config.mk

config.mk:
	@echo "Please run ./configure. Stop."
	@exit 1

default: all papchaptest
all: wvdial.a wvdial wvdialconf pppmon

wvdial.a: wvdialer.o wvmodemscan.o wvpapchap.o wvdialbrain.o \
	wvdialmon.o

wvdial wvdialconf papchaptest pppmon: \
  LDFLAGS+=-luniconf -lwvstreams -lwvutils -lwvbase

wvdial wvdialconf papchaptest pppmon: wvdial.a

install-bin: all
	[ -d ${BINDIR}      ] || install -d ${BINDIR}
	[ -d ${PPPDIR}      ] || install -d ${PPPDIR}
	install -m 0755 wvdial wvdialconf ${BINDIR}
	cp ppp.provider ${PPPDIR}/wvdial
	cp ppp.provider-pipe ${PPPDIR}/wvdial-pipe

install-man:
	[ -d ${MANDIR}/man1 ] || install -d ${MANDIR}/man1
	[ -d ${MANDIR}/man5 ] || install -d ${MANDIR}/man5
	install -m 0644 wvdial.1 wvdialconf.1 ${MANDIR}/man1
	install -m 0644 wvdial.conf.5 ${MANDIR}/man5

install: install-bin install-man

uninstall-bin:
	rm -f ${BINDIR}/wvdial ${BINDIR}/wvdialconf
	rm -f ${PPPDIR}/wvdial
	rm -f ${PPPDIR}/wvdial-pipe

uninstall-man:
	rm -f ${MANDIR}/man1/wvdial.1 ${MANDIR}/man1/wvdialconf.1
	rm -f ${MANDIR}/man5/wvdial.conf.5

uninstall: uninstall-bin uninstall-man

clean:
	rm -f wvdial wvdialconf wvdialmon papchaptest pppmon

distclean:
	rm -f version.h config.mk

.PHONY: clean all install-bin install-man install uninstall-bin uninstall-man \
	uninstall
