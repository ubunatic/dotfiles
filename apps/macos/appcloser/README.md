# No 🍏 Music
When using headphones on MacOS, Apple assumes you want to use Apple Music and opens the app. \
Apple does not allow MacOS user to change this behavior.

This is stupid! 😡 \
So let's fix it! 💪

## How `appcloser` it works
The provided app will watch for Apple Music to open, just to close it afterwards.

It is currently written using Applescript, supported by a `.plist` file to install it as system service.

## Instalation
```
make install
```
This will adjust the `.plist` XML file to point to the `appcloser` script and then install the `.plist` file to `~/Library/LaunchAgents` from where the OS will pick it up automatically.

See [Makefle](./Makefile) for more details.
