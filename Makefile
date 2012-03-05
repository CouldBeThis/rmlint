#source dir
SOURCEDIR=src
DOCDIR=doc

#MANDIR
MANDIR=$(DESTDIR)/usr/share/man/man1
#MANUAL
MANDOC=rmlint.1.gz

#install
INSTALLPATH=$(DESTDIR)/usr/bin

#Programs 
ECHO=echo
RM=rm -rf
CAT=cat
CP=cp
STRIP=strip -s
MKDIR=mkdir -p

#compiling stuff
CC=gcc

#Heavy Warnlevel 
WARN=-Wall -pedantic -std=c99 

ifeq ($(CC),gcc)
  OPTI=-march=native -O0 -s -finline-functions
else
  OPTI=-march=native -Os -s -finline-functions
endif

#Link with google's malloc
TCMALLOC=-fno-builtin-malloc -fno-builtin-calloc -fno-builtin-realloc -fno-builtin-free -L tcmalloc/libtcmalloc_minimal.a -D_THREAD_SAFE

#also use -pipe 

ifdef DEBUG
  CFLAGS=-c -pipe -ggdb3 $(WARN) $(TCMALLOC) -D_FILE_OFFSET_BITS=64
else
  CFLAGS=-c -pipe $(OPTI) $(WARN) $(TCMALLOC) -D_FILE_OFFSET_BITS=64
endif

#Link flags 
LDFLAGS=-lpthread -lm

SOURCES= \
	$(SOURCEDIR)/md5.c \
	$(SOURCEDIR)/filter.c \
	$(SOURCEDIR)/mode.c \
	$(SOURCEDIR)/list.c \
	$(SOURCEDIR)/rmlint.c \
	$(SOURCEDIR)/main.c


OBJECTS=$(SOURCES:.c=.o)
INCLUDE=
EXECUTABLE=rmlint 

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE):  $(OBJECTS)
		 @$(CC) $(OBJECTS) -o $@ $(LDFLAGS)
ifdef DEBUG
	     @$(ECHO) "=> Building debug target."
else
	     @$(STRIP) $(EXECUTABLE)
	     @$(ECHO) "=> Stripping program done."
endif
	     @$(ECHO) "=> Linking program done."  

.c.o: 	
	@$(ECHO) "-> Compiling $<"
	@$(CC) $(INCLUDE) $(CFLAGS) $< -o $@

.PHONY : clean
clean:
	@$(ECHO) "<> Making clean."
	@$(RM) $(SOURCEDIR)/*.o $(EXECUTABLE) 2> /dev/null

.PHONY : install
install: 
	@$(MKDIR) $(INSTALLPATH)
	@$(ECHO) "++ Copying executable to $(INSTALLPATH)"
	@$(CP) $(EXECUTABLE) $(INSTALLPATH)
	@$(MKDIR) $(MANDIR)
	@$(ECHO) "++ Copying manpage to $(MANDIR)."
	@$(CP) "$(DOCDIR)/$(MANDOC)" $(MANDIR)

.PHONY : uninstall
uninstall:
	@$(ECHO) "-- Removing the lint of rmlint" 
	$(RM) "$(INSTALLPATH)/$(EXECUTABLE)"
	$(RM) "$(MANDIR)/$(MANDOC)"