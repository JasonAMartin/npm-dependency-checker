defmodule Ndc do

  @expected_fields ~w(
     devDependencies dependencies
  )

  @npm_view_fields ~w(
     repository
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
      |> elem(0)
      |> decode_body(@npm_view_fields)
      |> transform_repo_raw_json_url
      |> fetch_package_json
      |> parse_dependencies
  end

  ## This function only parses the first item in the list. It needs to be refactored.
  def parse_dependencies(dependencies_list) do
    Enum.at(dependencies_list, 0)
      |> (fn x -> iterate_dependencies(elem(x, 1)) end).()
  end

  @doc """
  Iterates through a map and prints out the key:value pairs
  Returns `:ok`.
  """
  def iterate_dependencies(map) when is_map(map) do
    ## More work to do.
    Enum.map(map, fn {k, v} -> IO.inspect [k,v] end)
  end

  @doc """
  Returns false when a non-map argument is passed in
  """
  def iterate_dependencies(_anything_else), do: false

  @doc """
  Takes a String and runs the system command "npm view <package>"
  Returns: the output of that command
  """
  def npm_view(package) when is_binary(package) do
    System.cmd("npm", ["view", "--json", package])
  end

  @doc """
  Handles all non-string arguments and returns false since we're not doing anything with it
  """
  def npm_view(_anything), do: false

  @doc """
  Fetches a url, which should be a JSON file and sends it to decode_body for decoding to a map
  """
  def fetch_package_json(repo) do
    case HTTPoison.get(repo) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decode_body(body, @expected_fields)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        "Your princess is in another castle."
      {:error, %HTTPoison.Error{reason: reason}} ->
        raise reason
    end
  end

  def decode_body(body, fields) do
    body
    |> Poison.decode!
    |> Map.take(fields)
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

  @doc """
  Takes a GitHub url and transforms it to point to the package.json in the master branch
  """
  def transform_repo_raw_json_url(repo) when is_list(repo) do
    ## we will do a little replace therapy to fetch the raw json.
    ## expected: git+https://github.com/user/repo.git
    ## end result is: https://raw.githubusercontent.com/someuser/somerepo/master/package.json
    String.replace(repo[:repository]["url"], "git+","")
      |> String.replace(".git", "")
      |> String.replace("github","raw.githubusercontent")
      |>  (fn x -> x <> "/master/package.json" end).()
  end

  @doc """
  Returns false when a non-binary is passed in
  """
  def transform_repo_raw_json_url(_anything_else), do: false

  # Handle parsing of arguments
  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [pkg: :string]
    )
    options
  end
end
