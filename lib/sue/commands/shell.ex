defmodule Sue.Commands.Shell do
  alias Sue.Models.Response

  @doc """
  Show how long Sue's server has been running.
  Usage: !uptime
  """
  def c_uptime(_msg) do
    %Response{body: output_single_cmd("uptime")}
  end

  @doc """
  Tell a random, hopefully interesting adage.
  Usage: !fortune
  """
  def c_fortune(_msg) do
    %Response{body: output_single_cmd("fortune")}
  end

  @spec output_single_cmd(String.t()) :: String.t()
  defp output_single_cmd(cmd) do
    {output, 0} = System.cmd(cmd, [])
    output
  end
end
