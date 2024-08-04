module erl_nif;
import std::io;

const int ERL_NIF_MAJOR_VERSION = 2;
const int ERL_NIF_MINOR_VERSION = 17;
const char* ERL_NIF_MIN_ERTS_VERSION = "erts-14.0";

def ErlNifTerm = ulong;

struct Enif_environment_t {
	char[1] _unused;
}
def ErlNifEnv = Enif_environment_t;

def ErlNifFuncPtr = fn ErlNifTerm(
    ErlNifEnv* env,
    int argc,
    ErlNifTerm* argv
);

struct ErlNifFunc {
    char* name;
    uint arity;
    ErlNifFuncPtr fptr;
    uint flags;
}

def ErlNifLoadFunc = fn int(ErlNifEnv*, void*, ErlNifTerm);
def ErlNifUpgradeFunc = fn int(ErlNifEnv*, void*, void*, ErlNifTerm);
def ErlNifUnloadFunc = fn void(ErlNifEnv*, void*);

struct ErlNifEntry {
    int major;
    int minor;
    char* name;
    int num_of_funcs;
    ErlNifFunc* funcs;
    ErlNifLoadFunc* load;
    ErlNifLoadFunc* reload;
    ErlNifUpgradeFunc* upgrade;
    ErlNifUnloadFunc* unload;
    char* vm_variant;
    ulong options;
    ulong sizeof_ErlNifResourceTypeInit;
    char* min_erts;
}

enum ErlNifCharEncoding : int (int value) {
    ERL_NIF_LATIN1 = 1,
    ERL_NIF_UTF8 = 2,
}

struct ErlNifPid {
    ErlNifTerm pid;
}
struct ErlDrvMonitor {
    char[32] data;
}
def ErlNifMonitor = ErlDrvMonitor;

def ErlNifEvent = int;
def ErlNifResourceDtor = fn void(ErlNifEnv*, void*);
def ErlNifResourceStop = fn void(ErlNifEnv*, void*, ErlNifEvent, int);
def ErlNifResourceDown = fn void(ErlNifEnv*, void*, ErlNifPid*, ErlNifMonitor*);
def ErlNifResourceDynCall = fn void(ErlNifEnv*, void*, void*);

struct ErlNifResourceTypeInit {
    ErlNifResourceDtor* dtor;
    ErlNifResourceStop* stop;
    ErlNifResourceDown* down;
    int members;
    ErlNifResourceDynCall* dyncall;
}

fn ErlNifTerm enif_make_string(ErlNifEnv* env, char* str, ErlNifCharEncoding enc) {
   return _enif_make_string(env, str, enc.value);
}

extern fn ErlNifTerm _enif_make_string(ErlNifEnv*, char*, int) @extern("enif_make_string");
extern fn ErlNifTerm enif_make_int(ErlNifEnv*, int);
extern fn ErlNifTerm enif_make_badarg(ErlNifEnv* env);
extern fn int enif_get_int(ErlNifEnv*, ErlNifTerm, int*);

const ErlNifFunc[*] NIF_FUNCS = {
    {"hello", 0, &hello, 0},
    {"add", 2, &add, 0},
};

const ErlNifEntry NIF_ENTRY = {
    ERL_NIF_MAJOR_VERSION,
    ERL_NIF_MINOR_VERSION,
    "Elixir.C3ErlNif",
    NIF_FUNCS.len,
    &NIF_FUNCS,
    null,
    null,
    null,
    null,
    "beam.vanilla",
    1,
    ErlNifResourceTypeInit.sizeof,
    ERL_NIF_MIN_ERTS_VERSION
};

fn ErlNifEntry* nif_init() @export("nif_init") {
    io::printn("nif_init");
    return &NIF_ENTRY;
}

fn ErlNifTerm hello(ErlNifEnv* env, int argc, ErlNifTerm* argv)
{
    char* hello = "Hello World";
    ErlNifTerm result = enif_make_string(env, hello, ErlNifCharEncoding.ERL_NIF_LATIN1);
    io::printn(ErlNifCharEncoding.ERL_NIF_LATIN1.value);
    io::printfn("result = %s", result);
    return result;
}

fn ErlNifTerm add(ErlNifEnv* env, int argc, ErlNifTerm* argv)
{
    int a;
    int b;

    if (argc != 2) {
        return enif_make_badarg(env);
    }

    enif_get_int(env, argv[0], &a);
    enif_get_int(env, argv[1], &b);

    int result = a + b;
    io::printfn("result = %d", result);

    //return enif_make_string(env, "Hello World", ErlNifCharEncoding.ERL_NIF_LATIN1);
    return enif_make_int(env, result);
}
