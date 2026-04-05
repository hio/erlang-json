-module(issue_001).
-include_lib("eunit/include/eunit.hrl").

issue_001_test_() ->
  [
    % reported cases.
    % This calls returns a proper result:
    ?_assertEqual(
      {ok, {[ {<<"algorithm">>, <<"HMAC-SHA256">>}, {<<"credits">>, {[ {<<"buyer">>, 100000000000000} ]} } ]} },
      enif_json:decode(<<"{\"algorithm\":\"HMAC-SHA256\",\"credits\":{\"buyer\":100000000000000}}">>)
    ),
    ?_assertEqual(
      {ok, {[ {<<"algorithm">>, <<"HMAC-SHA256">>}, {<<"credits">>, {[ {<<"buyer">>, 1000000000}, {<<"receiver">>, 100000000} ]} } ]} },
      enif_json:decode(<<"{\"algorithm\":\"HMAC-SHA256\",\"credits\":{\"buyer\":1000000000, \"receiver\":100000000}}">>)
    ),
    ?_assertEqual(
      {ok, {[ {<<"algorithm">>, <<"HMAC-SHA256">>}, {<<"credits">>, {[ {<<"buyer">>, 1000000000}, {<<"receiver">>,10000000000000000000000} ]} } ]} },
      enif_json:decode(<<"{\"algorithm\":\"HMAC-SHA256\",\"credits\":{\"buyer\":1000000000, \"receiver\":10000000000000000000000}}">>)
    ),

    % But this one returns an {error,{69,invalid_internal_no_key_set}}:
    ?_assertEqual(
      {ok, {[ {<<"algorithm">>, <<"HMAC-SHA256">>}, {<<"credits">>, {[ {<<"buyer">>, 10000000000}, {<<"receiver">>, 100000000} ]} } ]} },
      enif_json:decode(<<"{\"algorithm\":\"HMAC-SHA256\",\"credits\":{\"buyer\":10000000000, \"receiver\":100000000}}">>)
    ),

    % simple case.
    ?_assertEqual(
      {ok, {[{<<"x">>, 123456789012345678901234567890}, {<<"y">>, 0}]}},
      enif_json:decode(<<"{\"x\":123456789012345678901234567890,\"y\":0}">>)
    ),
    ?_assertEqual(
      {ok, {[{<<"a">>, 113456789012345678901234567890}, {<<"b">>,{[{<<"x">>, 123456789012345678901234567890}, {<<"y">>, 20}]}}, {<<"c">>, 30}]} },
      enif_json:decode(<<"{\"a\":113456789012345678901234567890,\"b\":{\"x\":123456789012345678901234567890,\"y\":20},\"c\":30}">>)
    ),

    ?_assert(true)
  ].

