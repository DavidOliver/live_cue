# LiveCue

A Phoenix LiveView-powered shared-file music collection player, for listening in sync with friends.

## Audio file format support

FLAC. (mp3 and m4a support is in progress.)

## Setup

These instructions are for Debian/Ubuntu.

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

5. Install inotify filesystem-watcher Linux interface:

	```
	$ sudo apt install inotify-tools
	```

### 3. Get source code and configure

1. Clone repository:

	```
	$ git clone git@bitbucket.org:theoliverbros/live_cue.git [<destination>]
	```

2. `cd` to the repo directory.

3. Copy `config/dev.secret.exs.example` to `config/dev.secret.exs`, and populate all values in the new config file.

4. Install Elixir dependencies:

	```
	$ mix deps.get
	```

	Answer yes to any subsequent questions on installing Rebar and/or Hex.

### 4. Install frontend-related dependencies

1. [Install Node](https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions). (14 LTS recommended.)

2. Install project JavaScript dependencies:

	```
	$ npm install --prefix assets
	```

## Run

1. In a separate terminal, run cmus:

	```
	$ cmus
	```

2. In the original terminal, start LiveCue:

	```
	$ iex --name <node name> --cookie <pre-shared secret> -S mix phx.server
	```

	For example:

	```
	$ iex --name ian --cookie m0nk3y -S mix phx.server
	```

3. Parse and process local music collection files:

	```
	iex> LiveCue.process_collection()
	```

	This step is only required on the first run and after music collection updates.

4. Connect to the shared network

	For example, ZeroTier.

5. Connect to your friend’s LiveCue node:

	```
	iex> Node.connect(:<node name>)
	```

	For example:

	```
	iex> Node.connect(:david@doliver)
	```

Visit [`localhost:4000`](http://localhost:4000) in your web browser.

Select an album or track and hit play! Play, pause and stop actions should take effect on both your player and that of your friend’s.

To stop the app, press Ctrl+C twice in the LiveCue iex terminal.

## Parsing collection and storing data

Processing collection files into data for use by LiveCue is done in two main steps.

### 1. Parsing collection files

In this step, we obtain basic file and meta data from the music collection’s files, and store the result in the local database.

This step can be individually run in the Elixir interactive terminal:

```
iex> LiveCue.parse_collection_files()
```

### 2. Processing parsed data

In this step, we transform and apply keys for storage to the data generated in step 1, and store the result in the local database. The data generated in this step is read when the LiveCue browser-based interface is used.

This step can be individually run in the Elixir interactive terminal:

```
iex> LiveCue.store_collection_data()
```

As this step uses the data stored by step 1, the code for step 2 can be updated and re-run during development without having to re-parse the collection files, which is a relatively lengthy process.
