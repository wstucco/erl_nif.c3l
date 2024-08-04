all: clean niftest erl_nif

clean:
	rm -f *.o 2>/dev/null
	rm -f erl_nif.so 2>/dev/null

ERL_ROOT=/opt/homebrew/Cellar/erlang/26.2.5/lib/erlang
niftest: niftest.c
	gcc -fPIC -g -O3 -ansi -pedantic -Wall -bundle -bundle_loader $(ERL_ROOT)/erts-*/bin/beam.smp -I $(ERL_ROOT)/erts-*/include/ -o niftest.so niftest.c
	gcc -I $(ERL_ROOT)/erts-*/include/ -E niftest.c -o niftest_preprocessed.c

erl_nif: erl_nif.c3
	~/Downloads/macos/c3c --no-entry -z "-fPIC -g -bundle -bundle_loader $(ERL_ROOT)/erts-*/bin/beam.smp" compile -o erl_nif.so erl_nif.c3
