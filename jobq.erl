% Thanks to help from:
% http://www.rsaccon.com/2007/09/mochiweb-erlang-based-webserver-toolkit.html

-module(jobq).

-export([start/0, stop/0, handle_request/2]).

-record(params, {
  val = ""
}).


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
      QPid ! {pop, Resp};

    'POST' ->
      Params = parse_doc_query(Req),
      Val = Params#params.val,
      QPid ! {push, Val, Resp}
  end.


parse_doc_query(Req) ->
  lists:foldl(fun(Pair, Args) ->
    case Pair of
      {"val", Val} ->
        Args#params{val=Val}
    end
  end, #params{}, Req:parse_post()).
