-module(q).
-export([start/0, loop/0]).

start() -> spawn(fun q:loop/0).

loop() -> loop([9,8,7,6,5,4,3,2,1]).
loop(Q) ->
  io:format("Q: ~p~n", [Q]),
  receive
    {peek, Resp} ->
      [Head, _] = Q,
      respond(Resp, io_lib:format("~p~n", [Head])),
      loop(Q);

    {pop, Resp} ->
      io:format("Pop Lock And Drop It"),
      [Head | Tail] = Q,
      respond(Resp, io_lib:format("~p~n", [Head])),
      loop(Tail);

    {push, Item, Resp} ->
      respond(Resp, io_lib:format("~p~n", [true])),
      loop(lists:append(Q, [Item]));

    _ ->
      loop(Q)
  end.

respond(Resp, Data) ->
  Resp:write_chunk(Data),
  Resp:write_chunk("").
