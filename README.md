# LiveCue

These instructions are for Ubuntu 20.04.

At this stage, using a modest subset of the music collection is recommended. Note that currently only FLAC files are indexed.

## Setup

### 1. Install cmus

`$ sudo apt install cmus`

### 2. Install Erlang and Elixir

1. [Install asdf](https://asdf-vm.com/#/core-manage-asdf).

2. Install Erlang build process dependencies:

	`$ sudo apt install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev`

3. Install Erlang:

	`$ asdf install erlang 23.2.7`

4. Install Elixir:

	`$ asdf install elixir 1.11.3-otp-23`

### 3. Get source code and configure

1. Clone repository:

	`$ git clone git@bitbucket.org:theoliverbros/live_cue.git [<destination>]`

2. `cd` to the new project repo directory. (All subsequent commands should be executed from this directory.)

3. In the `config` directory, copy `dev.secret.exs.example` to `dev.secret.exs`, and populate all values in the new config file.

4. Install Elixir dependencies:

	`$ mix deps.get`

	Answer yes to questions on installing Rebar and Hex.

### 4. Install frontend-related dependencies

1. [Install Node](https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions). (14 LTS recommended.)

2. Install JavaScript dependencies. In the project directory:

	`$ npm install --prefix assets`

## Run for development

1. In a separate terminal, run cmus:

	`$ cmus`

2. Start Phoenix endpoint:

	`$ mix phx.server`

Visit [`localhost:4000`](http://localhost:4000) in your web browser.

While the collection is being indexed each subdirectory should be printed to stdout.

To stop the app, press Ctrl+C twice.

## Learn about Phoenix

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
