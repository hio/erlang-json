// This file is part of eep0018 released under the MIT license. 
// See the LICENSE file for more information.

#include "erl_nif.h"

ERL_NIF_TERM encode(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM decode(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

int
on_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM info)
{
    return 0;
}

int
on_reload(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM info)
{
    return 0;
}

int
on_upgrade(ErlNifEnv* env, void** priv_data, void** old_data, ERL_NIF_TERM info)
{
    return 0;
}

static ErlNifFunc nif_funcs[] =
{
    {"encode_nif", 2, encode},
    {"decode_nif", 3, decode}
};

ERL_NIF_INIT(enif_json, nif_funcs, &on_load, &on_reload, &on_upgrade, NULL);
