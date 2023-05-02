# lint

🌱 A tiny tool for writing dialogue. 

🖍️ Write conversations made of lines. 

💬 Use the template line types: default and choice.

🚀 Export your data to JSON.

## How it Works

A project is made up of **Conversations**, which are themselves made up of Lines. Each line has a Type, which determines its Fields.

**Default** lines are spoken by a character. 

**Choice** lines have multiple choices for player selection.

Right click on the conversation tree (left) or main panel (right) to create a new conversation or line, respectively. 

## Saving and Exporting

To save your lint project, navigate to File -> Save (or Save As) and choose a file location. Note that the file type ".lnt" is actually just a json file configured for a lint project. Any .lnt file can be Opened (File -> Open) to work on. 

To Export your data, navigate to File -> Export (or Export As). This will produce a json file that strips away the data lint uses to process. Note that these *cannot* be loaded back into lint, so ensure you save as a ".lnt" file to backup your project.
