# LineEx.Webhook

**NOTE:** The library is under development. It can have breaking changes during develop. Please
use with cautions.

`LineEx.Webhook` is a process to handle incoming webhook from LINE messaging api. The module
will act as a process and send events to a module that implements behaviour.

## Installation

You needs to add dependency to your project:

```elixir
def deps do
  [
    {:line_ex_webhook, "~> 0.1.0", github: "github.com/wingyplus/line_ex", sparse: "line_ex_webhook"},
  ]
end
```
