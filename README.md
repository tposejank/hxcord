# disclaimer
this is written by chatgpt. I will change this later

# discord.hx

**discord.hx** is an API and Gateway wrapper for [Discord](https://discord.com/) written in Haxe, inspired by [discord.py](https://github.com/Rapptz/discord.py), which is built using Python. The project aims to provide an easy-to-use and efficient way to interact with the Discord API and Gateway, allowing developers to build bots and automation for Discord servers using Haxe.

## Features

- **Haxe-Based**: Written in Haxe, allowing for cross-compilation and multi-platform support.
- **Gateway Support**: Establish and maintain WebSocket connections with Discord's Gateway for real-time events like messages, reactions, etc.
- **API Wrapper**: Simplifies HTTP requests to Discord's REST API for creating and managing servers, users, channels, messages, and more.
- **Inspired by discord.py**: Takes inspiration from the simplicity and usability of discord.py, bringing the same functionality to the Haxe ecosystem.
- **Event Handling**: Customizable event listeners for responding to different Discord events.
- **Rich Documentation**: Code examples and API documentation available to help you get started.

## Installation

To use discord.hx, simply add it as a dependency to your Haxe project by including it in your `haxelib.json` or `build.hxml` file:

Afterwards, you can install the library:
```hxml
haxelib install discord.hx
```

Then, include the library in your code:

```haxe
import discord.Client;
```

## Usage Example
Here is a simple example to get you started with a basic bot that responds to messages:

```haxe
import discord.Client;
import discord.types.Intents;
import discord.message.Message;

class Main {
    static function main() {
        var client = new Client("YOUR_BOT_TOKEN", Intents.all());

        client.addEventListener('MESSAGE_CREATE', function(message:Message) {
            if (message.content.trim() == '!greet') {
                message.reply(new Message('Hello!'));
            }
        });

        client.run();
    }
}
```

## Requirements
- Haxe 4

## Supported platforms (not written by gpt)
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