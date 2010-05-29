Sound.js - API
==============

`Sound.js` is designed to have a simple and familiar API. Two new global constructors are exposed: [`Sound`](#Sound) and [`SoundChannel`](#SoundChannel), which are designed to loosely match Flash's [Sound](http://www.adobe.com/livedocs/flash/9.0/ActionScriptLangRefV3/flash/media/Sound.html) and [SoundChannel](http://www.adobe.com/livedocs/flash/9.0/ActionScriptLangRefV3/flash/media/SoundChannel.html) API's.


---
<a name="Sound"></a>
### Sound ###


<a name="Sound#new"></a>
#### `new Sound(src)` ####
  - `src` | _String_ | The absolute or relative location of the audio resource to load.

Begins the loading of an audio resource. The resource begins downloading immediately after the constructor returns.


<a name="Sound#play"></a>
#### `Sound#play(options)` → [`SoundChannel`](#SoundChannel) ####
  - `options` | _Object_ | An Object containing instance options for the `SoundChannel` to use.

Begins playback of the `Sound` through a `SoundChannel` instance. Pass an optional `options` Object with any of the values:

 - `offset`: The number of milliseconds to start from. Default 0.
 - `pan`: Value from -1 (full left) to 1 (full right). The left-to-right panning of the sound. Default 0. Note that this property is only used with Flash, so if you **MUST** use `pan`, then be sure to set [`Sound.forceFlash`](#Sound.forceFlash) to `true`.
 - `volume`: The volume, ranging from 0 (silent) to 1 (full volume). Default 1.


<a name="Sound#loaded"></a>
#### `Sound#loaded` → `Boolean` ####

`false` immediately after construction, and throughout loading. `true` once the audio resource has finished loading. 


<a name="Sound#src"></a>
#### `Sound#src` → `String` ####

The resource path passed into the constructor.


... more to come ...