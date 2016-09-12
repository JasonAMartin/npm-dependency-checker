# NPM DEPENDENCY CHECKER

This tool was written as part of a let's build for [ElixirDev.io](http://www.elixirdev.io).

#### Goal Overview

* I'd like some sort of indicator that it's working (progress notification)
* I'd like it to be as fast as possible. At first, I just want it work, but it should end up concurrently grabbing all the package info.
* I'd like the output to be easy-to-read in the terminal, but I'd like to be able to pass in an argument to store it into a file (for those who don't want to >>)

#### Update

As of now NPM Dependency Checker will give you a listing of dependencies for a package published to NPM. It currently only lists out the first dependency list (so either dependencies or devDependencies).

#### Usage

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
NPM package: jest
"babel-core"
"babel-eslint"
"babel-plugin-syntax-trailing-function-commas"
"babel-plugin-transform-es2015-destructuring"
"babel-plugin-transform-es2015-parameters"
"babel-plugin-transform-flow-strip-types"
"chalk"
"codecov"
"eslint"
"eslint-plugin-babel"
"eslint-plugin-flow-vars"
"eslint-plugin-flowtype"
"eslint-plugin-react"
"flow-bin"
"glob"
"graceful-fs"
"istanbul-api"
"istanbul-lib-coverage"
"jasmine-reporters"
"lerna"
"minimatch"
"mkdirp"
"progress"
"rimraf"
```
