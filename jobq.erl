-module(jobq).
-export([start/0, stop/0, handle_request/2]).

start() ->
  QPid = q:start(),
  
  Loop = fun (Req) -> apply(?MODULE, handle_request, [Req, QPid]) end,
  mochiweb_http:start([
      {loop, Loop},
      {name, ?MODULE},
      {ip, "127.0.0.1"},
      {port, 9952}
  ]).

stop() ->
  mochiweb_http:stop(?MODULE).

handle_request(Req, QPid) ->
  Method = Req:get(method),

  Resp = Req:ok({"text/plain", chunked}),
  case Method of
    'GET' ->
      QPid ! {pop, Resp}
  end.

