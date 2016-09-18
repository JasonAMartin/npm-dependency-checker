defmodule Ndc do
  @working_directory Application.get_env(:ndc, __MODULE__)[:working_directory]

  @working_filename Application.get_env(:ndc, __MODULE__)[:working_filename]

  @expected_fields ~w(
    dependencies
  )

  @npm_view_fields ~w(
     dependencies
  )

  ####@message_types [{~r/http/, :http}]

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
    IO.puts "NPM starting package: #{options[:pkg]}"
    options[:pkg]
      |> initial_package_information
  end

  def initial_package_information(repo) do
    dependencies = repo
      |> npm_view("latest")
      |> elem(0)
      |> decode_body(@npm_view_fields)
      |> parse_dependencies
    cond do
    (dependencies == []) -> get_package_information(:error404)
    true -> get_package_information(dependencies, [{repo, "latest"}])
    end
  end

  def get_package_information(pending_dependency_list, all_dependencies_list) do
      package = elem(List.first(pending_dependency_list),0)
      version = elem(List.first(pending_dependency_list),1)
        repo = package
          |> npm_view(version)
          |> elem(0)
          |> decode_body(@npm_view_fields)
          |> parse_dependencies

        ## Scrubbing deps from npm_view call against pening+all deps. Remaining are added to pending.
        ## Make map sets
        [current_dependency | remaining_dependencies] = pending_dependency_list

        dependency_union = MapSet.union(MapSet.new(all_dependencies_list), MapSet.new(remaining_dependencies))
        scrubbed_dependencies = MapSet.difference(MapSet.new(repo), dependency_union)
        update_pending = MapSet.to_list(scrubbed_dependencies)++remaining_dependencies
        complete_dependency_list = [current_dependency]++all_dependencies_list

      ## get next dep if exists and recall. If not, recall with just 1 arg.
      cond do
        (length(update_pending) > 0) ->
          get_package_information(update_pending, complete_dependency_list)
        true ->
          get_package_information(complete_dependency_list)
      end
  end

  @doc """
  When :error404 is passed in, the user is told nothing is found.
  """
  def get_package_information(:error404) do
    IO.inspect "Nothing found."
  end

  @doc """
  Takes a list and reports back to the user the dependencies and count. It also writes a file that lists all dependencies.
  """
  def get_package_information(all_dependencies_list) do
    IO.inspect all_dependencies_list
    IO.puts "Total number of dependencies: #{length(all_dependencies_list)}"
    IO.puts "Dependencies were saved into #{@working_filename} in directory #{@working_directory}."

    final_list = Enum.reduce all_dependencies_list, [], fn {k, v}, acc ->
      updated_version = v
        |> String.replace("^", "")
        |> String.replace("~", "")
        |> String.replace("%", "")
      ["#{k}:#{updated_version}\n"]++acc
    end

    File.write!(Path.absname("#{@working_directory}#{@working_filename}"), List.to_string(final_list))
  end

  @doc """
  Takes a list with {atom:, %{map}} elements and returns a merged list of Repos structs for dependencies.
  """
  def parse_dependencies(dependencies_list) do
    dependencies = (dependencies_list[:dependencies] == nil) && [] || Enum.reduce dependencies_list[:dependencies], [], fn {k, v}, acc ->
      [{k,v}]++acc
    end
    dependencies
  end

  @doc """
  Returns false when a non-map argument is passed in
  """
  def iterate_dependencies(_anything_else), do: false

  @doc """
  Takes a String and runs the system command "npm view --json <package>@<version>"
  Returns: the output of that command
  """
  def npm_view(package, version) when is_binary(package) do
    repo = "#{package}@#{version}"
    System.cmd("npm", ["view", "--json", repo])
  end

  @doc """
  Handles all non-string arguments and returns false since we're not doing anything with it
  """
  def npm_view(_anything), do: false

  @doc """
  Guards against decode_body receiving undefined responses.
  """
  def decode_body("undefined\n", _) do
    [dependencies: %{}]
  end

  @doc """
  Guards against decode_body receiving empty responses.
  """
  def decode_body("", _) do
    [dependencies: %{}]
  end

  @doc """
  Takes a JSON body and desired fields and returns a map with that information.
  """
  def decode_body(body, fields) do
    body
    |> Poison.decode!
    |> Map.take(fields)
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

  # Handle parsing of arguments
  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [pkg: :string]
    )
    options
  end
end
