# LiveCue

## Setup

These instructions are for Ubuntu 20.04.

### 1. Install cmus

	$ sudo apt install cmus

### 2. Install languages and supporting packages

1. [Install asdf](https://asdf-vm.com/#/core-manage-asdf).

2. Install Erlang build process dependencies:

	```
	$ sudo apt install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev
	```

3. Install Erlang:

	```
	$ asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
	$ export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"
	$ asdf install erlang 23.2.7
	```

4. Install Elixir:

	```
	$ asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
	$ asdf install elixir 1.11.3-otp-23
	```

5. Install innotify filesystem-watcher Linux interface

	```
	$ sudo apt install inotify-tools
	```

### 3. Get source code and configure

1. Clone repository:

	```
	$ git clone git@bitbucket.org:theoliverbros/live_cue.git [<destination>]`
	```

2. `cd` to the new project repo directory. (All subsequent commands should be executed from this directory.)

3. In the `config` directory, copy `dev.secret.exs.example` to `dev.secret.exs`, and populate all values in the new config file.

4. Install Elixir dependencies:

	```
	$ mix deps.get
	```

	Answer yes to questions on installing Rebar and/or Hex.

### 4. Install frontend-related dependencies

1. [Install Node](https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions). (14 LTS recommended.)

2. Install project JavaScript dependencies. In the project directory:

	```
	$ npm install --prefix assets
	```

## Run for development

1. In a separate terminal, run cmus:

	```
	$ cmus
	```

2. Start LiveCue:

	```
	$ iex --name <node name> --cookie <pre-shared secret cookie> -S mix phx.server
	```

	For example:

	```
	$ iex --name ian --cookie dh30dh2ogiusd8jdujdfisw -S mix phx.server
	```

Visit [`localhost:4000`](http://localhost:4000) in your web browser.

To stop the app, press Ctrl+C twice.

## Learn about Phoenix

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
