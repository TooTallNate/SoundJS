SoundEffect.js
==============

`SoundEffect.js` is a library that provides browsers with a JavaScript sound API that first tries audio files with native HTML5 Audio and falls back to Flash when necessary.

Specifically, the `SoundEffect.js` API offers the ability to play the same sound file more than one time, even while the same sound is already playing. This is also known as multi-layering sounds. 

### Motivation: ###

`SoundEffect.js` is specifically created for the [Simple Game Framework](http://www.simplegameframework.com) HTML engine. HTML5 Audio is a nice idea, but the spec provides no multi-layering support, meaning any `<audio>` instance can only play it's `src` once at a time. There's also the case where no native HTML5 Audio is supported, or the specific file type is not supported, and that's where Flash can come in behind the scenes.

### Features: ###

 * Provides a simple API to load sounds initially, and create play instances when the sound has enough data to start playing or has loaded completely.
 * First attempts to use native HTML5 Audio to load and play back the sound.
 * Falls back to Flash when HTML5 fails or is not implemented.
 * Multi-layering loaded sounds, for multiple bullet shot sounds for example.

#### Example Usage: ####

    var shot = SoundEffect.load("shot.mp3");
    shot.on("load", function() {
        function playShot() {
            return shot.play();
        }
        playShot();
        setTimeout(playShot, 50);
        setTimeout(playShot, 234);
    });

View the full API docs.

#### Building Flash Source and Minimizing JavaScript ####

A few dependencies are required in order to build the source code into a Flash compatible SWF, and minimize ([Compile](http://code.google.com/closure/compiler/)) the JavaScript source. Make sure that you have installed:

 * [HaXe 'haxe' compiler command](http://haxe.org/)
 * [Node.js 'node' command](http://nodejs.org)

Once the dependencies are met, you can simply run

    ./compile

from the root directory. `compile` is a simple script written in JavaScript using Node.js as the interpreter. It first uses the Google Compiler web service to minimize the JavaScript code, then uses the `haxe` command line tool to compile the HaXe source into a Flash SWF file.
