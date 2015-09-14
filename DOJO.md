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
For example "#{inspect foo} rats".

Pipe operator
-------------

The pipe operator is simplar to F#, it will supply the first argument to the next function in the chain.
For example, the documentation for Enum.reverse states:

    reverse(collection) 	Reverses the collection

.. which means that we can call it with the pipe operator as:

    [1,2,3,4] |> Enum.reverse

Or to fetch the 3rd element in the list:
    [1,2,3,4] |> Enum.fetch(2)

You can think of a pipe as marking points where we transform data.  Modify your private function to capitalise the first character of the returned string (see String.capitalize).
 
Lists, tuples, maps
-------------------

Lists can grow, tuples cannot.  Maps are similar to hashes or dictionaries in other languages.

Write a function that takes two integer arguments (use a guard here) and returns them as a list.

What happens if you don't pass an integer? It crashes!  This is a good thing.  Part of the Erlang/Elixir thing is to stop errors getting too far into the system.  The general idea is that you code for what you want, anything else should cause your module to fail.


The string thing
----------------

With Erlang coming from a telecoms background, string handling isn't a strong point.  Strings come in two flavours, the first is a list of ascii values.

In Elixir, this is represented by single quotes:

    'abc' is the same as [10, 11, 12]

The other representation is as a binary string.  This tends to be the most used string type.  Elixir can pattern match arbitrary bytes in 

## FIXME

* Module attributes

* Pattern matching
* Recursion

Documentation (ie. h MyMod.function)
-------------

Documentation in Elixir is a first class citizen (surprise surpirise, in a modern language).  We can add documentation to modules and functions with `@moduledoc` and `@doc`.

Add a @doc section to your "cats" function, ie:

    @doc ~S"""
    My Cat
    """
    def cat do
      "cats"
    end

Now you can get some help from the shell:

    iex> h Enum

.. will give you the `@moduledoc` from the Enum module.  Do the same for your module and function.

Doctests
--------

If you add an example with the `iex` prompt, you can run a test on it.

    @doc ~S"""
    My Cat

    Example:
        iex> MyModule.cat
        "cats"
    """



* GenServers
* Supervisors
* Dynamic Code Reload

* Load json config and survive and error (tweak Supervisor timeouts)
