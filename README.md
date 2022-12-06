# lint# lint

🌱 A tiny tool for writing dialogue. 

🖍️ Write conversations made of lines. 

💬 Use the template line types: default and choice.

🌀 Or create your own line types with any fields you want.

🚀 Export your data to JSON.

## How it Works

A project is made up of **Conversations**, which are themselves made up of Lines. Each line has a Type, which determines its Fields.

**Default** lines are spoken by an NPC. 

**Choice** lines have no speaker, as these will be player choices.

Right click on the conversation tree (left) or main panel (right) to create a new conversation or line, respectively.

## Saving and Exporting

To save your lint project, navigate to File -> Save (or Save As) and choose a file location. Note that the file type ".lnt" is actually just a json file configured for a lint project. Any .lnt file can be Opened (File -> Open) to work on. 

Once you have saved or opened a file, your file location will be cached for the duration lint is open.

To Export your data, navigate to File -> Export. This will produce a json file that strips away the data lint uses to process. Note that these *cannot* be loaded back into lint, so ensure you save as a ".lnt" file to backup your project.

Once you have exported a file, your file location will be cached for the duration lint is open.
