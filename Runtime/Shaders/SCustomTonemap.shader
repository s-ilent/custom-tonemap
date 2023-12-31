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


class GranTurismoTonemapper
{
    static const float e_const = 2.71828f;

    float W_f(float x, float e0, float e1)
    {
        if (x <= e0)
            return 0;
        if (x >= e1)
            return 1;
        float a = (x - e0) / (e1 - e0);
        return a * a * (3 - 2 * a);
    }
    float H_f(float x, float e0, float e1)
    {
        if (x <= e0)
            return 0;
        if (x >= e1)
            return 1;
        return (x - e0) / (e1 - e0);
    }

    float Map(float x)
    {
        float P = 1;
        float a = 1;
        float m = 0.22f;
        float l = 0.4f;
        float c = 1.33f;
        float b = 0;
        float l0 = (P - m) * l / a;
        float L0 = m - m / a;
        float L1 = m + (1 - m) / a;
        float L_x = m + a * (x - m);
        float T_x = m * pow(x / m, c) + b;
        float S0 = m + l0;
        float S1 = m + a * l0;
        float C2 = a * P / (P - S1);
        float S_x = P - (P - S1) * pow(e_const, -(C2 * (x - S0) / P));
        float w0_x = 1 - W_f(x, 0, m);
        float w2_x = H_f(x, m + l0, m + l0);
        float w1_x = 1 - w0_x - w2_x;
        float f_x = T_x * w0_x + L_x * w1_x + S_x * w2_x;
        return f_x;
    }
    float3 Map3(float3 x)
    { 
        return float3(Map(x[0]), Map(x[1]), Map(x[2]));
    }
};

class ParamsLogC
{
    float cut;
    float a, b, c, d, e, f;
};

class LogColorTransform
{
    static const ParamsLogC LogC = {0.011361f, 5.555556f, 0.047996f, 0.244161f, 0.386036f, 5.301883f, 0.092819f};

    // This is only being ran on a small LUT texture so the extra cost is fine
    #define USE_PRECISE_LOGC 1

    float LinearToLogC_Precise(float x)
    {
        float o;
        if (x > LogC.cut)
            o = LogC.c * log10(LogC.a * x + LogC.b) + LogC.d;
        else
            o = LogC.e * x + LogC.f;
        return o;
    }

    float3 LinearToLogC(float3 x)
    {
    #if USE_PRECISE_LOGC
        return float3(
            LinearToLogC_Precise(x.x),
            LinearToLogC_Precise(x.y),
            LinearToLogC_Precise(x.z)
        );
    #else
        return float3(
            LogC.c * log10(LogC.a * x.x + LogC.b) + LogC.d,
            LogC.c * log10(LogC.a * x.y + LogC.b) + LogC.d,
            LogC.c * log10(LogC.a * x.z + LogC.b) + LogC.d
        );
    #endif
    }

    float LogCToLinear_Precise(float x)
    {
        float o;
        if (x > LogC.e * LogC.cut + LogC.f)
            o = (pow(10.0f, (x - LogC.d) / LogC.c) - LogC.b) / LogC.a;
        else
            o = (x - LogC.f) / LogC.e;
        return o;
    }

    float3 LogCToLinear(float3 x)
    {
    #if USE_PRECISE_LOGC
        return float3(
            LogCToLinear_Precise(x.x),
            LogCToLinear_Precise(x.y),
            LogCToLinear_Precise(x.z)
        );
    #else
        return float3(
            (pow(10.0f, (x.x- LogC.d) / LogC.c) - LogC.b) / LogC.a,
            (pow(10.0f, (x.y- LogC.d) / LogC.c) - LogC.b) / LogC.a,
            (pow(10.0f, (x.z- LogC.d) / LogC.c) - LogC.b) / LogC.a
        );
    #endif
    }
};

// https://iolite-engine.com/blog_posts/minimal_agx_implementation

class AgxTonemapper
{
    // If HLSL supported constructors this would be passed through as one, but instead it's just a variable
    // 0: Default, 1: Golden, 2: Punchy
    #define AGX_LOOK 0

    // Mean error^2: 3.6705141e-06
    float3 agxDefaultContrastApprox(float3 x) {
    float3 x2 = x * x;
    float3 x4 = x2 * x2;
    
    return + 15.5     * x4 * x2
            - 40.14    * x4 * x
            + 31.96    * x4
            - 6.868    * x2 * x
            + 0.4298   * x2
            + 0.1191   * x
            - 0.00232;
    }

    float3 agx(float3 val) {
    const float3x3 agx_mat = transpose(float3x3(
        0.842479062253094, 0.0423282422610123, 0.0423756549057051,
        0.0784335999999992,  0.878468636469772,  0.0784336,
        0.0792237451477643, 0.0791661274605434, 0.879142973793104));
        
    const float min_ev = -12.47393f;
    const float max_ev = 4.026069f;

    // Input transform (inset)
    val = mul(agx_mat, val);
    
    // Log2 space encoding
    val = clamp(log2(val), min_ev, max_ev);
    val = (val - min_ev) / (max_ev - min_ev);
    
    // Apply sigmoid function approximation
    val = agxDefaultContrastApprox(val);

    return val;
    }

    float3 agxEotf(float3 val) {
    const float3x3 agx_mat_inv = transpose(float3x3(
        1.19687900512017, -0.0528968517574562, -0.0529716355144438,
        -0.0980208811401368, 1.15190312990417, -0.0980434501171241,
        -0.0990297440797205, -0.0989611768448433, 1.15107367264116));
        
    // Inverse input transform (outset)
    val = mul(agx_mat_inv, val);
    
    // sRGB IEC 61966-2-1 2.2 Exponent Reference EOTF Display
    // NOTE: We're linearizing the output here. Comment/adjust when
    // *not* using a sRGB render target
    val = max(val, 0); // Was not in original, but needed to avoid issues after log conversion. 
    val = pow(val, 2.2);

    return val;
    }

    float3 agxLook(float3 val) {
        const float3 lw = float3(0.2126, 0.7152, 0.0722);
        float luma = dot(val, lw);
        
        float3 offset = (0.0);
        float3 slope =  (1.0);
        float3 power =  (1.0);
        float sat = 1.0;
        
        switch(_AgX_Look)
        {
        case 99: // Custom
        {
            offset = _AgX_Offset;
            slope = _AgX_Slope;
            power = _AgX_Power;
            sat = _AgX_Sat;
            break;
        }
        
        case 1: // Golden
        {
            slope = float3(1.0, 0.9, 0.5);
            power = (0.8);
            sat = 0.8;
            break;
        }
        
        case 2: // Punchy
        {
            slope = (1.0);
            power = float3(1.35, 1.35, 1.35);
            sat = 1.4;
            break;
        }
        }
        
        // ASC CDL
        val = pow(val * slope + offset, power);
        return luma + sat * (val - luma);
    }

    // Mean error^2: 1.85907662e-06
    float3 defaultContrastApprox(float3 x) {
    float3 x2 = x * x;
    float3 x4 = x2 * x2;
    float3 x6 = x4 * x2;
    
    return - 17.86     * x6 * x
            + 78.01     * x6
            - 126.7     * x4 * x
            + 92.06     * x4
            - 28.72     * x2 * x
            + 4.361     * x2
            - 0.1718    * x
            + 0.002857;
    }
};

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
                // position += 0.008;
                // position = agx.defaultContrastApprox(position);
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