#! /usr/bin/env escript
% This file is part of eep0018 released under the MIT license. 
% See the LICENSE file for more information.

main([]) ->
    code:add_pathz("ebin"),
    code:add_pathz("test"),
    
    etap:plan(28),
    util:test_good(good()),
    util:test_errors(errors()),
    etap:end_tests().

good() ->
    [
        {<<"\"\"">>, <<"">>},
        {<<"\"0\"">>, <<"0">>},
        {<<"\"foo\"">>, <<"foo">>},
        {<<"\"\\\"foobar\\\"\"">>, <<"\"foobar\"">>},
        {<<"\"\\n\\n\\n\"">>, <<"\n\n\n">>},
        {<<"\"\\\" \\b\\f\\r\\n\\t\\\"\"">>, <<"\" \b\f\r\n\t\"">>},
        {<<"\"foo\\u0005bar\"">>, <<"foo", 5, "bar">>},
        {<<"\"\\uFFFF\"">>, <<239, 191, 191>>, <<"\"", 239, 191, 191, "\"">>},
        {
            <<"\"\\uD834\\uDD1E\"">>,
            <<240, 157, 132, 158>>,
            <<34, 240, 157, 132, 158, 34>>
        },
        % Not sure if this is best but YAJL replaces invalid
        % surrogate pairs with a ?
        {
            <<"\"\\uD834foo\\uDD1E\"">>,
            <<"?foo?">>,
            <<"\"?foo?\"">>
        },
        %% Lone high-surrogate U+D83D is expected to be replaced with '?',
        %% without eating its following codepoint, '\' in this case.
        {
            <<"\"\\uD83D\\\\x\"">>,
            <<"?\\x">>,
            <<"\"?\\\\x\"">>
        },
        %% Lone low-surrogate U+DC00 is expected to be replaced with '?'.
        {
            <<"\"x\\uDC00y\"">>,
            <<"x?y">>,
            <<"\"x?y\"">>
        }
    ].

errors() ->
    [
        <<"\"", 0, "\"">>,
        <<"\"\\g\"">>,
        % CouchDB-345
        <<"\"",78,69,73,77,69,78,32,70,216,82,82,32,70,65,69,78,33,"\"">>,

        %% "\g" is an invalid escape sequence. It should emit a parse error
        %% even if it appears at a position where a low surrogate is
        %% expected.
        <<"\"\\uD83D\\g\"">>
    ].
