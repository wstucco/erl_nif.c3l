module erl;

import enif;
import std::io;

fn String ErlNifTerm.as_str(ErlNifTerm* self, ErlNifEnv* env = __env) @dynamic
{
    DString str;
    ulong type = enif::term_type(env, *self);

    switch(type) {
        case erl::NifTermType.ATOM.value:
            usz! len = erl::get_atom_length(env, *self);
            if(try len) {
                char* buffer = malloc(len + 1);
                defer free(buffer);
                enif::snprintf(buffer, len + 1, "%T", *self);
                str.appendf(":%s", buffer[0:len]);
            }

        case erl::NifTermType.INTEGER.value:
            str.appendf("%d", get_int(env, *self)!!);

        case erl::NifTermType.LIST.value:
            str.append("[");
            ErlNifTerm list = *self;
            ErlNifTerm head;
            ErlNifTerm tail;
            while (enif::get_list_cell(env, list, &head, &tail)) {
                list = tail;
                if(enif::is_empty_list(env, list)) {
                    str.appendf("%s", head.as_str(env));
                } else {
                    str.appendf("%s, ", head.as_str(env));
                }
            }
            str.append("]");
        case erl::NifTermType.TUPLE.value:
            str.append("{");
            ErlNifTerm *tuple;
            int arity;
            enif::get_tuple(env, *self, &arity, &tuple);

            for(int i = 0;i < arity; ++i) {
                if(i == arity - 1) {
                    str.appendf("%s", tuple[i].as_str(env));
                } else {
                    str.appendf("%s, ", tuple[i].as_str(env));
                }
            }
            str.append("}");
        default:
            io::eprintfn(`unreachable("should be a valid NifTermType") %d`, type);
            // unreachable("should be a valid NifTermType");
    }
    return str.len() > 0 ? str.copy_str() : "";
}
