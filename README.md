# Custom Tonemap
Alternate colour grading system for VRchat/Unity using custom render textures.

As of writing, this includes support for various tonemapping functions and general colour grading settings.

### Supported Tonemappers

- [Gran Turismo](http://cdn2.gran-turismo.com/data/www/pdi_publications/PracticalHDRandWCGinGTS_20181222.pdf) 
- [AgX](https://github.com/EaryChow/AgX)
- [Khronos Neutral](https://www.khronos.org/news/press/khronos-pbr-neutral-tone-mapper-released-for-true-to-life-color-rendering-of-3d-products)
- [Tony McMapface](https://github.com/h3r2tic/tony-mc-mapface)
- [Gran Turismo 7](https://blog.selfshadow.com/publications/s2025-shading-course/#course_content)

### Colour Grading Settings

- Color temperature and colour cast shifts
- Complete global saturation
- Per-channel adjustments for brightness, contrast, and highlights
- Midpoint correction
- Black level correction

Plus, two slots for custom LUTs to apply pre-authored film/scene looks. 

# How to Use
You can use the included post-processing prefabs. 

- In the `Examples` folder, you'll find a set of prefabs corresponding to the main tonemappers included in this asset. 
- Simply drag one in and set it up to match your scene's post-process layer settings.

For more details, see the [Manual](Manual.md). 

# License
MIT license. 