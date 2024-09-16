module erl;
import enif;
import std::io;

// STATIC GLOBALS

enif::ErlNifEnv* __env;

fn void erl_init() @init @private {
    std::io::printn("INIT erl");
    __env = enif::alloc_env();
}

// CONSTS
const NIF_MAJOR_VERSION = enif::ERL_NIF_MAJOR_VERSION;
const NIF_MINOR_VERSION = enif::ERL_NIF_MINOR_VERSION;
const NIF_MIN_ERTS_VERSION = enif::ERL_NIF_MIN_ERTS_VERSION;

// TYPEDEFS
//distinct ZString = inline char*;
distinct NifEntry = ErlNifEntry;
def NifEnv = ErlNifEnv;
def NifFunc = ErlNifFunc;
def NifFuncPtr = fn NifTerm(NifEnv*, int, NifTerm*);
distinct NifResourceTypeInit = ErlNifResourceTypeInit;
def NifTerm = ErlNifTerm;

def Callback = fn Term(NifEnv* env, Term[] terms);

/*
TODO: check for bad_arg with enif_is_exception in these functions and return {:error, reason tuple}
nif_make_badarg     // of course
enif_raise_exception // if passed the atom 'badarg'
enif_make_double     // for non finite values
enif_make_atom       // for too long atoms
enif_make_atom_len
enif_cpu_time        // if not supported
enif_schedule_nif    // various error cases
*/

// ENUMS
enum NifCharEncoding : int (uint value) {
    LATIN1 = 1,
    UTF8 = 2,
}

enum NifTermType : int (int value) {
    ATOM = 1,
	BITSTRING = 2,
	FLOAT = 3,
	FUN = 4,
	INTEGER = 5,
	LIST = 6,
	MAP = 7,
	PID = 8,
	PORT = 9,
	REFERENCE = 10,
	TUPLE = 11,
	BAD_ARG = 12,
	_MISSING_DEFAULT_CASE__READ_THE_MANUAL = -1,
}

// API

fn NifEnv* alloc_env() {
    return enif::alloc_env();
}

fn NifTerm make_atom(NifEnv* env, ZString name) {
    return enif::make_atom(env, name);
}

fn NifTerm make_int(NifEnv* env, int i) {
    return enif::make_int(env, i);
}

fn NifTerm make_string(NifEnv* env, char* str, NifCharEncoding enc = NifCharEncoding.UTF8) {
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

fn usz! get_atom_length(NifEnv* env, NifTerm term) {
    usz out;
    if(!enif::get_atom_length(env, term, &out, NifCharEncoding.UTF8.value)) {
        return ConversionResult.VALUE_OUT_OF_RANGE?;
    }

    return out;
}

fn int! get_int(NifEnv* env, NifTerm term) {
    int out;
    if(!enif::get_int(env, term, &out)) {
        return ConversionResult.VALUE_OUT_OF_RANGE?;
    }

    return out;
}

fn usz! get_list_length(NifEnv* env, NifTerm term) {
    usz out;
    if(!enif::get_list_length(env, term, &out)) {
        return ConversionResult.VALUE_OUT_OF_RANGE?;
    }

    return out;
}

fn NifTerm make_badarg(NifEnv* env) {
    return enif::make_badarg(env);
}

module erl::atoms;
import enif;
import std::io;
import std::core::string;

int a = 1;

fn void run_at_startup() @init
{
    a = 2;
    // Run at startup
    io::printn("INIT erl::atoms");
    NifEnv* env = erl::alloc_env();
    NifTerm ok = erl::make_atom(env, "ok");
    io::printn(ok.as_str());
}


module erl::term;

import enif;
import std::io;

interface Term {
    fn String as_str();
    fn enif::ErlNifTerm nif_term();
    fn NifTermType nif_term_type();
}

macro Term.as(Term* self, $Type) {
    if($Type.typeid == ((any)*self).type) {
        return *anycast(*self, $Type)!!;
    }

    return CastResult.TYPE_MISMATCH?;
}

struct BadArg(Term) {
    NifTerm term;
}

fn BadArg* new_badarg(NifEnv* env = erl::__env) {
    return mem::new(BadArg, { .term = erl::make_badarg(env) });
}

fn ErlNifTerm BadArg.nif_term(BadArg* self) @dynamic {
    return self.term;
}

fn String BadArg.as_str(BadArg* self) @dynamic {
    return ":badarg";
}

fn NifTermType BadArg.nif_term_type(BadArg* self) @dynamic {
    return NifTermType.BAD_ARG;
}


struct SimpleTerm(Term) {
    NifTerm term;
}

fn SimpleTerm* new_simple_term(NifTerm term, NifEnv* env = erl::__env) {
    return mem::new(SimpleTerm, { .term = term });
}

fn ErlNifTerm SimpleTerm.nif_term(SimpleTerm* self) @dynamic {
    return self.term;
}

fn String SimpleTerm.as_str(SimpleTerm* self) @dynamic {
    return self.nif_term().as_str();
}

fn NifTermType SimpleTerm.nif_term_type(SimpleTerm* self) @dynamic {
    return NifTermType._MISSING_DEFAULT_CASE__READ_THE_MANUAL;
}

struct List(Term) {
    NifTerm term;
    Term[] items;
    usz len;
    Callback callback;
}

fn Term hello(NifEnv* env, Term[] terms) {
    io::printfn("HELLO %d", terms.len);
    foreach(index, term: terms) {
        io::printfn("%d: %s", index, term.as_str());
    }

    return terms[0];
}

fn List* new_list(NifTerm term, NifEnv* env = erl::__env) {
    return mem::new(List, {
        .term = term,
        .len = erl::get_list_length(env, term)!!,
        .callback = &hello
    });
}

fn ErlNifTerm List.nif_term(List* self) @dynamic {
    return self.term;
}

fn String List.as_str(List* self) @dynamic {
    return self.term.as_str();
}

fn NifTermType List.nif_term_type(List* self) @dynamic {
    return NifTermType.LIST;
}

struct Integer(Term) {
    NifTerm term;
    NifEnv* env;
    int val;
}

fn Integer* new_integer(NifTerm term, NifEnv* env = erl::__env) {
    int val = erl::get_int(env, term)!!;

    return mem::new(Integer, {
        .term = term,
        .env = env,
        .val = val,
    });
}

fn Integer* new_int(int val, NifEnv* env = erl::__env) {
    return mem::new(Integer, {
        .term = erl::make_int(env, val),
        .val = val
    });
}

fn ErlNifTerm Integer.nif_term(Integer* self) @dynamic {
    return self.term;
}

fn String Integer.as_str(Integer* self) @dynamic {
    DString str;
    str.appendf("%d", self.val);
    return str.copy_str();
}

fn NifTermType Integer.nif_term_type(Integer* self) @dynamic {
    return NifTermType.INTEGER;
}

fn int Integer.value(Integer* self) @dynamic {
    return self.val;
}

macro Integer.type(Integer* self) {
    return Integer.typeid;
}

fn Term new_term(NifTerm term, NifEnv* env = erl::__env) {
    ulong type = enif::term_type(env, term);

    switch(type) {
        case erl::NifTermType.INTEGER.value:
            return (Term)new_integer(term, env);

        case erl::NifTermType.LIST.value:
            return (Term)new_list(term, env);

        default:
            io::printfn("unsupported NifTermType %d", type);
            return (Term)new_simple_term(term, env);
    }
}


/**
ENV
**/

struct Env {
    NifEnv* nif_env;
}

macro new_env(NifEnv* env) {
    return Env{ .nif_env = env };
}

fn BadArg* Env.badarg(Env* env) @dynamic {
    return mem::new(BadArg, { .term = erl::make_badarg(env.nif_env) });
}

fn Integer* Env.integer(Env* env, int val) @dynamic {
    return mem::new(Integer, {
        .term = erl::make_int(env.nif_env, val),
        .val = val
    });
}
