Try some Elixir!
================

mix new
-------

Mix is a tool to help create Elixir projects.  It will create a skeleton project with a skeleton test framework.
It can also be extended and used to do things like hook into the [Hex](http://hex.pm) package management system to deal with dependancies.

Create a new project with `mix new elixir_dojo`.


Define a function
-----------------

Mix has provided a (small) skeleton module, now you can add a function to it.  Define a function that returns "cats".
We don't need any parameters or guards.

Private functions
-----------------

We can define private functions with 'defp'.  Define a function that takes a parameter and returns it before the word "rats".
For example "#{foo} rats".

Pipe operator
-------------

The pipe operator is simplar to F#, it will supply the first argument to the next function in the chain.
For example:
    [1,2,3,4] |> Enum.reverse




Functions defined 

* Private functions
* Pipe operator

* Lists, tuples, maps
* The string thing
* Module attributes

* Pattern matching
* Recursion

* Docs (ie. h MyMod.function)
* Doctests

* GenServers
* Supervisors
* Dynamic Code Reload

* Load json config and survive and error (tweak Supervisor timeouts)
