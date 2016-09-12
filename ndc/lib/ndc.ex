defmodule Ndc do

  @expected_fields ~w(
     devDependencies dependencies
  )

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
    options[:pkg]
      |> npm_view
      |> get_package_repo_url
      |> transform_repo_raw_json_url
      |> fetch_package_json
      |> parse_dependencies
  end

  ## This function only parses the first item in the list. It needs to be refactored.
  def parse_dependencies(dependencies_list) do
    Enum.at(dependencies_list, 0)
      |> (fn x -> iterate_dependencies(elem(x, 1)) end).()
  end

  def iterate_dependencies(map) do
    ## More work to do.
    Enum.map(map, fn {k, v} -> IO.inspect [k,v] end)
  end

  def npm_view(package) do
    System.cmd("npm", ["view", package])
  end

  def get_package_repo_url(data) do
    ## sending output from npm view on the command line.
     Regex.run(~r/homepage: \'(.*)\'/, elem(data,0)) |> Enum.at(1)
  end

  def fetch_package_json(repo) do
    case HTTPoison.get(repo) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decode_body(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  def decode_body(body) do
    body
    |> Poison.decode!
    |> Map.take(@expected_fields)
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

  def transform_repo_raw_json_url(repo) do
    ## we will do a little replace therapy to fetch the raw json.
    ## end result is: https://raw.githubusercontent.com/someuser/somerepo/master/package.json
    String.replace(repo, "#readme","")
      |> String.replace("github","raw.githubusercontent")
      |>  (fn x -> x <> "/master/package.json" end).()
  end

  # Handle parsing of arguments
  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [pkg: :string]
    )
    options
  end
end
