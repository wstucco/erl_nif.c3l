all: erl_nif

clean:
	rm -f *.o *.so

erl_nif: erl_nif.c3
	c3c --no-entry --use-stdlib=no -z "-fno-pie -fPIC -g -bundle -flat_namespace -undefined dynamic_lookup" compile -o erl_nif.so erl_nif.c3
