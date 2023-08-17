# How to execute

`./apply_changes.rb path_to_input.json path_to_changes.json path_to_output.json`

- `path_to_input.json`: can be any JSON file in the structure outlined in the "Structure of Input file" section.
- `path_to_changes.json`: can be any JSON file in the structure outlined in the "Structure of Change file" section.
- `path_to_output.json`: any filename. _NOTE_ existing files will be overwritten.

### Debugging

To validate output, pass any arbitrary 4th argument to enable debug logs or explicitly set it in source code.

# Design Decisions/Considerations

### Structure of Input file

```json
{
  "users": [
    {
      "id": "string",
      "name": "string"
    }
  ],
  "playlists": [
    {
      "id": "string",
      "owner_id": "string",
      "song_ids": ["string"]
    }
  ],
  "songs": [
    {
      "id": "string",
      "artist": "string",
      "title": "string"
    }
  ]
}
```

### Structure of Change file

Available actions: "playlist.add_song", "user.create_playlist", "playlist.destroy"

_NOTE_: All actions are assumed to be in sequential order.

- "user.create_playlist": requires 2 arguments, first argument is ID of a user, second is ID of a song
- "playlist.add_song": requires 2 arguments, first argument is ID of a playlist, second is ID of a song
- "playlist.destroy": requires 1 arguments, the argument is ID of a playlist

```json
{
  "operations": [
    {
      "action": "string",
      "arguments": ["string"]
    }
  ]
}
```

_Thoughts_: this feels like JSON-ifying a list of CRUD operations plus a few one off actions. I opted to go specific for now.

If I wanted this to be more generic in order to support other
operations on song, playlists, and future models, but YAGNI for now:

- I could build out an "argument" object structure that includes type
  e.g. `"arguments": [{ "type": "song", "id": "string" }]`
- Make the actions "CRUD + add" and have the script parse the "arguments"
  to decide what logic should happen
  e.g
  The follow JSON would map to the "playlist.add_song" logic
  ```
  {
     "action": "add",
     "arguments": [
       { "type": "playlist", "id": "2"},
       { "type": "song", "id": "1"}
     ]
   }
  ```

### Output File

- Opted to overwrite if output file already exists since it's simpler.

# Future Improvements

- Scale to handle
  - If the data sources that generate changes & input files can be processed in real time, I'd focus on chunking & deduping the the data sources so that the resulting input & changes files are optimized.
    - Large files can suck up a lot of memory as we read the file. The ideal scenario is to focus on chunking out the files before it becomes too large in the first place
    - Large input files
      - I assume that songs don't change a lot and become massive. Also songs don't belong to a specific user, it's more a shared catalog. As such, I would extract that out into a different data store than a JSON file. Redis cache, DB backed, or something else.
      - I would also split input files into per user files. It goes hand in hand with the strategy below for large change files. Preprocessing it into per user input files.
    - Large changes files
      - You can also segregate the changes into per user change files and then squash various sequential actions in it. This also unlocks parallel processing of changes on a per user basis E.G.
        - Multiple add of a particular song can be squashed into 1 action
        - Multiple deletes of a playlist can be squashed into 1 action
  - If the large input & changes files are provided to us without the possibility of real time pre-processing before the files are generated, we'll have to read the files in byte chunks/stream.
    - Assuming the top level keys of users, songs, and playlists are still valid, I'd process the top level keys as they are streamed in and write to redis or some other data store that allows retrieval of subsets for operations. From there I would apply similar strategies to segregate by user and dedupe actions.
    - There are gems that allow processing specific paths of a JSON file and processsing that value of that path in chunks.
    - I think the high level concept here is to read the JSON, keep track of open and closing braces/brackets, and reading the JSON file in chunks until it can be parsed into meaningful JSON.
    - Things like https://github.com/dgraham/json-stream & https://github.com/brianmario/yajl-ruby will will maintain a state machine and notify on certain conditions, e.g. array of completion and we can then extract out those values to store into less memory intensive data stores for further processing.

### Considerations/Assumptions

- Any invalid operation will fail the entire operation, the assumption here is that operations are serial and may depend on previous operations.
- Assumes that IDs are strings, using UUID for IDs to reduce chances of ID collision
- Assumes that we are creating new playlists with just one song right now. It could easily be extended for multiple songs
- Refactorings are listed as TODOs in source code

### Logic & Test Cases that need to be automated

- Parsing input & changes json
- Ensuring input has users, songs, playlists keys
- Ensuring changes has operations key
- Pending Implementation: Ensuring that operations are properly formatted
- Test the actual actions with automation

# Time to implement

- Actual coding time ~70 minutes.
- Time digesting prompt, thinking through concepts, and writing/updating readme ~30 minutes.
