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
  [H|_] = do(qlc:q([X || X <- mnesia:table(qrow)])),
  H.
  
peek() ->
  Item = first_item(),
  {qrow, _, Data} = Item,
  Data.

pop() ->
  Item = first_item(),
  F = fun() ->
        {qrow, Id, Data} = Item,
        mnesia:delete({qrow, Id}),
        Data
      end,
  {atomic, Data} = mnesia:transaction(F),
  Data.
  

clear() ->
  mnesia:clear_table(qrow).

do(Q) ->
  F = fun() -> qlc:e(Q) end,
  {atomic, Val} = mnesia:transaction(F),
  Val.

