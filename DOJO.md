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

```elixir
defmodule Dojo.Hello do
  @moduledoc "Let's say hello"
  
  @doc """
  Says hello to you in Swedish.
  """
  def se(person) do
    "Hej #{inspect person}"
  end
end
```

If you're coming from Ruby, don't forget the `do` on the end of the function `def`.
Now start iex (interactive Elixir) with `iex -S mix`.  Here's the output we're expecting:

    iex(1)> Dojo.Actor.add(1,2)
    3
    iex(2)> 

Exit iex with crtl+c, ctrl+c.

Just as a side note, if you come from Ruby, you'll recognise the `"#{var}"` syntax.  This is how we include variables in strings.  Notice that we use `#{inspect person}` rather than just `#{person}`.  This is because Elixir uses a 'protocol' to give us a string representation of a term.  The `String.Chars` protocol looks like:

```elixir
import Kernel, except: [to_string: 1]

defprotocol String.Chars do
  @moduledoc ~S"""
  The String.Chars protocol is responsible for
  converting a structure to a Binary (only if applicable).
  The only function required to be implemented is
  `to_string` which does the conversion.

  The `to_string` function automatically imported
  by Kernel invokes this protocol. String
  interpolation also invokes to_string in its
  arguments. For example, `"foo#{bar}"` is the same
  as `"foo" <> to_string(bar)`.
  """

  def to_string(thing)
end

defimpl String.Chars, for: Atom do
  def to_string(nil) do
    ""
  end

  def to_string(atom) do
    Atom.to_string(atom)
  end
end

# ... skip to the end ...

defimpl String.Chars, for: Float do
  def to_string(thing) do
    IO.iodata_to_binary(:io_lib_format.fwrite_g(thing))
  end
end

```

It's what gives us polymophism in Elixir.  We can define different implementations for different types.

Anyway, back to our Actor.  If you've added a `@doc` to your function, try `h Dojo.Actor.add` in iex.

Don't forget to recompile your module if you make changes.  You can either quit iex with ctrl+c, ctrl+c, it'll recompile when you start iex; or you can use `r(Dojo.Actor)`.

The Actor Model
---------------

There's a reason we called our module `Actor`.  Erlang (and by extension Elixir) has a very strong actor model.  All Elixir code runs in a 'process'.  This is a very lightweight process inside the Erlang VM, not an operating system process.  This means we don't have the usual problems with threading (locking or sharing memory).  The only way to talk to another process is to send messages.  There's probably an actor model in your normal language (Orleans, Akka etc).

One of the reasons I started looking at Erlang and Elixir was because processors aren't getting faster.  We're getting lots more cores, so we need to learn how to program in a concurrent system.  This is something that Erlang has been doing for years, and now we have a Ruby-esque language that runs on this solid VM.  Let's have a look.

Here's an example from [elixir-lang.org](http://elixir-lang.org):

```elixir
parent = self()

# Spawns an Elixir process (not an operating system one!)
spawn_link(fn ->
  send parent, {:msg, "hello world"}
end)

# Block until the message is received
receive do
  {:msg, contents} -> IO.puts contents
end
```

The `self()` call will return the current process' process ID (or PID).  We then spawn another Elixir process that's linked to our process with `spawn_link`.  What this means is that if our new child process crashes, we crash too.  Then we start blocking and wait for messages coming back to us.  If the received message matches the pattern `{:msg, contents}` (more on this later) then we'll print the output to the console.  'spawn_link' takes an anonymous function that just sends a message back to the parent.

Add the following function to the `lib/dojo.ex` file:

```elixir
defmodule Dojo do

  @doc """
  Spawn a process to add two numbers together.
  """
  def actortest(x, y) do
    pid = self()
    spawn_link(fn ->
      Dojo.Actor.add(x, y, pid)
    end)
    
    receive do
      {:msg, result} -> result
    end
  end

end
```

Now create a `Dojo.Actor.add/3` function to send the result back as a message.  You'll see this syntax a lot, it just signifies the arity (number of parameters) of the function.  You can leave your `Dojo.Actor.add/2` function as it is.  Try `Dojo.Actor.actortest/2` in iex.  Iex even has tab complete for modules and function names.
 
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

Atoms are the same as symbols in other languages.  Almost like a constant (in those without symbols), but without needing to be tied to an integer, for example.

Lists typically hold a variable number of items (may be different types):

    iex> [1,2,3, "four"]
    [1, 2, 3, "four"]

Tuples typically hold a fixed number of items.  It's common to see things like `{:ok, "value"}` or `{:error, reason}` returned by functions (where `reason` is a description of the problem).

    iex> {:ok, "hello"}
    {:ok, "hello"}

Because lists of tuples with the first value as an atom is so common, Elixir has a nicer way to represent this:

    iex> [{:milk, 2}, {:bread, 1}]
    [milk: 2, bread: 1]

Both of these are the same.

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

Also notice that the representation is similar to the list of tuples (and Ruby's hashes, for that matter).  This only happens when we use atoms as keys.

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

As you can see, we've picked up a curious thing from the Erlang shell.  If a list can be entirely repesented in ASCII, then that's how the shell prints the list.  For the most part you don't have to worry about it because we tend to use binary strings in Elixir.

The other representation is as a binary string.  This tends to be the most used string type in Elixir.

    iex> "hello"
    "hello"

With Elixir's Ruby influence comes the String module.  Try some of the String functions in iex (remember you can tab complete).  If you want help, just do `h String.<function name>`, for example:

    iex> h String.upcase

Pattern matching
----------------

Pattern matching is everywhere in Elixir.  You've already seen some in our receive block while waiting for messages.

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

Yay, thanks Elixir.  2 doesn't match x, so we got an error.  This is a good thing.  The rules are that if a variable is 'unbound' and we pattern match, we'll bind a value to the variable.  Elixir does allow re-binding variables within a function, but we can use the pin operator (`^`) to avoid this:

    iex> x = 1
    1
    iex> ^x = 2
    ** (MatchError) no match of right hand side value: 2
    iex> {y, ^x} = {2, 1}
    {2, 1}
    iex> y
    2
    iex> {y, ^x} = {2, 2}
    ** (MatchError) no match of right hand side value: {2, 2}

We can use pattern matching to match data structures too:

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

```elixir
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
```

If we don't care what a value is, we can use the pattern matching placeholder `_`, or use `_` as the start of a variable we'll never use, ie:

```elixir
case RATM.jump do
  {:ok, how_high} ->
    Logger.debug fn -> "I really want to jump #{how_high}" end
    :ok
  {:error, reason} ->
    {:error, reason}
  _other ->
    Logger.warn fn -> "Some other thing happened" end
end
```
        
Modify your Actor.add/2 function to return `:snake_eyes` if both values are 1.  Falling back to normal operation if not.

Documentation
-------------

Documentation in Elixir is a first class citizen (surprise surpirise, in a modern language).  We can add documentation to modules and functions with `@moduledoc` and `@doc`.

Add a @doc section to your "add" function, ie:

```elixir
@doc ~S"""
My Cat goes meow.
"""
def cat do
  :meow
end
```

Now you can get some help from the shell:

    iex> h Enum

.. will give you the `@moduledoc` from the Enum module.  Do the same for your module and function.  It uses markdown formatting.

Doctests
--------

You may have noticed that a lot of inbuilt functions have examples in the documentation.  These examples can also be used as tests.  If we detect lines starting with four spaces, then `iex>`, we'll use it as a test.

Here's an example of a doctest for our `cat` function above.

```elixir
defmodule Dojo do

  @doc ~S"""
  My Cat goes meow.
  
  Example
  
      iex> Dojo.cat
      :meow
  
  """
  def cat do
    :meow
  end

end
```

Then in `test/dojo_test.ex`, we just have:

```elixir
defmodule DojoTest do
  use ExUnit.Case, async: true
  doctest Dojo
end
```

.. now we can run `mix test`.  Add some doctests to your `Dojo.Actor.add/2` function.

Pipe operator
-------------

The pipe operator is similar to F# but it will supply the first argument to the next function in the chain, not the last (F# people: `<ackbar>It's a trap!</ackbar>`).

For example, the documentation for Enum.reverse states:

    reverse(collection) 	Reverses the collection

.. which means that we can pass it a collection with the pipe operator as:

    [1,2,3,4] |> Enum.reverse

Or to fetch the 3rd element in the list:
    [1,2,3,4] |> Enum.fetch(2)

You can think of a pipe as marking points where we transform data.

Let's build a MUD
-----------------

Ok, let's have a go at a really basic MUD.  First create a new project with a supervision tree:

    mix new game --sup

The first thing to do is to make a `lib/game` directory.  Grab the `*.ex` from the skeleton project, they go in your new `lib/game` directory.  

* lib/game/board.ex

This will represent the 2d game board.  You'll need to come up with some better descriptions (in `Game.Board.newboard/0`), my rooms are probarbly pretty lame.  Let's try the Agent.

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

The main board is defined in the `newboard` function.  The rows and columns are just lists.

* lib/game.ex

Now let's setup our supervision tree (quit iex first with ctrl+c, ctrl+c).  Your `lib/game.ex` file defines the supervisor. `mix` will have given you an empty supervisor skeleton, we need to add the following workers and a task supervisor:

```elixir
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
```

* lib/game/player.ex

  This deals with players.  We can register players with the game, update their position and things in the bag they're carrying.

* lib/game/listener.ex

  This listens on the TCP socket and launches `Game.Acceptor.start/1`.


Wandering around
----------------

From here on in, most of our changes will be in `acceptor.ex`.  This is the process that's launched when a client connects.

Telnet to port 4040 on your machine, you should be able to enter a player name and type 'quit' at the `command>` prompt.

Ok, our MUD isn't up to much at the moment.  Let's let our user wander about.

If the user enters "north" at our direction prompt, move them north , show the new room description, then wait for another command.  Same for the other three directions (south, east and west).  You can use `Game.Player.move/2` to move the player.

* tip

  Don't forget you have tab complete and help in the `iex` shell.

Houston?
--------

Let's try a little experiment because yes, we have a problem.  Assuming you haven't fixed it already, what happens if a player enters a command other than north, south, east, west or quit?  Oh no, our Acceptor crashes!

Try this.  Connect two clients to our game, they should use different player names.  In one of the telnet windows, send a bad command and watch it crash, leave the other at the `command>` prompt.  Keep the Elixir shell running.  Now add a drop through case statement in `acceptor.ex` (have a look at the pattern matching section if you want an example).  Just display valid commands, then go back into the main loop.

Once you've saved the file, reload the module with:

    iex> r(Game.Acceptor)

Now you should be able to telnet back in and issue a bad command.  However, our other session is still active.  We can type 'quit' and quit normally.

Hello Joe; Hello Mike!

Player position
---------------

Now that we know where the player is, we should be able to keep their position across sessions. The Player and Board processes are still running even when our acceptor processs isn't.  Welcome the player back if they're already registered.

Look at the way that `case` uses pattern matching.  We should be able to use this to make an appropriate greeting.

Other Players
-------------

Can we register more than one player in the game?  If another player's in the same room as us, we want to know who's there.  `Game.Player.at/1` will return a list of players at a position on the board.

Collecting things
-----------------

Players may be able to collect things as they travel about.  They certainly have a bag, check out `Game.Player.bag/1` and `Game.Player.add_to_bag/2`.  You'll notice that `Game.Board.room/1` returns a tuple with one value.  Now's the time to add things to rooms.  Update `Game.Board.newboard/0` and add some items.

The traditional way would be something like this:

    {"room description"}
    .. becomes
    {"room description", [{:apple, 5}, {:gold, 1}]}

Chat
----

This is a bit trickier.

If another player's in the same room as us, can we chat to the other player?  Getting messages between processes is easy, as long as you know the pid; and the other process is listening.


Lots of extra stuff
-------------------

There's a lot more to the language, such a behaviours, protocols, macros etc.  Have a look at http://elixir-lang.org for more.  Jose Valim has done a [How I Start](http://www.howistart.org/posts/elixir/1) using the game Portal as an example.  Videos from the Elixir conferences have made it to [confreaks.tv](http://confreaks.tv/tags/40).
