Try some Elixir!
================

Prereqs
-------

* An installation of [Elixir](http://elixir-lang.org/install.html).
* A telnet client (ie [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) on windows or 'telnet' on linux)

Mix
---

Mix is a tool to help create Elixir projects.  It will create a skeleton project with a skeleton test framework.
It can also be extended and used to do things like hook into the [Hex](http://hex.pm) package management system to deal with dependancies.

Create a new project with `mix new dojo` (where 'dojo' is the name of our project).

Create a new module
-------------------

    snapper:~$ mix new dojo
    snapper:~$ cd dojo
    snapper:~/dojo$ mkdir lib/dojo
    snapper:~/dojo$ tree
    .
    ├── config
    │   └── config.exs
    ├── lib
    │   ├── dojo
    │   └── dojo.ex
    ├── mix.exs
    ├── README.md
    └── test
        ├── dojo_test.exs
        └── test_helper.exs
    
    4 directories, 6 files
    snapper:~/dojo$ 


Mix has provided a (small) skeleton module, in `lib/dojo.ex`.  If we want to add more modules to the project, we create the `lib/dojo` directory and add our modules there.  Add a module `Dojo.Actor`, it goes in the file `lib/dojo/actor.ex`.

Create a function `Dojo.Actor.add` that takes two integer arguments and adds the result together.  As an example, a "hello world" below:

    defmodule Dojo.Hello do
      @moduledoc "Let's say hello"
      
      @doc """
      Says hello to you in Swedish.
      """
      def se(person) do
        "Hej #{inspect person}"
      end
    end

Now start iex (interactive Elixir) with `iex -S mix`.

If you come from Ruby, you'll recognise the `"#{var}"` syntax.  If you've added a `@doc` to your function, try `h Dojo.Actor.add` in iex.

Don't forget to recompile your module if you make changes.  You can either quit iex with ctrl+c, ctrl+c, it'll recompile when you start iex; or you can use `r(Dojo.Actor)`.

Numbers, lists, tuples and maps etc
-----------------------------------

We can experiment with data types in iex:

Numbers, strings and atoms:

    iex> 1 + 4
    5
    iex> "jim" <> "bob"
    "jimbob"
    iex> :hello
    :hello

Atoms are the same as symbols in other languages.

Lists typically hold a fixed number of items (may be different types):

    iex> [1,2,3, "four"]
    [1, 2, 3, "four"]

Tuples typically hold a fixed number of items.  It's common to see things like `{:ok, "value"}` or `{:error, reason}` returned by functions (where `reason` is a description of the problem).

    iex> {:ok, "hello"}
    {:ok, "hello"}

Maps are similar to hashes or dictionaries in other languages.  If the key is an atom, then you can access the value with the dot notation.  It'll raise a KeyError if the key doesn't exist.

    iex> foo = %{:one => 1, :two => 2}
    %{one: 1, two: 2}
    iex> foo[:one]
    1
    iex> foo.one
    1
    iex> foo[:three]
    nil
    iex> foo.three
    ** (KeyError) key :three not found in: %{one: 1, two: 2}
        
    iex(16)> 


The string thing
----------------

With Erlang coming from a telecoms background, string handling isn't a strong point.  Strings come in two flavours, the first is a list of ascii values.

In Elixir, this is represented by single quotes:

    'abc' is the same as [10, 11, 12]

    iex> 'ABC'       
    'ABC'
    iex> [65,66,67]
    'ABC'
    iex> 

As you can see, we've picked up a curious thing.  If a list can be entirely repesented in ASCII, then that's how the shell prints the list.  For the most part you don't have to worry about it because we tend to use binary strings in Elixir.

The other representation is as a binary string.  This tends to be the most used string type in Elixir.

    iex> "hello"
    "hello"

Pattern matching
----------------

The `=` operator in Elixir is a bit different to what we're used to.  Try to think of it as an equality test, for example:

    iex> x = 1
    1
    iex> x    
    1
    iex> 1 = x
    1

So far so good, x _is_ equal to 1, so it's all good.  What happens if we try another test?

    iex> 2 = x
    ** (MatchError) no match of right hand side value: 1

Yay, thanks Elixir.  2 doesn't match x, so we got an error.  This is a good thing.  We can use pattern matching to match data structures too:

    iex> [head|tail] = [1,2,3,4]
    [1, 2, 3, 4]
    iex> head
    1
    iex> tail
    [2, 3, 4]

We use this a lot in recursion, lists behave more like linked lists rather than normal arrays in other languages.  We can also pick values out from maps:

    iex> muse = %{:dom => :drums, :chris => :bass, :matt => :lead}  
    %{chris: :bass, dom: :drums, matt: :lead}
    iex> %{:dom => instrument} = muse
    %{chris: :bass, dom: :drums, matt: :lead}
    iex> instrument
    :drums

We can also use patten matching in function heads, ie:

    defmodule Dojo.Hello do
      @moduledoc "Let's say hello"
      
      @doc """
      Says hello to you in Swedish.
      """
      def se("ida") do
        "Hej Hej Ida!"
      end
      def se(person) do
        "Hej #{inspect person}"
      end
    end

If we don't care what a value is, we can add the pattern matching placeholder `_`, or use `_` as the start of a variable we'll never use, ie:

    case RATM.jump do
      {:ok, how_high} ->
        Logger.debug fn -> "I really want to jump #{how_high}" end
        :ok
      {:error, reason} ->
        {:error, reason}
      _other ->
        Logger.warn fn -> "Some other thing happened" end
    end
        
Modify your Actor.add/2 function to return `:snake_eyes` if both values are 1.  Falling back to normal operation if not.

Documentation
-------------

Documentation in Elixir is a first class citizen (surprise surpirise, in a modern language).  We can add documentation to modules and functions with `@moduledoc` and `@doc`.

Add a @doc section to your "add" function, ie:

    @doc ~S"""
    My Cat goes meow.
    """
    def cat do
      :meow
    end

Now you can get some help from the shell:

    iex> h Enum

.. will give you the `@moduledoc` from the Enum module.  Do the same for your module and function.  It uses markdown formatting.

Pipe operator
-------------

The pipe operator is similar to F# but it will supply the first argument to the next function in the chain, not the last (`<ackbar>It's a trap!</ackbar>`).

For example, the documentation for Enum.reverse states:

    reverse(collection) 	Reverses the collection

.. which means that we can pass it a collection with the pipe operator as:

    [1,2,3,4] |> Enum.reverse

Or to fetch the 3rd element in the list:
    [1,2,3,4] |> Enum.fetch(2)

You can think of a pipe as marking points where we transform data.

Let's build a MUD
-----------------

Oh, iex has tab complete for module and function names, how cool is that?
If you want to find out which functions the `String` module has, just type `String.<tab>`.
Erlang and Elixir tends to list the arity of the function (how many parameters the function takes).
If you want to see more, just type `h String.strip` for example.

Ok, let's have a go at a really basic MUD.  First create a new project with a supervision tree:

    mix new game --sup

The first thing to do is to make a `lib/game` directory.  Grab the `*.ex` from the skeleton project, they go in your new `lib/game` directory.  

* lib/game/board.ex

This will represent the 2d game board.  You'll need to come up with some better descriptions, my rooms are probarbly pretty lame.  Let's try the Agent.

    snapper$ iex -S mix
    Erlang/OTP 17 [erts-6.3] [source] [64-bit] [smp:2:2] [async-threads:10] [hipe] [kernel-poll:false]
    
    Compiled lib/game/board.ex
    Compiled lib/game/acceptor.ex
    Compiled lib/game/listener.ex
    Compiled lib/game/player_position.ex
    Generated game.app
    Interactive Elixir (1.0.3) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> {:ok, pid} = Game.Board.start_link
    {:ok, #PID<0.114.0>}
    iex(2)> {row, column} = Game.Board.start_position
    {2, 1}
    iex(3)> Game.Board.room({row, column})
    
    22:03:21.415 [debug] Fetching row: 2 column: 1
    {:ok, "eight"}
    iex(4)> 

A #PID is a process ID.  Whenever we spawn a process or start an OTP managed process, we get a process ID.  If we want to interact with the process, we'll need to keep it.  If we're just interested in the side effects of the process, maybe not.  In this case, `Game.Board.start_link` returns `{:ok, pid}` so that it can be managed by an OTP supervisor.

The main board is defined in the `newboard` function.


* lib/game.ex

Now let's setup our supervision tree (quit iex first with ctrl+c, ctrl+c).  Your `lib/game.ex` file defines the supervisor. `mix` will have given you an empty supervisor skeleton, we need to add the following workers and a task supervisor:

    defmodule Game do
      use Application
    
      # See http://elixir-lang.org/docs/stable/elixir/Application.html
      # for more information on OTP Applications
      def start(_type, _args) do
        import Supervisor.Spec, warn: false
    
        children = [
          # Define workers and child supervisors to be supervised
          supervisor(Task.Supervisor, [[name: Game.TaskSupervisor]]),
          worker(Game.Board, []),
          worker(Game.Player, []),
          worker(Task, [Game.Listener, :acceptor, []])
        ]
    
        # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
        # for other strategies and supported options
        opts = [strategy: :one_for_one, name: Game.Supervisor]
        Supervisor.start_link(children, opts)
      end
    end


Wandering around
----------------

Ok, our MUD isn't up to much at the moment.  Let's let our user wander round.

If the user enters "north" at our direction prompt, move them north and show the new room description.
Same for the other three directions (south, east and west).

Player position
---------------

Now that we know where the player is, we should be able to keep their position across sessions. The Player and Board Servers are still running even when our acceptor processs isn't.  Welcome the player back if they're already registered.

Other Players
-------------

Can we register more than one player in the game?  If another player's in the same room as us, we want to know who's there.

Special skills
--------------

Players may be able to collect special skills as they travel about.

Chat
----

If another player's in the same room as us, can we chat to the other player?  Getting messages between processes is easy, as long as you know the pid; and the other process is listening.


Lots of extra stuff
-------------------

There's a lot more to the language, such a behaviours, protocols, macros etc.  Have a look at http://elixir-lang.org for more.  Jose Valim has done a [How I Start](http://www.howistart.org/posts/elixir/1) using the game Portal as an example.
