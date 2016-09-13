defmodule NdcTest do
  use ExUnit.Case
  doctest Ndc

  test "iterate_dependencies: iterate a map" do
    assert Ndc.iterate_dependencies(%{a: 1, b: 2, c: 3})
  end

  test "iterate_dependencies:fail quietly when passed something other than a map" do
    refute Ndc.iterate_dependencies("The Cat and the Cradle and the Silver Sppon")
  end

  test "npm_view: runs the npm view command when passed a string" do
    assert Ndc.npm_view("microlibrary")
  end

  test "npm_view: fails silently and returns true when passed non-string" do
    refute Ndc.npm_view(1337)
  end

  test "fetch_package_json(repo): raises UndefinedFunctionError when passing in numbers" do
    assert_raise UndefinedFunctionError, fn ->
      Ndc.fetch_package_json(3434234)
    end
  end

  test "transform_repo_raw_json_url(repo): returns the proper github raw source url" do
    assert Ndc.transform_repo_raw_json_url([repository: %{"type" => "git",
   "url" => "git+https://github.com/JasonAMartin/npm-dependency-checker.git"}]) == "https://raw.githubusercontent.com/JasonAMartin/npm-dependency-checker/master/package.json"
  end

  test "transform_repo_raw_json_url(repo): returns false when a non-list is passed in" do
    refute Ndc.transform_repo_raw_json_url(3)
  end

  test "decode_body: returns map" do
    assert Ndc.decode_body("{\n  \"name\": \"microlibrary\",\n  \"version\": \"1.2.6\",\n \"repository\": {\n  \"type\": \"git\",\n \"url\": \"git+https://github.com/JasonAMartin/microlibrary.git\"\n  },\n  \"dependencies\": {\n    \"unique-random-array\": \"1.0.0\"\n  },\n  \"devDependencies\": {\n    \"babel\": \"^6.1.18\",\n   \"mocha-lcov-reporter\": \"^1.0.0\"\n  }\n}\n", ~w(devDependencies dependencies ))
  end
end
