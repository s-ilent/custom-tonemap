# Custom Tonemap Manual
This manual will provide a brief overview of the settings in Custom Tonemap. It's formatted for Markdown viewers, but should be readable as plain text as well. It covers the options and settings available at the time of writing.

## How Custom Tonemap Works
Custom Tonemap is a replacement for the tonemapping and colour grading system in Unity's default post-processing stack. In the post-processing stack, you can provide an external texture to use for colour grading. By using a custom render texture (CRT) for this colour grading texture, we can use our own colour grading and tonemapping systems without breaking compatibility with VRC. 

CRTs represent buffers that Unity will render a specified material/shader into. Custom Tonemap provides a set of CRTs already configured to work with the post-processing stack and a set of profiles. If you want to use them in your own profiles, set the Mode in Colour Grading to External, and place the CRT into the Lookup Texture field. 

The settings for Custom Tonemap are set through Materials specified in the CRT. If you want to tweak the colour grading settings, I recommend copying the example files into your project first. Otherwise, they will probably be overwritten when you update Custom Tonemap. 

By default, the provided CRTs are set to an Update Mode of "OnLoad". This means they will only be generated once, when the scene is loaded. If you want to alter the material properties in realtime as your scene is running, you will need to change this to Realtime, which will render the LUT every frame. 

If you want to blend between multiple sets of Custom Tonemap settings, you can also have multiple CRTs set to OnLoad, and blend  between them using the Post-Process Volume's Weight parameter.

## How to Adjust Settings
The settings for each instance of Custom Tonemap are stored in a Material. 
### Tonemapper
- Gran Turismo: A natural tonemapper developed by Polyphony Digital for their racing game series. It's meant to imitate the look of cameras used to capture races and other sports events, and is designed to look natural with a neutral middle. Unlike AgX and Khronos Neutral, it doesn't have any correction for colour shifts. 
- AgX: A tonemapper developed for film and computer graphics by Troy Sobotka and Eary Chow. It's designed as a next-generation tonemapper that avoids problems like the "Notorious Six", a quirk in current tonemappers that causes colours to be compressed into various primary colours as they get brighter before reaching pure white. As the author puts it, "It provides smooth chromatic attenuation in the image across challenging use cases including wider gamut rendering, real-camera-produced colorimetry etc." Wow! [You can read more here.](https://github.com/EaryChow/AgX)
    When AgX is selected, you'll also be able to select an "AgX Look" which provides additional colour adjustments as part part of the tonemapping process. You can also select "Custom" as an AgX Look to make your own adjustments to the tonemapping within AgX space. 
- Khronos Neutral: A colour preserving tonemapper developed by Khronos Group for the e-commerce industry. The main goal of this tonemapper is to preserve colour contrast and tone even when confronted with varying lighting conditions. As a result, it looks much more saturated than AgX by default, and avoids colour shifting entirely. However, it may not handle scenes with large variances in brightness well. [You can read more here.](https://modelviewer.dev/examples/tone-mapping)
- Tony McMapface: A tonemapper designed to be used as a base for further adjustments. "It is intentionally boring, does not increase contrast or saturation, and stays close to the input stimulus where compression isn't necessary." Like AgX, it is designed to avoid unwanted colour shifts towards primary colours. [You can read more here.](https://github.com/h3r2tic/tony-mc-mapface)
- Debug None: No tonemapper. This is only useful for debugging. Please avoid using it normally. 

## Pre-Tonemap Adjustments
To change the individual RGB components of Brightness, Contrast, and Highlight, double click to swap the mode. You can double click again to swap back to editing the overall value.

- Colour Temperature: Adjusts the colour balance of the scene. Lower is colder (blue), higher is warmer (red). 
- Colour Cast Adjustment: Adjusts the colour balance of the scene, but over green/magenta. 
- Saturation: Adjusts the vividness (saturation) of colours. Higher values will make colours more vivid, while lower values will make colours more pale. 
- Brightness: Adjusts the brightness. Higher values will make the image brighter, while lower values will make it darker.
- Contrast: Adjusts the contrast of shadows (regions that are darker than the midpoint). 
- Highlight: Adjusts the strength of highlights (regions that are brighter than the midpoint).
- Midpoint Correction: Adjusts the midpoint, which is the border between highlights and shadows. 
- Black Correction: Adjusts the brightness level of the darkest part of the image. 

## Post-Tonemap Adjustments
### Adjustment LUT
You can provide a LUT (look-up table) with colour adjustments. These LUTs are typically exported from software like Photoshop or DaVinci Resolve as a .CUBE file. When loaded into Unity, Unity will automatically generate a .asset with the .CUBE's contents converted into a LUT. With a LUT loaded, you can adjust the intensity (degree of application) with the slider. 