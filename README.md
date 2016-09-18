# NPM DEPENDENCY CHECKER

This tool was written as part of a let's build for [ElixirDev.io](http://www.elixirdev.io).

#### Current Version

A major refactor of the tool was done and the current version is working nicely. You kick it off by passing in a package you're interested in (for example: react) and it will tell you how many dependencies you'll be installing to use it.

While some packages might only have a tree of 2-10 dependencies, I've found some that end up with over 500 dependencies.

#### Usage

**Configure**

Go to */config/config.exs* and update the two config options as desired.

**Build the application**

Navigate to the *ndc* folder in your terminal and run this command.

```
$ mix escript.build
```

**Run the application**

After building the application, you'll find it in the *ndc* folder. Here's example usage:

```
$ ./ndc --pkg=jest
```

Example output:

```
## OUTPUT:
NPM starting package: react
[{"ua-parser-js", "^0.7.9"}, {"asap", "~2.0.3"}, {"promise", "^7.1.1"},
 {"loose-envify", "^1.0.0"}, {"whatwg-fetch", "^0.8.2"},
 {"iconv-lite", "~0.4.4"}, {"encoding", "^0.1.11"}, {"node-fetch", "^1.0.1"},
 {"isomorphic-fetch", "^2.1.1"}, {"immutable", "^3.7.6"}, {"core-js", "^1.0.0"},
 {"fbjs", "^0.8.4"}, {"js-tokens", "^1.0.1"}, {"loose-envify", "^1.1.0"},
 {"object-assign", "^4.1.0"}, {"react", "latest"}]
Total number of dependencies: 16
Dependencies were saved into dep_list.txt in directory /over/here/.
```
