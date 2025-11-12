MacOS Keylayouts
================

> [!NOTE]
> When MacOS asks you to identify your keyboard you should press the key next to the left of the left Shift key.
> This is usually the `<` key on a German PC keyboard. However MacOS may think you pressed the `^` key instead.
> In this case repeat the keyboard identification and press `^` instead. This will fix most issues.
>
> If this does not help, try to use my layouts to fix your issues.

I am using a German PC keyboard on a Mac and Apple's support for this is very bad. Here is a keyboard layout to fix this!

Meet the **German - PC** MacOS Keylayout.

<img src="German-PC.iconset/Assets/menubar-example.png" alt="German - PC keylayout icon" width="192"/>

Installation
------------

    make install

Or copy the `.keylayout` and the `.icns` files manually.

    cp *.keylayout *.icns "$HOME/Library/Keyboard Layouts"

Post Install
------------
To use the new keyboard layouts, you may need to log out and log back in. For changed KeyBindings only just restart you apps.
You can select the keyboard layout in System Preferences > Keyboard > Input Sources. Or run `make settings` to jump there.

Development
-----------
See [Makefile](Makefile) for details how to develop layouts.

Learnings
---------
When MacOS asks you to identify your keyboard you should press the key next to the left of the left Shift key.
This is usually the `<` key on a German PC keyboard. However MacOS may think you pressed the `^` key instead.
In this case repeat the keyboard identification and press `^` instead. This will fix most issues.
