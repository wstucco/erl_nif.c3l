module erl;
import enif;

// CONSTS
const NIF_MAJOR_VERSION = enif::ERL_NIF_MAJOR_VERSION;
const NIF_MINOR_VERSION = enif::ERL_NIF_MINOR_VERSION;
const NIF_MIN_ERTS_VERSION = enif::ERL_NIF_MIN_ERTS_VERSION;

// FAULTS
fault Err
{
    INVALID_OR_OUT_OF_BOUNDS_INT
}

// TYPEDEFS
distinct ZString = inline char*;
distinct NifEntry = ErlNifEntry;
def NifEnv = ErlNifEnv;
def NifFunc = ErlNifFunc;
distinct NifFuncPtr = ErlNifFuncPtr;
distinct NifResourceTypeInit = ErlNifResourceTypeInit;
def NifTerm = ErlNifTerm;

// ENUMS
enum NifCharEncoding : int (uint value) {
    ERL_NIF_LATIN1 = 1,
    ERL_NIF_UTF8 = 2,
}

// API
fn NifTerm make_atom(NifEnv* env, ZString name) {
    return enif::make_atom(env, name);
}

fn NifTerm make_int(NifEnv* env, int i) {
    return enif::make_int(env, i);
}

fn NifTerm make_string(NifEnv* env, char* str, NifCharEncoding enc = NifCharEncoding.ERL_NIF_LATIN1) {
   return enif::make_string(env, str, enc.value);
}

fn NifTerm make_tuple(NifEnv* env, NifTerm[] arr) {
    return enif::make_tuple_from_array(env, arr, arr.len);
}

fn NifTerm make_tuple1(NifEnv* env, NifTerm t1) {
    return make_tuple(env, {t1});
}

fn NifTerm make_tuple2(NifEnv* env, NifTerm t1, NifTerm t2) {
    return make_tuple(env, {t1, t2});
}

fn NifTerm make_tuple3(NifEnv* env, NifTerm t1, NifTerm t2, NifTerm t3) {
    return make_tuple(env, {t1, t2, t3});
}

fn NifTerm make_tuple4(NifEnv* env, NifTerm t1, NifTerm t2, NifTerm t3, NifTerm t4) {
    return make_tuple(env, {t1, t2, t3, t4});
}

fn NifTerm make_tuple5(NifEnv* env, NifTerm t1, NifTerm t2, NifTerm t3, NifTerm t4, NifTerm t5) {
    return make_tuple(env, {t1, t2, t3, t4, t5});
}

fn NifTerm make_tuple6(NifEnv* env, NifTerm t1, NifTerm t2, NifTerm t3, NifTerm t4, NifTerm t5, NifTerm t6) {
    return make_tuple(env, {t1, t2, t3, t4, t5, t6});
}

fn NifTerm make_tuple7(NifEnv* env, NifTerm t1, NifTerm t2, NifTerm t3, NifTerm t4, NifTerm t5, NifTerm t6, NifTerm t7) {
    return make_tuple(env, {t1, t2, t3, t4, t5, t6, t7});
}

fn NifTerm make_tuple8(NifEnv* env, NifTerm t1, NifTerm t2, NifTerm t3, NifTerm t4, NifTerm t5, NifTerm t6, NifTerm t7, NifTerm t8) {
    return make_tuple(env, {t1, t2, t3, t4, t5, t6, t7, t8});
}

fn NifTerm make_tuple9(NifEnv* env, NifTerm t1, NifTerm t2, NifTerm t3, NifTerm t4, NifTerm t5, NifTerm t6, NifTerm t7, NifTerm t8, NifTerm t9) {
    return make_tuple(env, {t1, t2, t3, t4, t5, t6, t7, t8, t9});
}

fn NifTerm make_list(NifEnv* env, NifTerm[] arr) {
    return enif::make_list_from_array(env, arr, arr.len);
}

fn int! get_int(NifEnv* env, NifTerm term) {
    int out;
    if(!enif::get_int(env, term, &out)) {
        return Err.INVALID_OR_OUT_OF_BOUNDS_INT?;
    }

    return out;
}

fn NifTerm make_badarg(NifEnv* env) {
    return enif::make_badarg(env);
}
