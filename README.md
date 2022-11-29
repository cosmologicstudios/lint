# lint# lint

🌱 A tiny tool for writing dialogue. 

🖍️ Write conversations made of lines. 

💬 Use the template line types: default and choice.

🌀 Or create your own line types with any fields you want.

🚀 Export your data to JSON or YAML.

## How it Works

A project is made up of **Conversations**, which are made up of Lines. Each line has a Type, which determines its Fields.

**Default** lines are spoken by an NPC. 

```yaml
id: Value                 // A randomly generated UUID. We can use this unique identifier for localisation, audio, etc.
type: LineType            // The Type of the line. This will either be "default" or "choice".
text: Value               // The actual line of dialogue.
speaker: Value            // The character who speaks the line.
animation: Value          // Set the animation of the speaker.
goto: List(               // The line we will "go to" next. 
  condition: Value,       // We can set multiple entries of lines to "go to" with conditions;
  line: Line              // For example, we may want to go to line3 if gold > 10 but otherwise go to line 4.
)                         
signals: List(Signal)     // A list of "signals" or game triggers, eg: "change_variable gold add 100".
```
**Choice** lines appear as a number of choices the Player can select.
```yaml
id: Value                 // A randomly generated UUID. We can use this unique identifier for localisation, audio, etc.
type: LineType            // The Type of the line. This will either be "default" or "choice".
animation: Value          // Set the animation of the speaker.
choices: List(            // A list of choice lines the Player can select.
  text: Value             // The actual line of dialogue.
  goto: Line              // The line we will "go to" next. 
  signals: List(Signal)   // Signals to run if this choice is selected.
  show_condition: Value   // The condition for this choice to appear, eg. "health > 2"
)                         
```
