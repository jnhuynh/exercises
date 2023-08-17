# How to execute

`./apply_changes.rb input.json changes.json output.json`

- `input.json`: can be any JSON file in the structure outlined in the "Structure of Input file" section.
- `changes.json`: can be any JSON file in the structure outlined in the "Structure of Change file" section.
- `output.json`: any filename. _NOTE_ existing files will be overwritten.

# Acceptance Criteria for Changes file

- Add an existing song to an existing playlist
- Add a new playlist for existing user; playlist should contain at least 1 existing song
- Remove an existing playlist

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

- "playlist.add_song": requires 2 arguments, first argument is ID of a playlist, second is ID of a song
- "user.create_playlist": requires 2 arguments, first argument is ID of a user, second is ID of a song
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
  - very large input files
  - large changes files

# Time to implement
