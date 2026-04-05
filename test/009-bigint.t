#! /usr/bin/env escript
% This file is part of eep0018 released under the MIT license. 
% See the LICENSE file for more information.

main([]) ->
    code:add_pathz("ebin"),
    code:add_pathz("test"),
    
    etap:plan(2),

    etap:is(enif_json:decode(<<"18446744073709551616">>), {ok, 18446744073709551616}, "DEC: 18446744073709551616"),
    etap:is(enif_json:encode(18446744073709551616), {ok, <<"18446744073709551616">>}, "ENC: 18446744073709551616"),

    etap:end_tests().


