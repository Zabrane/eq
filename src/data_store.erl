-module(data_store).
-compile(export_all).
-record(qrow, {id, data}).

%% IMPORTANT: The next line must be included
%% if we want to call qlc:q(...)
-include_lib("stdlib/include/qlc.hrl").

do_this_once() ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(qrow,[{attributes, record_info(fields, qrow)}]),%%, {type, ordered_set}
  mnesia:stop().

start() -> 
  mnesia:start(), 
  mnesia:wait_for_tables([qrow], 20000).

push(Data) ->
  Item = #qrow{id=erlang:make_ref(), data=Data},
  F = fun() ->
        mnesia:write(Item)
      end,
  mnesia:transaction(F).

first_item() ->
  case do(qlc:q([X || X <- mnesia:table(qrow)])) of
    [H|_] -> H;
    _     -> {}
  end.
  
peek() ->
  case first_item() of
    {qrow, _, Data} -> Data;
    _               -> nothing
  end.

pop() ->
  case first_item() of
    {qrow, Id, Data} -> 
      mnesia:transaction(fun() -> mnesia:delete({qrow, Id}) end),
      Data;
    _ -> nothing
  end.
  

clear() ->
  mnesia:clear_table(qrow).

do(Q) ->
  F = fun() -> qlc:e(Q) end,
  {atomic, Val} = mnesia:transaction(F),
  Val.

