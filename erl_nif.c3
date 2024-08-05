module erl_nif;

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

fn ErlNifTerm enif_make_string(ErlNifEnv* env, char* str, ErlNifCharEncoding enc = ErlNifCharEncoding.ERL_NIF_LATIN1) {
   return _enif_make_string(env, str, enc.value);
}

fn ErlNifTerm enif_make_tuple(ErlNifEnv* env, ErlNifTerm[] arr) {
    return enif_make_tuple_from_array(env, arr, arr.len);
}

fn ErlNifTerm enif_make_tuple2(ErlNifEnv* env, ErlNifTerm t1, ErlNifTerm t2) {
    return enif_make_tuple(env, {t1, t2});
}

fn ErlNifTerm enif_make_list(ErlNifEnv* env, ErlNifTerm[] arr) {
    return enif_make_list_from_array(env, arr, arr.len);
}

extern fn ErlNifTerm _enif_make_string(ErlNifEnv*, char*, int) @extern("enif_make_string");
extern fn ErlNifTerm enif_make_int(ErlNifEnv*, int);
extern fn ErlNifTerm enif_make_badarg(ErlNifEnv*);
extern fn int enif_get_int(ErlNifEnv*, ErlNifTerm, int*);
extern fn ErlNifTerm enif_make_atom(ErlNifEnv*, char*);
extern fn ErlNifTerm enif_make_list_from_array(ErlNifEnv*, ErlNifTerm[], uint);
extern fn ErlNifTerm enif_make_tuple_from_array(ErlNifEnv*, ErlNifTerm[], uint);

const ErlNifFunc[*] NIF_FUNCS = {
    {"hello", 0, &hello, 0},
    {"add", 2, &add, 0},
    {"atom", 0, &atom, 0},
    {"tuple", 0, &tuple, 0},
    {"tuple2", 0, &tuple2, 0},
    {"list", 0, &list, 0},
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
    return &NIF_ENTRY;
}

fn ErlNifTerm hello(ErlNifEnv* env, int argc, ErlNifTerm* argv)
{
    ErlNifTerm result = enif_make_string(env, "Hello World", ErlNifCharEncoding.ERL_NIF_LATIN1);
    return result;
}

fn ErlNifTerm atom(ErlNifEnv* env, int argc, ErlNifTerm* argv)
{
    ErlNifTerm result = enif_make_atom(env, "atom");
    return result;
}

fn ErlNifTerm tuple(ErlNifEnv* env, int argc, ErlNifTerm* argv)
{
    ErlNifTerm t1 = enif_make_atom(env, "error");
    ErlNifTerm t2 = enif_make_atom(env, "not_implemented");
    return enif_make_tuple(env, {t1, t2});
}

fn ErlNifTerm tuple2(ErlNifEnv* env, int argc, ErlNifTerm* argv)
{
    return enif_make_tuple2(
        env,
        enif_make_atom(env, "error"),
        enif_make_string(env, "not found", ErlNifCharEncoding.ERL_NIF_LATIN1)
    );
}

fn ErlNifTerm list(ErlNifEnv* env, int argc, ErlNifTerm* argv)
{
    ErlNifTerm t1 = enif_make_atom(env, "error");
    ErlNifTerm t2 = enif_make_atom(env, "not_implemented");
    ErlNifTerm t3 = enif_make_int(env, 666);
    ErlNifTerm t4 = enif_make_string(env, "a string");
    return enif_make_list(env, {t1, t2, t3, t4});
}

fn ErlNifTerm add(ErlNifEnv* env, int argc, ErlNifTerm* argv)
{
    if (argc != 2) {
        return enif_make_badarg(env);
    }

    int a;
    int b;

    enif_get_int(env, argv[0], &a);
    enif_get_int(env, argv[1], &b);

    int result = a + b;
    return enif_make_int(env, result);
}
