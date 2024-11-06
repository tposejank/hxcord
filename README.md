# ![hxcord](https://github.com/tposejank/hxcord/blob/755ee15c3eff8907a2bc6a4a1136e53fc3ac8219/assets/hxcord_full.png?raw=true)

**hxcord** is an API and Gateway wrapper for [Discord](https://discord.com/) written in Haxe, inspired by [discord.py](https://github.com/Rapptz/discord.py). This library gives an easy-to-use and efficient way to interact with the Discord API and Gateway, allowing you to make a Discord bot using Haxe.

## Features

- **Written in Haxe**: Allows for cross-compilation and support in 3 platforms.
- **Gateway Support**: Creates connections with Discord's Gateway for you which manage real-time events like messages, reactions, etc.
- **API Wrapper**: Makes requests to Discord's REST API for you for creating and managing servers, users, channels, messages, and more.
- **Inspired by discord.py**: Takes inspiration from the simplicity and usability of discord.py, bringing the much of the same functionality to the Haxe ecosystem.
- **Event-Based**: Customizable event listeners for responding to different Discord events.

## Installation

To use hxcord, simply add it as a dependency to your Haxe project by including it in your `haxelib.json` or `build.hxml` file.

Afterwards, you can install the library:
```hxml
haxelib install hxcord
```

Then, include the library in your code:

```haxe
import discord.commands.Bot;
```

## Usage Example
Here is a simple example to get you started with a basic bot that responds to messages:

```haxe
import discord.commands.Bot;
import discord.Flags.Intents;
import discord.message.Message;

class Main {
    static function main() {
        var bot:Bot = new Bot("YOUR_BOT_TOKEN", Intents.all());

        bot.addEventListener('message', function(event) {
            if (event.message.content.trim() == '!greet') {
                event.message.reply(new Message('Hello!')); // soon
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
- HashLink (*Recommended*)
- C++ (Requires `hxcpp`)
    
    Including, but not limited to:
    - Windows (Lime)
    - Android (Lime)

## Documentation
Comprehensive documentation and additional examples can be found in the wiki.

## Contributing
We welcome contributions! Please see our CONTRIBUTING.md for guidelines on how to contribute to this project.

## License
This project is licensed under the MIT License - see the LICENSE for details.

Inspired by the discord.py project. Special thanks to all contributors!
