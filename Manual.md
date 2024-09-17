# Custom Tonemap Manual
This manual will provide a brief overview of the settings in Custom Tonemap. It's formatted for Markdown viewers, but should be readable as plain text as well. It covers the options and settings available at the time of writing.

## How Custom Tonemap Works
Custom Tonemap is a replacement for the tonemapping and colour grading system in Unity's default post-processing stack. In the post-processing stack, you can provide an external texture to use for colour grading. By using a custom render texture (CRT) for this colour grading texture, we can use our own colour grading and tonemapping systems without breaking compatibility with VRC. 

CRTs represent buffers that Unity will render a specified material/shader into. Custom Tonemap provides a set of CRTs already configured to work with the post-processing stack and a set of profiles. If you want to use them in your own profiles, set the Mode in Colour Grading to External, and place the CRT into the Lookup Texture field. 

The settings for Custom Tonemap are set through Materials specified in the CRT. If you want to tweak the colour grading settings, I recommend copying the example files into your project first. Otherwise, they will probably be overwritten when you update Custom Tonemap. 

By default, the provided CRTs are set to an Update Mode of "OnLoad". This means they will only be generated once, when the scene is loaded. If you want to alter the material properties in realtime as your scene is running, you will need to change this to Realtime, which will render the LUT every frame. 

If you want to blend between multiple sets of Custom Tonemap settings, you can have multiple CRTs set to OnLoad, and blend  between them using the Post-Process Volume's Weight parameter, which can save performance. 

## Settings Overview
### Tonemapper Settings 
- Gran Turismo
    - A natural tonemapper developed by Polyphony Digital for their racing game series. 
    - It's meant to imitate the look of cameras used to capture races and other sports events, and is designed to look natural with a neutral middle. 
    - Unlike AgX and others on this list, ![it doesn't have any correction for colour shifts. ](https://github.com/user-attachments/assets/be21b79b-132f-4a2f-a37e-47a28cb5c1af)
- AgX
    - A tonemapper developed for film and computer graphics by Troy Sobotka and Eary Chow. 
    - It's designed as a next-generation tonemapper that avoids problems like the "Notorious Six", a quirk in current tonemappers that causes colours to be compressed into various primary colours as they get brighter before reaching pure white. 
    - As the author puts it, "It provides smooth chromatic attenuation in the image across challenging use cases including wider gamut rendering, real-camera-produced colorimetry etc." Wow! 
    - When AgX is selected, you'll also be able to select an "AgX Look" which provides additional colour adjustments as part part of the tonemapping process. You can also select "Custom" as an AgX Look to make your own adjustments to the tonemapping within AgX space. 
    - [You can read more here.](https://github.com/EaryChow/AgX)
- Khronos Neutral
    - A colour preserving tonemapper developed by Khronos Group for the e-commerce industry. 
    - The main goal of this tonemapper is to preserve colour contrast and tone even when confronted with varying lighting conditions. As a result, it looks much more saturated than AgX by default, and avoids colour shifting entirely. 
    - It is best suited to environments with very little variance in lighting. 
    - [You can read more here.](https://modelviewer.dev/examples/tone-mapping)
- Tony McMapface
    - A tonemapper designed by Tomasz Stachowiak to be used as a base for further adjustments. 
    - "It is intentionally boring, does not increase contrast or saturation, and stays close to the input stimulus where compression isn't necessary." Like AgX, it avoids colour shifts towards primary colours.
    - [You can read more here.](https://github.com/h3r2tic/tony-mc-mapface)
- Debug None
    - No tonemapper. This is mainly useful for debugging. Please avoid using it normally. 
    - It might be useful for advanced users who you provide their own tonemapping through a LUT.

### Pre-Tonemap Adjustments
To change the individual RGB components of Brightness, Contrast, and Highlight, double click to swap the mode. You can double click again to swap back to editing the overall value.

- Colour Temperature: <br />Adjusts the colour balance of the scene. Lower is colder (blue), higher is warmer (red). 
- Colour Cast Adjustment: <br />Adjusts the colour balance of the scene, but over green/magenta. 
- Saturation: <br />Adjusts the vividness (saturation) of colours. Higher values will make colours more vivid, while lower values will make colours more pale. 
- Brightness: <br />Adjusts the brightness. Higher values will make the image brighter, while lower values will make it darker.
- Contrast: <br />Adjusts the contrast of shadows (regions that are darker than the midpoint). 
- Highlight: <br />Adjusts the strength of highlights (regions that are brighter than the midpoint).
- Midpoint Correction: <br />Adjusts the midpoint, which is the border between highlights and shadows. 
- Black Correction: <br />Adjusts the brightness level of the darkest part of the image. 

### Post-Tonemap Adjustment LUT
You can provide a LUT (look-up table) with colour adjustments. These LUTs are typically exported from software like Photoshop or DaVinci Resolve as a .CUBE file. When loaded into Unity, Unity will automatically generate a .asset with the .CUBE's contents converted into a LUT. With a LUT loaded, you can adjust the intensity (degree of application) with the slider. 

## Setting up the CRT
Here is an overview of the settings used in the custom render texture for Custom Tonemap. 
- Dimension must be **3D** in order for the CRT to be useable as an external tonemapping source in Unity.
- Size is 57x57x57 by default, but this is actually higher than what Unity uses by default. It should be at least 33x33x33. 
- Color Format is set to `R16G16B16A16_SFLOAT`. Floating point is used for extra precision, which is important to get interpolation between colours correct and reduces the amount of error caused by quantization.
- Wrap Mode must be Clamp. Otherwise, the edges of the texture will bleed into each other and you'll get weird artifacts.
- Filter Mode must be Trilinear. Otherwise, you'll see banding between different colours.
- The Material is your material with the Custom Tonemap shader on it, and Shader Pass should be Tonemap.
- Initialization Mode is set to OnLoad. If it isn't set to OnLoad, it doesn't seem to be initialized properly. 
- Update mode is set to OnLoad. As mentioned above, this means they will only be generated when loaded. If you want to alter the material properties in realtime as the scene is running, change it to Realtime, which will render the CRT every frame. 
