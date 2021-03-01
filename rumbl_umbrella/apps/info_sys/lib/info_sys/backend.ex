defmodule InfoSys.Backend do
  @callback name() :: String.t()
  @callback compute(query :: String.to(), opts :: Keyword.t()) ::
    [%InfoSys.Result{}]
end