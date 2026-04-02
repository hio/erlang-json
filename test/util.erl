% This file is part of eep0018 released under the MIT license. 
% See the LICENSE file for more information.
-module(util).
-export([test_good/1, test_errors/1]).

test_good(Cases) ->
    lists:foreach(fun(Case) -> check_good(Case) end, Cases).

test_errors(Cases) ->
    lists:foreach(fun(Case) -> check_error(Case) end, Cases).

ok_dec(J, E) ->
    lists:flatten(io_lib:format("Decoding ~p gives ~p", [J, E])).

ok_enc(E, J) ->
    lists:flatten(io_lib:format("Encoding ~p gives ~p", [E, J])).

error_mesg(J) ->
    lists:flatten(io_lib:format("Decoding ~p returns an error.", [J])).

check_good({J, E}) ->
    etap:is(enif_json:decode(J), {ok, E}, ok_dec(J, E)),
    etap:is(enif_json:encode(E), {ok, J}, ok_enc(E, J));
check_good({J, E, J2}) ->
    etap:is(enif_json:decode(J), {ok, E}, ok_dec(J, E)),
    etap:is(enif_json:encode(E), {ok, J2}, ok_enc(E, J2)).

check_error(J) ->
    etap:fun_is(
        fun({error, _}) -> true; (_) -> false end,
        enif_json:decode(J),
        error_mesg(J)
    ).
