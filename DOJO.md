Try some Elixir!
================

Prereqs
-------

* An installation of [Elixir](http://elixir-lang.org/install.html).
* A telnet client (ie [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) on windows or 'telnet' on linux)

The default windows telnet client does still work if you enable it in Windows Features.  Local echo always used to be off by default, if that's still the case try something like this:

    C:\> telnet
    set localecho
    open localhost 4040

Numbers, lists, tuples and maps etc
-----------------------------------

The Elixir interactive shell is called `iex`.  Linux or OSX users can just type `iex` from a terminal.  There's a note for Windows users that might help:

Note: if you are on Windows, you can also try iex.bat --werl which may provide a better experience depending on which console you are using.

To quit `iex`, there's a quite inelegant ctrl+c, ctrl+c.

`iex` is the REPL (Read, Evaluate, Print Loop) for Elixir, we can type in an Elixir expression and get the result.  You'll notice that even simple things like integer numbers are an expression, they just return themselves.  If you press return at the `iex` prompt, it'll evaluate to `nil`.

In Elixir (and Erlang) documentation, you'll see functions referred to as `Dojo.Actor.add/2`.  It's just a way of describing the `add` function in the `Dojo.Actor` module that takes two parameters.  This is referred to as the arity of the function (the number of parameters it takes).

Let's experiment with data types in iex:

Try these:

#### Numbers

    iex> 1 + 4
    5

#### Strings

    iex> "jim" <> "bob"
    "jimbob"

#### Atoms

    iex> :hello
    :hello

Atoms are the same as symbols in some other languages (Ruby being one).  Almost like a constant, but without needing to be tied to an integer, for example.

Functions in the `Kernel` module are automatically imported (that is to say, you can just call `is_atom(:atom)` rather than `Kernel.is_atom(:atom)`.  The docs for the Kernel module are here: http://elixir-lang.org/docs/stable/elixir/Kernel.html

Try finding the remainder of an integer division.

Try using `inspect` to inspect an atom, notice how it can turn it into a string.  `inspect` will pretty print a data structure.

#### Lists

Lists typically hold a variable number of items (may be different types):

    iex> [1,2,3, "four"]
    [1, 2, 3, "four"]

To work with lists, you typically use the `Enum` module.  I remember it because it's a bit like the `Enumerable` mixin in Ruby, but if you come from another language I could see this being a strange one.  Have a look at the [docs](http://elixir-lang.org/docs/stable/elixir/Enum.html), just check your version if you're not running Elixir 1.1.

In Elixir (and Erlang) we typically add things to the head of a list, rather than pushing onto the tail (it's more expensive), the syntax looks like:

    iex> old_list = [1,2,3,4]
    [1, 2, 3, 4]
    iex> new_list = [ "new thing" | old_list ]
    ["new thing", 1, 2, 3, 4]

You'll see this syntax again when we start pattern matching heads and tails of lists.

Try using `Enum.take_random/2` to take a random item from the `old_list` array above.  If the Elixir gods are smiling on you, you should have tab completion for modules and functions in the Elixir shell.

#### Tuples

Tuples typically hold a fixed number of items.  It's common to see things like `{:atom, "value"}`, but they can hold anything.  It's also common to see `{:ok, "value"}` or `{:error, reason}` returned by functions (where `reason` is a description of the problem).

    iex> {:ok, "hello"}
    {:ok, "hello"}
    iex> {1,2,3,:moo}
    {1, 2, 3, :moo}

Because lists of tuples with the first value as an atom is so common, Elixir has a nicer way to represent this:

    iex> [{:milk, 2}, {:bread, 1}]
    [milk: 2, bread: 1]

Both of these are the same.

#### Maps

Maps are similar to hashes or dictionaries in other languages.  If the key is an atom, then you can access the value with the dot notation.  It'll raise a KeyError if the key doesn't exist.

Try this:

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

Also notice that the representation on the second line is similar to the list of tuples (and Ruby's hashes, for that matter).  This only happens when we use atoms as keys.

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

The docs for the String module are here: http://elixir-lang.org/docs/stable/elixir/String.html in case you don't have tab complete in your shell.

Try using `String.rjust` or `String.ljust` to justify strings.  The `\\` in the docs just signifies the default value of a parameter.  If you want to print the value out, have a look at `IO.puts`.

Pattern matching
----------------

Pattern matching is everywhere in Elixir.

The `=` operator in Elixir is a bit different to what we're used to.  You can use it to assign values:

    iex> x = 1
    1
    iex> x    
    1

.. but it's actually called the 'match operator'.  Try to think of it as a matching operation, for example:

    iex> 1 = x
    1

So far so good, x _is_ equal to 1, so it's all good.  What happens if we try another test?

    iex> 2 = x
    ** (MatchError) no match of right hand side value: 1

Yay, thanks Elixir.  2 doesn't match x, so we got an error.  This is a good thing.

We can use pattern matching to match data structures too.  Try this:

    iex> [head|tail] = [1,2,3,4]
    [1, 2, 3, 4]
    iex> head
    1
    iex> tail
    [2, 3, 4]

    iex> [x,y] = [10,20]
    [10, 20]
    iex> x
    10
    iex> y
    20


We use the `head|tail` thing a lot in recursion, lists behave more like linked lists rather than normal arrays in other languages.

You can also do the same thing for other structures too.  Try picking the second value out of a tuple such as `{:jimbob, :fruitbat}`.

We can also pick values out from maps:

    iex> muse = %{:dom => :drums, :chris => :bass, :matt => :lead}  
    %{chris: :bass, dom: :drums, matt: :lead}
    iex> %{:dom => instrument} = muse
    %{chris: :bass, dom: :drums, matt: :lead}
    iex> instrument
    :drums

We use patten matching in function heads too, ie:

```elixir
defmodule Dojo.Hello do
  
  @doc """
  Says hello to you.
  """
  def hello("Anna") do
    "Hey Anna, how's it going?"
  end
  def hello(person) do
    "Hello #{inspect person}"
  end
end
```

If we don't care what a value is, we can use the pattern matching placeholder `_`, or use `_` as the start of a variable we'll never use, ie (the `RATM.jump` function will return one of these tuples, or something else):

```elixir
case RATM.jump do
  {:ok, how_high} ->
    Logger.debug fn -> "I really want to jump #{how_high}" end
    :ok
  {:error, reason} ->
    {:error, reason}
  {:tea, _} ->
    Logger.debug fn -> "It's tea time, we'll try again later" end
    :tea
  _other ->
    Logger.warn fn -> "Some other thing happened" end
end
```

Modify your `Dojo.Actor.add/2` (the one with two parameters) function to return `:snake_eyes` if both values are 1.  Falling back to normal operation if not.

Documentation
-------------

We won't do it right now, but documentation in Elixir is a first class citizen (surprise surpirise, in a modern language).  We can add documentation to modules and functions with `@moduledoc` and `@doc` (it uses markdown formatting):

```elixir
@doc """
My Cat goes meow.
"""
def cat do
  :meow
end
```

The `"""` quotes are how you create multi-line strings (or 'heredocs').

Now we can get some help from the shell:

    iex> h MyModule.cat

Doctests
--------

You may have noticed that a lot of inbuilt functions have examples in the documentation.  These examples can also be used as tests.  If the doctests system detects lines starting with four spaces, then `iex>`, we can use it as a test.

Here's an example of a doctest for our `cat` function above (we'd always expect `Dojo.cat` to return the atom `:meow`).

```elixir
defmodule Dojo do

  @doc """
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

We won't go into doctests right now because we've got a lot to do, but have a look at this if you get time later: http://elixir-lang.org/getting-started/mix-otp/docs-tests-and-pipelines.html#doctests

Pipe operator
-------------

The pipe operator is similar to F# but it will supply the first argument to the next function in the chain, not the last (F# people: `<ackbar>It's a trap!</ackbar>`).

For example, the documentation for Enum.reverse states:

    reverse(collection) 	Reverses the collection

.. which means that we can pass it a list (have a look at the `Enumerable` protocol if you want to know more about the `collection` thing) with the pipe operator as:

    [1,2,3,4] |> Enum.reverse

Or to fetch the 3rd element in the list:

    [1,2,3,4] |> Enum.fetch(2)

You can think of a pipe as marking points where we transform data.

Using this L7 lineup (L7 are a band, in case you don't know them): `["gardner", "sparks", "jett", "finch", "plakas"]`.

Try to capitalize the first character of each name with `String.capitalize/1` in the anonymous function used in `Enum.map/2`, then make the list into a string, joined by " + " (look at `Enum.join/2` for that).  The pipe operator makes this kind of thing really readable.  Remember that documentation is either online http://elixir-lang.org/docs/stable/elixir/Kernel.html or in iex 'h Enum.map'.

Mix
---

Mix is a tool to help create Elixir projects.  It will create a skeleton project with a single passing test.
It can also be extended and used to do things like hook into the [Hex](http://hex.pm) package management system to deal with dependancies.

Create a new project
-------------------

We can create a new project with 'mix new'.

Try this:

    snapper:~$ mix new dojo
    snapper:~$ cd dojo

Our code goes in the `lib` directory.  If we want to add more than one module in the `Dojo` namespace, we need to create a subdirectory in `lib`.  This is pretty common, so create a `dojo` directory:

    snapper:~/dojo$ mkdir lib/dojo

You should wind up with a directory structure like this:

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

Mix has provided a (small) module, in `lib/dojo.ex`.  It doesn't do much at the moment. 

You'll notice that mix has created us a test too, in `test/dojo_test.exs`.  This just has one test defined that will always pass when we run `mix test`.  The `config` directory holds configuration that we can read from code, but we won't be using that in this dojo.  `mix.exs` is configuration for mix itself, we use it to pull in things like dependancies.  Again, we won't need to touch that in this dojo.

Create a module `Dojo.Actor`, it goes in the file `lib/dojo/actor.ex`.  Then create a function `Dojo.Actor.add` that takes two integer arguments and adds the result together.

Modules start with a capital letter, functions are typically lowercase, underscores, numbers and ? or !.  We follow a similar convention to Ruby, in that functions that return true or false are named with a question mark at the end, for example: `Foo.is_odd?(5)`.

As an example, a "hello world" below:

```elixir
defmodule Dojo.Hello do
  
  @doc """
  Says hello to you.
  """
  def hello(person) do
    "Hello #{inspect person}"
  end
end
```
If you're coming from Ruby, don't forget the `do` on the end of the function `def` (yes, I've done it; lots).

Now start iex (interactive Elixir) with `iex -S mix` from the base of your project directory (ie, the same directory that the `mix.exs` file is in).  This will compile your code into a `beam` file for the Erlang VM, then run it interactively.  In production, you can run the VM without the shell, then connect a shell afterwards to aid debugging.

Here's the output we're expecting:

    iex(1)> Dojo.Actor.add(1,2)
    3
    iex(2)> 

Exit iex with crtl+c, ctrl+c.

Don't forget to recompile your module if you make changes.  You can either quit iex with ctrl+c, ctrl+c, it'll recompile when you start iex; or you can use `r(Dojo.Actor)` from within the shell.

The Actor Model
---------------

There's a reason we called our module `Actor`.  Erlang (and by extension Elixir) has a very strong actor model.  All Elixir code runs in a 'process'.  This is a very lightweight process inside the Erlang VM, not an operating system process.  This means we don't have the usual problems with threading (locking or sharing memory).  The only way to talk to another process is to send messages.  There's probably an actor model in your normal language (Orleans, Akka etc).

One of the reasons I started looking at Erlang and Elixir was because processors aren't getting faster.  We're getting lots more cores, so we need to learn how to program in a concurrent system.  This is something that Erlang has been doing for years, and now we have a Ruby-esque language that runs on this solid VM.  It's not magic, but it does make concurrency much easier to handle.  Let's have a look.

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

The `self()` call will return the current process' Elixir process ID (or PID).  We then spawn another Elixir process that's linked to our process with `spawn_link`.  What this means is that if our new child process crashes, we crash too.  Then we start blocking and wait for messages coming back to us.  If the received message matches the pattern `{:msg, contents}` then we'll print the output to the console.  'spawn_link' takes an anonymous function that just sends a message back to the parent.

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

Now create a `Dojo.Actor.add` function that takes three parameters and sends the result back as a message.  You can leave the old two parameter function as it is.  If you call `add` with three parameters, it'll use your new version.  If you call it with two parameters, it'll use your original function.  You'll see this quite a lot in the built in libraries.

For example:

```elixir
defmodule Foo.Bar do

  # This would be referred to as my_function/2 in the documentation.
  def my_function(x,y) do
    :ok
  end

  # This would be referred to as my_function/3 in the documentation.
  def my_function(x,y,z) do
    :ok
  end

end
```

What happens when your run the `Dojo.actortest` function from the shell?  I know it doesn't look very exciting but it's actually passing messages between the two processes.

Let's build a MUD
-----------------

Ok, let's have a go at a really basic MUD.  First create a new project with an OTP supervision tree:

Don't do this in your existing 'dojo' directory, go back a directory first.  This will create a new 'game' directory.  Try this:

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
    {3, 1}
    iex(3)> Game.Board.room({row, column})
    
    22:03:21.415 [debug] Fetching row: 3 column: 1
    {:ok, "Welcome to the forest, please go north to start your journey."}
    iex(4)> 

A #PID is a process ID.  Whenever we spawn a process or start an OTP managed process, we get a process ID.  If we want to interact with the process, we'll need to keep it.  If we're just interested in the side effects of the process, maybe not.  In this case, `Game.Board.start_link` returns `{:ok, pid}` so that it can be managed by an OTP supervisor.

The main board is defined in the `newboard` function.  The rows and columns are just lists.

* lib/game.ex

Now let's setup our supervision tree (quit iex first with ctrl+c, ctrl+c).  Your `lib/game.ex` file defines the supervisor. `mix` will have given you an empty supervisor, we need to add the following workers and a task supervisor:

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

When you run `iex -S mix`, it'll compile and run your code, so you'll need to do that before you try and connect a client.  When you telnet in to your server with `telnet 0 4040`, or `telnet localhost 4040`, the Listener module will be listening on the socket.  It'll accept the connection and spawn a process which runs the `Game.Acceptor` module's `start/1` function.

Wandering around
----------------

Until we start collecting things, all of our changes will be in `acceptor.ex`.  This is the process that's launched when a client connects.

Telnet to port 4040 on your machine, you should be able to enter a player name and type 'quit' at the `command>` prompt.

Ok, our MUD isn't up to much at the moment.  Let's let our user wander about.

If the user enters "north" at our direction prompt, move them north , show the new room description, then wait for another command.  Same for the other three directions (south, east and west).  You can use `Game.Player.move/2` to move the player (`h Game.Player.move` for help in the shell).

Houston?
--------

Let's try a little experiment because yes, we have a problem.  Assuming you haven't fixed it already, what happens if a player enters a command other than north, south, east, west or quit?  Oh no, our Acceptor crashes!

Try this.  Connect two clients to our game, they should use different player names.  In one of the telnet windows, send a bad command and watch it crash, leave the other at the `command>` prompt.  Keep the Elixir shell running.  Now add a drop through case statement in `acceptor.ex` (have a look at the pattern matching section if you want an example).  Just display the valid commands, then go back into the main loop.

Once you've saved the file, reload the module with:

    iex> r(Game.Acceptor)

Now you should be able to telnet back in and issue a bad command.  However, our other session is still active.  We can type 'quit' and quit normally.

Hello Joe; Hello Mike!

Player position
---------------

Now that we know where the player is, we should be able to keep their position across sessions. The Player and Board processes are still running even when our acceptor processs isn't.  Welcome the player back if they're already registered (have a look at what `Player.register/1` returns).

Look at the way that `case` uses pattern matching.  We should be able to use this to make an appropriate greeting.

Other Players
-------------

We know that we can register more than one player.  Wouldn't it be nice if they knew about each other?  If another player's in the same room as us, we want to know who's there.  `Game.Player.at/1` will return a list of players at a position on the board.

Try to think about how Unix command line tools work.  We take small, dedicated programs and use the pipe operator to link them together to transform the data.  That's similar to what we're doing in Elixir.  We make small functions, you could call it 'parsing' the input with pattern matching, then output some data.  We link these small functions with the pipe operator to transform data.  Or at least, that's the ideal.

You already have the name of the player, so could you use that in a pattern match?

Collecting things
-----------------

Players may be able to collect things as they travel about.  They certainly have a bag, check out `Game.Player.bag/1`, `Game.Player.add_to_bag/2` and `Game.Player.replace_bag/2`.  You'll notice that `Game.Board.room/1` returns a tuple with one value.  Now's the time to add things to rooms.  Update `Game.Board.newboard/0` and add some items.

The traditional way would be something like this:

    {"room description"}
    .. becomes
    {"room description", [{:apple, 5}, {:gold, 1}]}

The first thing to do is to format a message for the user if we come across a room with items in.  Then you could just automatically pick up the items or maybe ask the player first?  If a player picks up a duplicate item, you should update the count of the item in the players bag.  From here, it's up to you what you do with all this stuff.  Could you trade it with other players or use it for a portal to another room or some other special power.

Chat
----

This is a bit trickier.

If another player's in the same room as us, can we chat to the other player?  Getting messages between processes is easy, as long as you know the pid; and the other process is listening.  You can get a player's chat pid with `Game.Player.chat_pid/1` and set a chat pid with `Game.Player.set_chat_pid/2`.  We already know how to send messages between processes and how to `spawn_link` a process.


Lots of extra stuff
-------------------

There's a lot more to the language, such a behaviours, protocols, macros etc.

If you want a good introduction (that's longer than this Dojo), have a look at [Getting Started](http://elixir-lang.org/getting-started/introduction.html).

Dave Thomas' [Programming Elixir](https://pragprog.com/book/elixir/programming-elixir) book is very good.

Jose Valim has done a [How I Start](http://www.howistart.org/posts/elixir/1) using the game Portal as an example.  Videos from the Elixir conferences have made it to [confreaks.tv](http://confreaks.tv/tags/40).  [Phoenix](http://www.phoenixframework.org/) is a niceElixir web framework.

I don't know if it's just because I'm already into it, but it does seem to be gaining momentum at the moment.  Have fun.
