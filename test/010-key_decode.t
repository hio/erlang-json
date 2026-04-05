#! /usr/bin/env escript
% This file is part of eep0018 released under the MIT license. 
% See the LICENSE file for more information.

main([]) ->
    code:add_pathz("ebin"),
    code:add_pathz("test"),
    
    etap:plan(8),

    etap:is(enif_json:decode(<<"{\"key\":1}">>), {ok, {[{<<"key">>,1}]}}, "DEC: default is binary key"),
    etap:is(enif_json:decode(<<"{\"key\":1}">>, [{key_decode, binary}]), {ok, {[{<<"key">>,1}]}}, "DEC: binary"),
    etap:is(enif_json:decode(<<"{\"key\":1}">>, [{key_decode, existent_atom}]), {ok, {[{key,1}]}}, "DEC: existent_atom"),
    etap:is(enif_json:decode(<<"{\"key\":1}">>, [{key_decode, [binary]}]), {ok, {[{<<"key">>,1}]}}, "DEC: [binary] => binary"),
    etap:is(enif_json:decode(<<"{\"key\":1}">>, [{key_decode, [existent_atom]}]), {ok, {[{key,1}]}}, "DEC: [existent_atom] => atom"),

    etap:is(enif_json:decode(<<"{\"no_atom/1234\":1}">>, [{key_decode, existent_atom}]), {error, {15, {atom_not_exist, <<"no_atom/1234">>}}}, "DEC: existent_atom/not exist"),
    etap:is(enif_json:decode(<<"{\"no_atom/1234\":1}">>, [{key_decode, [existent_atom, binary]}]), {ok, {[{<<"no_atom/1234">>, 1}]}}, "DEC: existent_atom or binary/not exist = binary"),
    etap:is(enif_json:decode(<<"{\"no_atom/1234\":1}">>, [{key_decode, [existent_atom, ignore]}]), {ok, {[]}}, "DEC: existent_atom or ignore/not exist = ignore"),

    etap:end_tests().


