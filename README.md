Weebo
=====

Weebo is an [XML-RPC](http://wikipedia.org/wiki/XML-RPC) parser/formatter for
Elixir, with full data-type support.

Weebo can be combined with GenServer, Phoenix, HTTPoison (and others!) to create
fully-featured XML-RPC clients & servers.

```elixir
request = Weebo.parse("<?xml version=\"1.0\"?><methodCall><methodName>math.sum</methodName><params><param><value><int>1</int></value></param><param><value><int>2</int></value></param><param><value><int>3</int></value></param></params></methodCall>")
#=> %Weebo.Request{method: "math.sum", params: [1, 2, 3]}

sum = Enum.sum(request.params)
response = %Weebo.Response{error: nil, params: [sum]}
Weebo.format(response)
#=> "<?xml version=\"1.0\"?><methodResponse><params><param><value><int>6</int></value></param></params></methodResponse>"
```

## Installation

Add Weebo to your mix dependencies:

```elixir
def deps do
  [{:weebo, "~> 1.0"}]
end
```

Then run `mix deps.get` and `mix deps.compile`.


## Data Type Mapping

All the following data-types are supported, and will be automatically serialized
in `format/1` and `parse/1`:

| XMLRPC | Elixir |
| -------|--------|
| `<string>`    | Bitstring `"string"` |
| `<int>`       | Integer   `8` |
| `<boolean>`   | Boolean   `true false `|
| `<double>`    | Float `6.3` |
| `<array>`     | List   `[1, 2, 3]` |
| `<struct>`    | Map  `%{key: "value"}`  |
| `<dateTime.iso8601>`    | Tuple `{{2015, 6, 7}, {16, 24, 18}}` |
| `<nil>`    | Nil atom `nil` |

In addition, the following extra data-types are supported only in `parse/1`:

| XMLRPC | Elixir |
| -------|--------|
| `<base64>`    | Bitstring `"string"` (will decode the base64 first) |
| `<i4>`       | Integer   `8` |

## Examples

### Creating a client with HTTPoison

> [https://github.com/edgurgel/httpoison](https://github.com/edgurgel/httpoison)

For quick-n-dirty usage, you can just use Weebo directly encode/decode
request/response bodies:

```elixir
body = %Weebo.Request{method: "sample.sumAndDifference", params: [5, 3]}
       |> Weebo.format

res = HTTPoison.post!("http://some-wordpress-site.com/xmlrpc.php", body)

Weebo.parse(res.body)
#=> %Weebo.Response{error: nil, params: [%{difference: 2, sum: 8}]}
```

Or for more encapsulation, you can use HTTPoison's [base wrapper](https://github.com/edgurgel/httpoison#wrapping-httpoisonbase)
to auto-parse & format requests:

```elixir
defmodule XMLRPC do
  use HTTPoison.Base

  def process_request_body(body), do: Weebo.format(body)
  def process_response_body(body), do: Weebo.parse(body)
end

body = %Weebo.Request{method: "sample.sumAndDifference", params: [5, 3]}
res = XMLRPC.post!("http://some-wordpress-site.com/xmlrpc.php", body)
res.body
#=> %Weebo.Response{error: nil, params: [%{difference: 2, sum: 8}]}
```

You can then build out your `XMLRPC` module to handle more features like
authentication, error handling, etc.

### Creating a server with Phoenix

> [http://phoenixframework.org](http://phoenixframework.org)

Phoenix might be a little overkill for just a stand-alone XML-RPC server, but
if you already have an existing application that you want to add XML-RPC support
to, then you're in luck!

First add a route to your `router.ex` file:

```elixir
post "/xmlrpc", XmlRpcController, :process
```

Then in your `xml_rpc_controller.ex`:

```elixir
defmodule MyApp.XmlRpcController do
  use MyApp.Web, :controller

  def process(conn, _params) do
    {:ok, body, _conn} = read_body(conn)
    xml_req = Weebo.parse(body)

    res = case xml_req.method do
      "math.sum" ->
        sum = Enum.sum(xml_req.params)
        %Weebo.Response{params: [sum]}
      _ ->
        %Weebo.Response{error: %{faultCode: 404, faultString: "Not found."}}
    end

    render conn, Weebo.format(res)
  end
end
```

### Used Weebo in another awesome way?

Please open an [issue/pull-request](https://github.com/stevenschobert/weebo) on
GitHub and I'll get it added to this README!


## Acknowledgements

Thank you to [@expelledboy](https://github.com/expelledboy) for releasing their
[exml](https://github.com/expelledboy/exml) package. Although I wasn't able to
use it directly, it served as a base for Weebo's internal [XML interface](/lib/xml_interface.ex).

Also thanks goes to [@seansawyer](https://github.com/seansawyer) for their awesome
[erlang_iso8601](https://github.com/seansawyer/erlang_iso8601) library, which
Weebo uses for timestamp parsing & formatting.
