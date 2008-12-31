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
      case length(Q) of
        0 ->
          respond(Resp, "null"),
          loop(Q);
        _ ->
          [Head | Tail] = Q,
          respond(Resp, io_lib:format("~p~n", [Head])),
          loop(Tail)
      end;

    {push, Item, Resp} ->
      respond(Resp, "true"),
      loop(lists:append(Q, [Item]));

    _ ->
      loop(Q)
  end.

respond(Resp, Data) ->
  Resp:write_chunk(Data),
  Resp:write_chunk("").
