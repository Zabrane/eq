-module(jobq).
-export([loop/0]).

loop() -> loop([]).

loop(Q) ->
  io:format("Q: ~p~n", [Q]),
  receive
    {peek} ->
      [Head, _] = Q,
      io:format("Got: ~p~n", [Head]),
      loop(Q);

    {pop} ->
      [Head, Tail] = Q,
      io:format("Got: ~p~n", [Head]),
      loop(Tail);

    {push, Item} ->
      io:format("Pushing: ~p~n", [Item]),
      loop(lists:append(Q, [Item]));

    _ ->
      io:format("Other")
  end.

