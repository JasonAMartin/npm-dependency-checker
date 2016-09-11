defmodule Ndc do

  # Application Start
  def main(args) do
   args |> parse_args |> process
  end

  # No arguments passed via command line
  def process([]) do
    IO.puts "Charmed, I'm sure."
  end

  # Arguments were passed via command line
  def process(options) do
    IO.puts "NPM package: #{options[:pkg]}"
  end

  # Handle parsing of arguments
  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [pkg: :string]
    )
    options
  end
end
