# Custom Tonemapper 
Alternate colour grading system for VRchat using custom render textures.

As of writing, this includes support for the AgX and Gran Turismo Sport tonemapping functions and some general colour grading settings.

# How to Use
You can use the included post-processing prefabs. 

- In the `Examples` folder, you'll find a set of prefabs corresponding to the main tonemappers included in this asset. 
- Simply drag one in and set it up to match your scene's post-process layer settings.

If you want to adjust the settings...

1. Copy or duplicate the existing CRT and Material files and place them into your project. 
2. Assign the material to the CRT's Material field.
3. Create a new post-processing profile, and add Colour Grading. Then, set the Type to External, and drag in the CRT.
4. Change the settings on the material as you like. The changes should be visible on screen!

# License
MIT license. 