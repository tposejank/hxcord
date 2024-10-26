# ![discord.hx](discord_hx.png)

**discord.hx** is an API and Gateway wrapper for [Discord](https://discord.com/) written in Haxe, inspired by [discord.py](https://github.com/Rapptz/discord.py), which is built using Python. The project aims to provide an easy-to-use and efficient way to interact with the Discord API and Gateway, allowing you to make a bot for Discord servers using Haxe.

## Features

- **Written in Haxe**: Allows for cross-compilation and support in 3 platforms.
- **Gateway Support**: Creates connections with Discord's Gateway for you which manage real-time events like messages, reactions, etc.
- **API Wrapper**: Makes requests to Discord's REST API for you for creating and managing servers, users, channels, messages, and more.
- **Inspired by discord.py**: Takes inspiration from the simplicity and usability of discord.py, bringing the same functionality to the Haxe ecosystem.
- **Event-Based**: Customizable event listeners for responding to different Discord events.

## Installation

To use discord.hx, simply add it as a dependency to your Haxe project by including it in your `haxelib.json` or `build.hxml` file.

Afterwards, you can install the library:
```hxml
haxelib install discord.hx
```

Then, include the library in your code:

```haxe
import discord.commands.Bot;
```

## Usage Example
Here is a simple example to get you started with a basic bot that responds to messages:

```haxe
import discord.commands.Bot;
import discord.types.Intents;
import discord.message.Message;

class Main {
    static function main() {
        var bot:Bot = new Bot("YOUR_BOT_TOKEN", Intents.all());

        bot.addEventListener('MESSAGE_CREATE', function(message:Message) { // NOT YET SUPPORTED
            if (message.content.trim() == '!greet') {
                message.reply(new Message('Hello!'));
            }
        });

        bot.run();
    }
}
```

## Requirements
- Haxe 4.3+

## Supported platforms
- Neko
- HashLink
- C++ (`haxelib install hxcpp`)

## Documentation
Comprehensive documentation and additional examples can be found in the wiki.

## Contributing
We welcome contributions! Please see our CONTRIBUTING.md for guidelines on how to contribute to this project.

## License
This project is licensed under the GNU v3.0 License - see the LICENSE file for details.

Inspired by the discord.py project. Special thanks to all contributors!