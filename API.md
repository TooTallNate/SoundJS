SoundJS - API
==============

`SoundJS` is designed to have a simple and familiar API. Two new global
constructors are exposed: [`Sound`](#Sound) and
[`SoundChannel`](#SoundChannel), which are designed to loosely resemble Flash's
[Sound](http://www.adobe.com/livedocs/flash/9.0/ActionScriptLangRefV3/flash/media/Sound.html)
and [SoundChannel](http://www.adobe.com/livedocs/flash/9.0/ActionScriptLangRefV3/flash/media/SoundChannel.html)
API's.


---
<a name="Sound"></a>
### Sound ###

The `Sound` class is what you will be mostly working with. Playing sounds with
`SoundJS` starts by loading an audio resource with the `new Sound`
constructor.

<a name="Sound#new"></a>
#### new Sound(src) ####
  - `src` | _String_ | The absolute or relative location of the audio resource
  to load.

Begins the loading of an audio resource. The resource begins downloading
immediately after the constructor returns.


<a name="Sound#play"></a>
#### Sound#play(options) → [`SoundChannel`](#SoundChannel) ####
  - `options` | _Object_ | An Object containing instance options for the
  `SoundChannel` to use.

Begins playback of the `Sound` through a `SoundChannel` instance. Pass an
optional `options` Object with any of the values:

 - `offset`: The number of milliseconds to start from. Default 0.
 - `pan`: Value from -1 (full left) to 1 (full right). The left-to-right
 panning of the sound. Default 0. Note that this property is only used with
 Flash, so if you **MUST** use `pan`, then be sure to set
 [`Sound.forceFlash`](#Sound.forceFlash) to `true`.
 - `volume`: The volume, ranging from 0 (silent) to 1 (full volume). Default 1.


<a name="Sound#getLength"></a>
#### Sound#getLength() → `Number` ####

Gets and returns the total duration of the audio resource, in milliseconds.


<a name="Sound#loaded"></a>
#### Sound#loaded → `Boolean` ####

`false` immediately after construction, and throughout loading. `true` once
the audio resource has finished loading. 


<a name="Sound#src"></a>
#### Sound#src → `String` ####

The resource path passed into the constructor.


<a name="Sound.forceFlash"></a>
#### Sound.forceFlash → `Boolean` ####

This value is checked every time `new Sound` is called. If it is set to
`true`, then playback will be through Flash ONLY. `false` by default.


<a name="Sound.version"></a>
#### Sound.version → `String` ####

The version String of `SoundJS`. Can be useful for debugging or verification
purposes.


---
<a name="SoundChannel"></a>
### SoundChannel ###

`SoundChannel` instances are created by calling [`Sound#play`](#Sound#play),
not by using the `new` operator. Once the sound data from a `SoundChannel` has
been played, or [`SoundChannel#stop`](#SoundChannel#stop) has been called, the
instance is useless (not re-usable).


<a name="SoundChannel#stop"></a>
#### SoundChannel#stop() → `undefined` ####

Stops the `SoundChannel` from playing it's data. The instance is essentially
useless after calling this, since `SoundChannel`s are not re-usable.


<a name="SoundChannel#getPosition"></a>
#### SoundChannel#getPosition() → `Number` ####

Gets and returns the current point that is being played in the sound file.


<a name="SoundChannel#getPan"></a>
#### SoundChannel#getPan() → `Number` ####

Gets and returns the current left-to-right pan of the sound playback.


<a name="SoundChannel#getVolume"></a>
#### SoundChannel#getVolume() → `Number` ####

Gets and returns the volume (from 0 to 1) of the sound playback.


<a name="SoundChannel#setPan"></a>
#### SoundChannel#setPan(pan) → `undefined` ####
  - `pan` | _Number_ | The value to set as the pan.

Sets the left-to-right pan of the sound playback, from -1 (full left) to 1
(full right).


<a name="SoundChannel#setVolume"></a>
#### SoundChannel#setVolume(vol) → `undefined` ####
  - `vol` | _Number_ | The value to set as the volume.

Sets the playback volume of the sound file (from 0 to 1).
