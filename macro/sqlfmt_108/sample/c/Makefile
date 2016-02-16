#---------------------------------------------------------------
# Borland C/C++ Compiler 用 Makefile
#---------------------------------------------------------------

dists_home = ../../  # 製品ホーム・ディレクトリ

CFLAGS = -w -I. -I$(dists_home)
LFLAGS = -L$(dists_home)

name = main
objs = $(name).obj
libs = sqlfmt.lib
exe = $(name).exe

all:
	make $(exe)

clean: 
	del $(objs) $(exe) $(name).tds $(name).tr2 

debug:
	$(CC) $(CFLAGS) $(LFLAGS) -e$(exe) -v $(libs) $(name).c
	start td32 $(exe)

$(exe): $(objs)
	$(CC) $(LFLAGS) -e$@ $** $(libs)

$(objs): $(dists_home)sqlfmt.lib 
