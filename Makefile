all: niftest erl_nif

clean:
	rm -f *.o *.so

ERL_ROOT=/opt/homebrew/Cellar/erlang/26.2.5/lib/erlang
niftest: niftest.c
	gcc -fPIC -g -O3 -ansi -pedantic -Wall -undefined dynamic_lookup -I $(ERL_ROOT)/erts-*/include/ -o niftest.so niftest.c
	gcc -I $(ERL_ROOT)/erts-*/include/ -E niftest.c -o niftest_preprocessed.c

erl_nif: erl_nif.c3
	c3c --no-entry --use-stdlib=no -z "-fno-pie -fPIC -g -bundle -flat_namespace -undefined dynamic_lookup" compile -o erl_nif.so erl_nif.c3
