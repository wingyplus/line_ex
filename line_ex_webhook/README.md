# LineEx.Webhook

**NOTE:** The library is under development. It can have breaking changes during develop. Please
use with cautions.

`LineEx.Webhook` provides mechanism to handle webhook event, such as verify signature, reply the message, etc.

## Features

* Provides mechanism to verify request before entering webhook. User don't to handle on
  their own.
* Provides user-friendly api to write webhook event handler. User don't need to worry about
  how they reply.
* Run it under supervisor. It'll restart automatically if it crash. (Thanks to Erlang/OTP).

## Installation

You needs to add dependency to your project:

```elixir
def deps do
  [
    {:line_ex_webhook, "~> 0.1.0-dev", github: "github.com/wingyplus/line_ex", sparse: "line_ex_webhook"},
  ]
end
```
