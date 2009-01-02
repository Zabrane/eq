-module(q).
-export([start/0, loop/0, join/1, join/2]).

start() -> spawn(fun q:loop/0).

loop() -> loop(["9","8","7","6","5","4","3","2","1"]).
loop(Q) ->
  %io:format("Q: ~p~n", [Q]),
  receive
    {peek, Resp} ->
      [Head, _] = Q,
      respond(Resp, io_lib:format("~p~n", [Head])),
      loop(Q);

    {pop, Resp, Options} ->

      OptionMap = lists:map(fun(Item) ->
        option(Item, Q)
      end, Options),

      KeyValuePairs = [option(data, Q) | OptionMap],
      JSON = join(KeyValuePairs, ", "),

      respond(Resp, io_lib:format("{~s}", [JSON])),
      loop(tail_or_empty(Q));

    {push, Resp, Item} ->
      respond(Resp, "{\"success\": true}"),
      loop(lists:append(Q, [Item]));

    {clear, Resp} ->
      respond(Resp, "{\"success\": true}"),
      loop([]);

    _ ->
      loop(Q)
  end.


join(List) ->
  join(List, "").
join([Head|[]], _) ->
  Head;
join([Head|Tail], Sep) ->
  string:concat(Head,
    string:concat(Sep,
      join(Tail, Sep))).

tail_or_empty([]) -> [];
tail_or_empty([_|Tail]) -> Tail.

option(data, []) ->
  "\"data\": null";
option(data, [Head | _]) ->
  io_lib:format("\"data\": ~s", [Head]);

option(count, Q) ->
  io_lib:format("\"count\": ~p", [length(Q)]).

respond(Resp, Data) ->
  Resp:write_chunk(Data),
  Resp:write_chunk("").
