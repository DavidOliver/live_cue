# LiveCue

A Phoenix LiveView-powered shared-file music collection player, for listening in sync with friends.


## Audio file format support

FLAC. (mp3 and m4a support is in progress.)


## Set up and configure

### 1. Ensure the Nix package manager is installed

[Instructions](https://zero-to-nix.com/concepts/nix-installer).

### 2. Ensure Devbox is installed

[Instructions](https://www.jetpack.io/devbox/docs/installing_devbox/).

### 3. Get LiveCue source code and configure

1. Clone repository:

	`$ git clone git@bitbucket.org:theoliverbros/live_cue.git <destination-directory>`

2. `cd` to the repository directory.

3. Prepare and enter the environment:

	`$ devbox shell`

4. Run initial setup:

	`$ devbox run setup`

5. Set values in `config/dev.secret.exs`.


## Perform initial run

1. If not already in the Devbox environment:

	`$ devbox shell`

2. Start LiveCue:

	`$ ./start.sh`

	This opens and configures a `tmux` session, in which `cmus` (the audio player) and `LiveCue` itself are run.

3. Parse and process local music collection files:

	```
	iex> LiveCue.process_collection()
	```

	This step is only required on the first run and after music collection updates.

4. Check that playing works locally.

	Visit [`localhost:4000`](http://localhost:4000) in your web browser.

	Choose an album or track and press play!

	To stop the app and close down related services:

	1. Press Ctrl+C twice in the LiveCue iex terminal.
	2. Type `:q` and press Return to quit `cmus`.
	3. `exit` to exit `tmux`.

	(Hopefully, the stopping process will soon be improved.)


## Listen in sync with your friend

1. Open ports `4369` and `9001`, TCP protocol, in your computer’s local software firewall.

2. Connect to the shared network. For example, ZeroTier.

3. Start LiveCue, as per steps 1 and 2 of the initial run.

4. Connect to your friend’s LiveCue node:

	`iex> Node.connect :"<remote node name>"`

	`true` should be returned.

	Example: `iex> Node.connect :"d@177.27.47.107"`

5. Visit [`localhost:4000`](http://localhost:4000) in your web browser.

6. Choose an album or track and press play! Play, pause and stop actions should take effect in both your player and that of your friend’s.


## Notes on parsing collection and storing data

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
