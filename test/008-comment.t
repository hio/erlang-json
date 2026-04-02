#! /usr/bin/env escript
% This file is part of eep0018 released under the MIT license. 
% See the LICENSE file for more information.

main([]) ->
    code:add_pathz("ebin"),
    code:add_pathz("test"),
    
    etap:plan(5),

    % allow comment requires explicit option.
    etap:is(enif_json:decode(<<"/* here is a comment. */ true">>, [allow_comments]), {ok, true}, "DEC: true (with comment/allowed) -> true"),
    etap:is(enif_json:decode(<<"/* here is a comment. */ true">>, [{allow_comments, true}]), {ok, true}, "DEC: true (with comment/allowed) -> true"),

    % deny comment explicitly.
    etap:is(enif_json:decode(<<"/* here is a comment. */ true">>, [{allow_comments, false}]), {error, {0, unallowed_comment}}, "DEC: true (with comment/denied) -> error/unallowed"),

    % default behavior denies comment.
    etap:is(enif_json:decode(<<"/* here is a comment. */ true">>), {error, {0, unallowed_comment}}, "DEC: true (with comment/default) -> error/unallowed"),
    etap:is(enif_json:decode(<<"/* here is a comment. */ true">>, []), {error, {0, unallowed_comment}}, "DEC: true (with comment/omitted) -> error/unallowed"),

    etap:end_tests().


