% This file is part of eep0018 released under the MIT license. 
% See the LICENSE file for more information.
%% @author YAMASHINA Hio <hio@hio.jp>
%% @author Paul J. Davis <paul.joseph.davis@gmail.com>
%% @doc This is a json encode/decode library for erlang.
%% @copyright 2011 YAMASHINA Hio,
%%            2011 Paul J. Davis
-module(enif_json).
-export([encode/1, decode/1, decode/2]).
-export_type([decode_error/0]).
-export_type([decode_options/0]).
-export_type([encode_error/0]).
-export_type([json_array/0]).
-export_type([json_array_t/1]).
-export_type([json_number/0]).
-export_type([json_object/0]).
-export_type([json_object_t/1]).
-export_type([json_primary/0]).
-export_type([json_string/0]).
-export_type([key/0]).
-export_type([value/0]).
-export_type([text/0]).
-export_type([binary_text/0]).

-on_load(init/0).

% ----------------------------------------------------------------------------
% type declarations.
% ----------------------------------------------------------------------------

-type value() :: json_primary()
               | json_object_t([{key(), value()}])
               | json_array_t(value()) .
%% any type of json value.

-type json_string()  :: unicode:unicode_binary().
%% json string value is represented erlang binary term.

-type json_number()  :: integer() | float().
%% json number value is represented erlang integer or float term.
-type json_primary() :: json_string()
                      | json_number()
                      | boolean()
                      | null .
%% non-structured values.

-type key() :: json_string() | atom().
%% key of object value. key() is mostly binary(), but it may be in atom() depended on key_decode option.

-type json_object_t(Pairs) :: {Pairs}.
%% json object value is represented in erlang tuple which contains single proplist style value.

-type json_object() :: json_object_t([{key(),value()}]).
%% json object.

-type json_array_t(T) :: [T].
%% json array value is represented in erlang array term.

-type json_array()  :: json_array_t(value()).
%% json array value is represented in erlang array term.

-type text()        :: unicode:chardata().
%% Json encoded text represented in erlang chardata term.
%% @see binary_text()

-type binary_text() :: unicode:unicode_binary().
%% Json encoded text represented in erlang binary term.
%% @see text()

-type decode_error() :: term().
%% reason for decode() error.

-type encode_error() :: term().
%% reason for encode() error.

-type decode_options() :: [ decode_option() ].
%% options for decode().
%% see decode/2.
-type decode_option()  :: allow_comments
                        | {allow_comments, boolean()}
                        | {key_decode, existent_atom | binary | [existent_atom | binary | ignore]} .
%% option for decode().
%% see decode/2.

% ----------------------------------------------------------------------------
% implementations.
% ----------------------------------------------------------------------------

nif_dir() ->
    case os:getenv("JSON_NIF_DIR") of
        false ->
            nif_dir_2();
        "" ->
            nif_dir_2();
        Path ->
            Path
    end.

nif_dir_2() ->
    case code:priv_dir(?MODULE) of
        {error, _} ->
            EbinDir = filename:dirname(code:which(?MODULE)),
            AppPath = filename:dirname(EbinDir),
            filename:join(AppPath, "priv");
        Path ->
            Path
    end.

init() ->
    PrivDir = nif_dir(),
    erlang:load_nif(filename:join(PrivDir, "enif_json"), 0).

%% @doc decode json text into erlang term.
%% @equiv decode(JsonText, [])
-spec decode(text()) -> {ok, value()} | {error, decode_error()}.
decode(JsonText) ->
    decode(JsonText, []).

%% @doc decode json text into erlang term.
%% 
%% Followins options are acceptable::
%%
%% <dl>
%% <dt id="allow_comments">allow_comments</dt>
%% <dt id="allow_comments.2">{allow_comments, boolean()}</dt>
%% <dd>
%% Allow JavaScript style comment in json text.
%% Default is false.
%% </dd>
%% <dt id="key_decode">{key_decode, existent_atom | binary | [existent_atom | binary | ignore]}</dt>
%% <dd>
%% Type of decoded key of json object.
%% Valid parameter is one of followings::
%% binary, existent_atom, [existent_atom, binary].
%% Default is binary.
%% </dd>
%% </dl>
-spec decode(text(), decode_options()) -> {ok, value()} | {error, decode_error()}.
decode(JsonText, Options) ->
    case decode_nif(JsonText, Options, []) of
        {ok, Value} ->
            {ok, Value};
        {badvals, BadValues} ->
            decode_retry(JsonText, Options, BadValues);
        {error, _Reason} = Err ->
            Err
    end.

-type predecoded_values() :: [{binary(), term()}].
-type position() :: non_neg_integer().
-spec decode_nif(text(), decode_options(), predecoded_values())
    -> {ok, value()} | {error, decode_error()} | {badvals, [{bigval, binary_text(), position()}]}.
decode_nif(JsonText, Options, PreDecodedValues) ->
    erlang:nif_error(module_not_loaded, [JsonText, Options, PreDecodedValues]).

decode_retry(JsonTerm, Options, Values) ->
    case pre_decode(Values) of
        {ok, PreDecodedValues} ->
            decode_retry_2(JsonTerm, Options, PreDecodedValues);
        {error, _Reason} = Err ->
            Err
    end.

decode_retry_2(JsonTerm, Options, PreDecodedValues) ->
    case decode_nif(JsonTerm, Options, PreDecodedValues) of
        {ok, Value} ->
            {ok, Value};
        {error, _Reason} = Err ->
            Err
    end.

pre_decode(Values) ->
    pre_decode(Values, []).
pre_decode([{bigval, Text, Pos} | Rest], Result) ->
    Text_2 = binary_to_list(Text),
    try
        list_to_integer(Text_2)
    of
        Value ->
            Result_2 = [{Text, Value}| Result],
            pre_decode(Rest, Result_2)
    catch
        error:badarg ->
            try
                list_to_float(Text_2)
            of
                Value ->
                    Result_2 = [{Text, Value}| Result],
                    pre_decode(Rest, Result_2)
            catch
                error:badarg ->
                    case re:run(Text, "^(\\d+)(e[-+]?\\d+)$",[dollar_endonly, {capture, all_but_first, list}]) of
                        {match, [Int, Exp]} ->
                            try
                                list_to_float(Int++".0"++Exp)
                            of
                                Value ->
                                    Result_2 = [{Text, Value}| Result],
                                    pre_decode(Rest, Result_2)
                            catch
                                error:badarg ->
                                   {error, {Pos, numeric_overflow, Text}}
                            end;
                        nomatch ->
                            {error, {Pos, numeric_overflow, Text}}
                    end
            end
    end;
pre_decode([], Result) ->
    {ok, lists:reverse(Result)}.


%% @doc encode erlang term into json text.
-spec encode(value()) -> {ok, binary_text()} | {error, encode_error()}.
encode(JsonTerm) ->
    case encode_nif(JsonTerm, []) of
        {ok, Value} ->
            {ok, Value};
        {badvals, BadValues} ->
            encode_retry(JsonTerm, BadValues);
        {error, _Reason} = Err ->
            Err
    end.

-type preencoded_values() :: [{term(), binary()}].
-spec encode_nif(value(), preencoded_values())
    -> {ok, binary_text()} | {error, encode_error()} | {badvals, [value()]}.
encode_nif(JsonTerm, PreEncodedValues) ->
    erlang:nif_error(module_not_loaded, [JsonTerm, PreEncodedValues]).

encode_retry(JsonTerm, Values) ->
    case pre_encode(Values) of
        {ok, PreEncodedValues} ->
            encode_retry_2(JsonTerm, PreEncodedValues);
        {error, _Reason} = Err ->
            Err
    end.

encode_retry_2(JsonTerm, PreEncodedValues) ->
    case encode_nif(JsonTerm, PreEncodedValues) of
        {ok, Value} ->
            {ok, Value};
        {error, _Reason} = Err ->
            Err
    end.

pre_encode(Values) ->
    pre_encode(Values, []).
pre_encode([Value | Rest], Result) when is_integer(Value) ->
    Text = list_to_binary(integer_to_list(Value)),
    Result_2 = [{Value, Text}| Result],
    pre_encode(Rest, Result_2);
pre_encode([Value | _Rest], _Result) ->
    {error, {badarg, Value}};
pre_encode([], Result) ->
    {ok, lists:reverse(Result)}.

% ----------------------------------------------------------------------------
% End of File.
% ----------------------------------------------------------------------------
