% Thanks to help from:
% http://www.rsaccon.com/2007/09/mochiweb-erlang-based-webserver-toolkit.html

-module(jobq).

-export([start/0, stop/0, handle_request/2]).

-record(post_params, {
  data = ""
}).

-record(get_params, {
  options = []
}).

init() ->
  code:add_patha("./src"),
  code:add_patha("./src/mochiweb").

start() ->
  init(),
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
      Params = parse_get_params(Req),
      Options = Params#get_params.options,
      QPid ! {pop, Resp, Options};

    'POST' ->
      Params = parse_post_params(Req),
      Val = Params#post_params.data,
      QPid ! {push, Resp, Val};

    'DELETE' ->
      QPid ! {clear, Resp}
  end.


parse_post_params(Req) ->
  lists:foldl(fun(Pair, Args) ->
    case Pair of
      {"data", Val} ->
        Args#post_params{data=Val}
    end
  end, #post_params{}, Req:parse_post()).

parse_get_params(Req) ->
  lists:foldl(fun(Pair, Args) ->
    case Pair of
      {"count", "true"} ->
        Args#get_params{options=[count|Args#get_params.options]}
    end
  end, #get_params{}, Req:parse_qs()).


