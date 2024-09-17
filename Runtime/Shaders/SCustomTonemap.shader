Shader "Silent/CustomRenderTexture/CustomTonemap"
{
    Properties
    {
        [Enum(Gran Turismo, 0, AgX, 1, Khronos Neutral, 2, Tony McMapface, 3, Debug None, 99)] _TonemapperType("Tonemapper", Float) = 0
        [Space]
        [Header(Post Tonemap Adjustment LUT)]
        [NoScaleOffset]_CustomLUT1("LUT 1", 3D) = "_Lut3D" {}
        _CustomLUT1Intensity("LUT 1 Intensity", Range(0, 1)) = 0.0
        [NoScaleOffset]_CustomLUT2("LUT 2", 3D) = "_Lut3D" {}
        _CustomLUT2Intensity("LUT 2 Intensity", Range(0, 1)) = 0.0
        [Space]
        [Header(AgX Settings)]
        [Enum(Base, 0, Golden, 1, Punchy, 2, Custom, 99)]_AgX_Look("AgX Look", Float) = 0
        [HDR]_AgX_Offset("Custom: Offset", Color) = (0,0,0,0)
        [HDR]_AgX_Slope("Custom: Slope", Color) = (1,1,1,1)
        [HDR]_AgX_Power("Custom: Power", Color) = (1,1,1,1)
        _AgX_Sat("Custom: Sat", Float) = 1.0
        [NonModifiableTextureData][HideInInspector]_UnityLogToLinearR1("Unity Log to Linear Transform LUT", 3D) = "_Lut3D"
        [NonModifiableTextureData][HideInInspector]_TonyMcMapfaceLUT("Tony McMapface Transform LUT", 3D) = "_Lut3D"
    }

     SubShader
     {
        Lighting Off
        Blend One Zero

        Pass
        {
            Name "Tonemap"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            float _TonemapperType;
            float _AgX_Look;

            float3 _AgX_Offset;
            float3 _AgX_Slope;
            float3 _AgX_Power;
            float _AgX_Sat;

            sampler3D _UnityLogToLinearR1;

            sampler3D _CustomLUT1;
            float _CustomLUT1Intensity;
            sampler3D _CustomLUT2;
            float _CustomLUT2Intensity;

            #include "LogColorTransform.hlsl" 
            #include "GranTurismoTonemapper.hlsl"
            #include "AgxTonemapper.hlsl"
            #include "KhronosNeutralTonemapper.hlsl" 
            #include "TonyMcMapfaceTonemapper.hlsl" 

            /* 
            On the PP side, external tonemapping is applied like this

            float3 colorLutSpace = saturate(LinearToLogC(colorLinear));
            float3 colorLut = ApplyLut3D(TEXTURE3D_ARGS(_LogLut3D, sampler_LogLut3D), colorLutSpace, _LogLut3D_Params.xy);
            colorLinear = lerp(colorLinear, colorLut, _LogLut3D_Params.z);

            where
            float4 _LogLut3D_Params;    // x: 1 / lut_size, y: lut_size - 1, z: contribution, w: unused
            
            half3 ApplyLut3D(TEXTURE3D_ARGS(tex, samplerTex), float3 uvw, float2 scaleOffset)
            {
                uvw.xyz = uvw.xyz * scaleOffset.yyy * scaleOffset.xxx + scaleOffset.xxx * 0.5;
                return SAMPLE_TEXTURE3D(tex, samplerTex, uvw).rgb;
            }
            */

            float3 RemapUV(float3 uv, float width, float height, float depth) {
                float3 dim = float3(width, height, depth);
                uv = floor(uv * dim) / (dim - 1.0);

                // Fix 3D slice coordinates directly
                uv.z = _CustomRenderTexture3DSlice  / (_CustomRenderTextureDepth - 1.0);

                return uv;
            }

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                float3 position = float3 (IN.localTexcoord.xyz).xyz; 
                
                float width = _CustomRenderTextureWidth;
                float height = _CustomRenderTextureHeight;
                float depth = _CustomRenderTextureDepth;
                position = RemapUV(position, width, height, depth);

                // For debugging; shouldn't be necessary
                // position = tex3D(_UnityLogToLinearR1, position);
                
                LogColorTransform lct;
                position = lct.LogCToLinear(position); 

                switch (_TonemapperType)
                {
                case 0:
                {
                    GranTurismoTonemapper gtt;
                    position = gtt.Map3(position);
                    break;
                }
                case 1:
                {
                    AgxTonemapper agx;
                    position = agx.agx(position);
                    position = agx.agxLook(position);
                    position = agx.agxEotf(position);
                    break;
                }
                case 2:
                {
                    KhronosNeutralTonemapper knt;
                    position = knt.Map(position);
                    break;
                }
                case 3:
                {
                    TonyMcMapfaceTonemapper tony;
                    position = tony.map(position);
                    break;
                }
                }

                // Todo...
                // - Add curve-based grading like GT presentation
                //   Brightness, contrast (with curve), highlight, midpoint correction...
                //   https://www.gran-turismo.com/us/gtsport/manual/#!/scapes/content04

                if (_CustomLUT1Intensity > 0)
                {
                    position = lerp(position, tex3D(_CustomLUT1, position), _CustomLUT1Intensity);
                }
                if (_CustomLUT2Intensity > 0)
                {
                    position = lerp(position, tex3D(_CustomLUT2, position), _CustomLUT2Intensity);
                }

                return float4(max(position, 0), 1);
            }
        ENDCG
        }
    }
}