Shader "Silent/CustomRenderTexture/CustomTonemap"
{
    Properties
    {
        [Enum(Gran Turismo, 0, AgX, 1)] _TonemapperType("Tonemapper", Float) = 0
        [Header(Gran Turismo Settings)]
        _GTT_Dummy("Todo", Float) = 0
        [Header(AgX Settings)]
        [Enum(Base, 0, Golden, 1, Punchy, 2, Custom, 99)]_AgX_Look("AgX Look", Float) = 0
        [HDR]_AgX_Offset("Custom: Offset", Color) = (0,0,0,0)
        [HDR]_AgX_Slope("Custom: Slope", Color) = (1,1,1,1)
        [HDR]_AgX_Power("Custom: Power", Color) = (1,1,1,1)
        _AgX_Sat("Custom: Sat", Float) = 1.0
    }

     SubShader
     {
        Lighting Off
        Blend One Zero

        Pass
        {
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 3.0

            float _TonemapperType;
            float _AgX_Look;

            float3 _AgX_Offset;
            float3 _AgX_Slope;
            float3 _AgX_Power;
            float _AgX_Sat;

            #include "LogColorTransform.hlsl"
            #include "GranTurismoTonemapper.hlsl"
            #include "AgxTonemapper.hlsl"

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                float3 position = float3 (IN.localTexcoord.xyz).xyz; 
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
                }

                return float4(position, 1);
            }
        ENDCG
        }
    }
}