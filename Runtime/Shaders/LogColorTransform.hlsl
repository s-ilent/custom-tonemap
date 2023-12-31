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