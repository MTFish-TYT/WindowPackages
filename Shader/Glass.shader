Shader "Glass/Glass"
{
    Properties
    {
        [Header(Glass)]
        _CubeMapOutSide     ("玻璃外侧CubeMap", Cube) = "_SkyBox"{}
        _CubeMapInside      ("玻璃内侧CubeMap", Cube) = "_SkyBox"{}
        _InsideDepth        ("内侧深度", Float) = 5
        _Refraction         ("折射率,x: 空气（默认1）, y: 玻璃（默认1.5）", Vector) = (1, 1.5, 0.0, 0.0)
        _GlassColor         ("窗户颜色", Color) = (1,1,1,1)
        _InsideMipLevel     ("窗户磨砂程度", Range(0, 11)) = 0
        [Header(Gauss)]
        [Toggle(_USE_GAUSS)] _Use_Gauss             ("启用窗纱", Float) = 0
        _GaussTex           ("窗纱", 2D) = "white"{}
        _GaussScale         ("窗纱密度", Float) = 1
        _GaussColor         ("窗纱颜色", Color) = (0,0,0,0)
        [Header(Curtain)]
        [Toggle(_USE_CURTAIN)] _UseCurtain          ("启用窗帘", Float) = 0
        [Toggle(_USE_TEXCURTAIN)] _UseTexCurtain    ("启用贴图窗帘", Float) = 0   
        _GussTexture        ("模拟窗帘的Perlin噪声", 2D) = "white"{}
        _GussScale          ("Perlin噪声 x:scale, y:offset, z: Strengh", Vector) = (0.4, 0, 1, 0)
        _GussRandom         ("y方向随机采样", Range(0, 1)) = 0
        _GussColor          ("窗帘颜色", Color) = (1 ,1 ,1 ,1)
        _GussMaskTex        ("窗帘Mask", 2D) = "white"{}
        _GussMaskScale      ("Perlin Mask x: scale, y: offset", Vector) = (1, 0, 0, 0)
        _GussMipLevel       ("模糊程度", Range(0, 11)) = 0
        _CurtainTex         ("贴图窗帘", 2D) = "white"{}
        [Header(Dirt)]
        [Toggle(_USE_DIRT)] _Use_Dirt               ("启用脏污", Float) = 0
        _Dirt1Scale         ("脏污1 xy:scale zw:offset", Vector) = (1,1,0,0)
        _Dirt2Scale         ("脏污2 xy:scale zw:offset", Vector) = (1,1,0,0)
        _Dirt1MaskScale     ("脏污1Mask xy:scale zw:offset", Vector) = (1,1,0,0)
        _Dirt2MaskScale     ("脏污2Mask xy:scale zw:offset", Vector) = (1,1,0,0)
        _Dirt1Color         ("脏污1颜色", Color) = (1,1,1,1)
        _Dirt2Color         ("脏污2颜色", Color) = (1,1,1,1)
        _DirtStrength       ("脏污强度", Range(0.01, 3)) = 1
        [Header(Dust)]
        [Toggle(_USE_DUST)] _Use_Dust               ("启用边缘灰尘", Float) = 0
        [Toggle(_USE_DUSTEX)] _Use_DustTex               ("仅使用单张积灰遮罩贴图", Float) = 0
        _CloudMaskTex       ("云噪声与基础遮罩", 2D) = "white"{}
        _Cloud1Scale        ("云1 xy:scale zw:offset", Vector) = (1,1,0,0)
        _Cloud2Scale        ("云2 xy:scale zw:offset", Vector) = (1,1,0,0)
        _Cloud3Scale        ("云3 xy:scale zw:offset", Vector) = (1,1,0,0)
        _DustColor          ("积灰颜色", Color) = (1,1,1,1)
        _DustMask           ("积灰遮罩", 2D) = "white"{}
        _DustStrength       ("积灰强度", Range(0.01, 3)) = 1
        [Header(Frame)]
        [Toggle(_USE_FRAME)] _Use_Frame             ("启用窗框", Float) = 0
        _FrameTex           ("窗框贴图", 2D) = "white"{}
        [Header(RainDrop)]
        [Toggle(_USE_RAINDROP)] _Use_RainDrop       ("启用雨滴", Float) = 0
        [Toggle(_USE_OPACITY)]  _Use_Opacity        ("启用透过磨砂", Float) = 0
        _RainDropSize       ("雨滴密度", Float) = 10
        _RainDistortion    ("雨滴扰动强度", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Geometry"
            "RenderType"="Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        Cull Off
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #pragma shader_feature_local _USE_CURTAIN
            #pragma shader_feature_local _USE_DIRT
            #pragma shader_feature_local _USE_TEXCURTAIN
            #pragma shader_feature_local _USE_FRAME
            #pragma shader_feature_local _USE_DUST
            #pragma shader_feature_local _USE_DUSTEX
            #pragma shader_feature_local _USE_RAINDROP
            #pragma shader_feature_local _USE_OPACITY
            #pragma shader_feature_local _USE_GAUSS

            TEXTURECUBE(_CubeMapOutSide);
            SAMPLER(sampler_CubeMapOutSide);
            TEXTURECUBE(_CubeMapInside);
            SAMPLER(sampler_CubeMapInside);
            TEXTURE2D(_GussTexture);
            SAMPLER(sampler_GussTexture);
            TEXTURE2D(_GussMaskTex);
            SAMPLER(sampler_GussMaskTex);
            TEXTURE2D(_CurtainTex);
            SAMPLER(sampler_CurtainTex);
            TEXTURE2D(_FrameTex);
            SAMPLER(sampler_FrameTex);
            TEXTURE2D(_CloudMaskTex);
            SAMPLER(sampler_CloudMaskTex);
            TEXTURE2D(_DustMask);
            SAMPLER(sampler_DustMask);
            TEXTURE2D(_GaussTex);
            SAMPLER(sampler_GaussTex);
            samplerCUBE _Reflection_CubeMap;

            float _InsideDepth;
            float2 _Refraction;
            float4 _GlassColor;
            int _InsideMipLevel;
            float3 _GussScale;
            float4 _GussColor;
            float _GussRandom;
            float2 _GussMaskScale;
            int _GussMipLevel;
            float4 _Dirt1Scale;
            float4 _Dirt2Scale;
            float4 _Dirt1MaskScale;
            float4 _Dirt2MaskScale;
            float4 _Dirt1Color;
            float4 _Dirt2Color;
            float _DirtStrength;
            float4 _Cloud1Scale;
            float4 _Cloud2Scale;
            float4 _Cloud3Scale;
            float4 _DustColor;
            float _DustStrength;
            float _RainDropSize;
            float _RainDistortion;
            float _GaussScale;
            float4 _GaussColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 posWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.posWS = TransformObjectToWorld(v.vertex);
                o.normalWS = TransformObjectToWorldNormal(v.normal);
                o.tangentWS = TransformObjectToWorldDir(v.tangent);
                float vertexTangentSign = v.tangent.w * unity_WorldTransformParams.w;
                o.bitangentWS = normalize(cross(o.normalWS, o.tangentWS)) * vertexTangentSign;
                o.uv = v.uv;
                return o;
            }

            float3 InteriorCubeMap(float3 worldPosition,  float3 worldTangent,float3 worldNormal,float3 worldBitangent,float2 uv)
			{
				float3 tanToWorld0 = float3(worldTangent.x, worldBitangent.x, worldNormal.x);
				float3 tanToWorld1 = float3(worldTangent.y, worldBitangent.y, worldNormal.y);
				float3 tanToWorld2 = float3(worldTangent.z, worldBitangent.z, worldNormal.z);
				float3 worldViewDir = GetWorldSpaceViewDir(worldPosition);
				worldViewDir = normalize(worldViewDir);
				float3 tanViewDir = tanToWorld0 * worldViewDir.x + tanToWorld1 * worldViewDir.y + tanToWorld2 * worldViewDir.z;
				tanViewDir = SafeNormalize(tanViewDir);
				float3 step1Val = (float3(-1, -1, 1) * tanViewDir);
				float3 step2Val = (1.0 / step1Val);
				float3 step3Val = (float3(((frac(((uv * float2(1, -1)))) * float2(2, -2)) - float2(1, -1)), -1.0 * _InsideDepth));
				float3 step4Val = (abs(step2Val) - (step2Val * step3Val));
				float3 step5Val = ((min(min(step4Val.x, step4Val.y), step4Val.z) * step1Val) + step3Val);
				return (float3(step5Val.z, step5Val.y, step5Val.x));
			}

            float Schlick(float n1, float n2)
            {
                float c = n1 - n2;
                float c2 = c * c;
                float m = n1 + n2;
                float m2 = m * m;
                return c2 / m2;
            }

            float ReflectI(float r, float costheta)
            {
                float oneMinusCostheta = 1 - costheta;
                float oMC5 = pow(oneMinusCostheta, 5);
                return r + (1 - r) * oMC5;
            }

            float ExtremeRemap(float x, float n)
            {
                x = x * 2;
                x = pow(x * 2, n);
                x = x / pow(2, n);
                return x;
            }

            float AddSub(float front, float back)
            {
                float r = 0;
                if (front > 0.5) r = min(1, front + back);
                else r = max(0, back - front);
                return r;
            }

            float N21(float2 p)
            {
                p = frac(p * float2(123.34, 345.45));
                p += dot(p , p +34.345);
                return frac(p.x * p.y);
            }

            float RainDrop(float2 inputuv)
            {
                float t = fmod(_Time.y, 7200);
                float col = 0;

                float2 aspect = float2(2,1); // 单个网格比例
                float2 uv = inputuv * _RainDropSize * aspect;
                uv.y += t * 0.25; // 网格运动抵消雨滴向上运动
                float2 gv = frac(uv) - 0.5;

                float2 id = floor(uv);
                float n = N21(id);
                t += n * 6.2831;

                float w = inputuv.y * 10;
                float x = (n - 0.5) * 0.8;
                x += (0.4 - abs(x)) * sin(3 * w) * pow(sin(w), 6) * 0.45;
                float y = -sin(t + sin(t + sin(t) * 0.5)) * 0.45;
                y -= (gv.x - x) * (gv.x - x);

                float2 dropPos = (gv - float2(x, y)) / aspect;
                float drop = smoothstep(0.05, 0.03, length(dropPos));

                float2 trailPos = (gv - float2(x, t * 0.25)) / aspect; // 生成单个
                trailPos.y = (frac(trailPos.y * 8) - 0.5) / 8; // 生成多个
                float trail = smoothstep(0.03, 0.01, length(trailPos)); // 绘制
                float fogTrail = smoothstep(-0.05, 0.05, dropPos.y); // 雨滴下方的不可见
                fogTrail *= smoothstep(0.5, y, gv.y); // 逐渐消失
                trail *= fogTrail;
                fogTrail *= smoothstep(0.05, 0.03, abs(dropPos.x));

                col += fogTrail * 0.5;
                col += trail;
                col += drop;

                // if(gv.x > 0.48 || gv.y > 0.49) col = float4(1,1,1,1);
                return col;
            }
            
            half4 frag (v2f i) : SV_Target
            {
                float3 viewWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS);
                float3 reflectDir = reflect(-viewWS, i.normalWS);
                float3 normalWS = normalize(i.normalWS);

                // 扰动雨滴
                float finalRain = 0;
                float rainMask = 0;
                #if _USE_RAINDROP
                    float rainDrop = RainDrop(i.uv);
                    rainMask = rainDrop;
                    rainDrop =(rainDrop - 0.5) * _RainDistortion;
                    finalRain = lerp(0, rainDrop, rainMask);
                #endif
                
                
                // 采样Outside
                float3 cubeMapOutside = SAMPLE_TEXTURECUBE(_CubeMapOutSide, sampler_CubeMapOutSide,reflectDir);

                // 采样Inside
                float3 insideCubeUV = InteriorCubeMap(i.posWS  + finalRain, i.tangentWS, i.normalWS, i.bitangentWS, i.uv);
                float3 cubeMapInside = SAMPLE_TEXTURECUBE_LOD(_CubeMapInside, sampler_CubeMapInside, insideCubeUV, _InsideMipLevel);
                #if _USE_RAINDROP && _USE_OPACITY
                    float3 rainInside = SAMPLE_TEXTURECUBE_LOD(_CubeMapInside, sampler_CubeMapInside, insideCubeUV, 0);
                    cubeMapInside = lerp(cubeMapInside, rainInside,pow(rainMask, 0.1));
                #endif
                
                // Perlin采样
                float perlin = 0;
                float perlinMask = 0;
                float3 insideAfterCurtain = 0;
                #if _USE_CURTAIN
                    #if _USE_TEXCURTAIN
                        float4 curtainTex = SAMPLE_TEXTURE2D(_CurtainTex, sampler_CurtainTex, i.uv + finalRain * 0.1);
                        perlin = curtainTex.r;
                        perlinMask = curtainTex.a;
                    #else
                        perlin = SAMPLE_TEXTURE2D(_GussTexture, sampler_GussTexture, (float2(i.uv.x, _GussRandom) + _GussScale.y) * _GussScale.x + finalRain * 0.1).g;
                        perlinMask = SAMPLE_TEXTURE2D(_GussMaskTex, sampler_GussMaskTex, (i.uv + _GussMaskScale.y) * _GussMaskScale.x + finalRain * 0.1).r;
                    #endif
                    perlin = pow(perlin, _GussScale.z);
                    insideAfterCurtain = SAMPLE_TEXTURECUBE_LOD(_CubeMapInside, sampler_CubeMapInside, insideCubeUV, _GussMipLevel + _InsideMipLevel);
                #else
                    insideAfterCurtain = cubeMapInside;
                #endif
                float perlinWithMask = lerp(1, perlin, perlinMask);
                float3 insideWithGuss = lerp(cubeMapInside, insideAfterCurtain, perlinMask);
                float3 insideWithCurtain = lerp(_GussColor, insideWithGuss, perlinWithMask);

                // 采样窗纱
                float gauseMask = 1; 
                #if _USE_GAUSS
                    gauseMask = SAMPLE_TEXTURE2D_LOD(_GaussTex, sampler_GaussTex, i.uv * _GaussScale + finalRain * 0.1, _InsideMipLevel * 0.5);
                #endif
                float3 windowWithGauss = lerp(_GaussColor, insideWithCurtain, gauseMask);
                
                // 菲涅尔计算
                float n1 = _Refraction.x;
                float n2 = _Refraction.y;
                float R0 = Schlick(n1, n2);
                float costheta = dot(viewWS, normalWS);
                float fresnel = ReflectI(R0, costheta);

                // 窗脏污效果
                float dirt1 = 0;
                float dirt2 = 0;
                #if _USE_DIRT
                    float m1 = SAMPLE_TEXTURE2D(_GussTexture, sampler_GussTexture, (i.uv + _Dirt1Scale.zw) * _Dirt1Scale.xy + finalRain * 0.1).r;
                    float m2 = SAMPLE_TEXTURE2D(_GussTexture, sampler_GussTexture, (i.uv + _Dirt2Scale.zw) * _Dirt2Scale.xy + finalRain * 0.1).g;
                    float m1Mask = SAMPLE_TEXTURE2D(_GussTexture, sampler_GussTexture, (i.uv + _Dirt1MaskScale.zw) * _Dirt1MaskScale.xy + finalRain * 0.1).b;
                    float m2Mask = SAMPLE_TEXTURE2D(_GussTexture, sampler_GussTexture, (i.uv + _Dirt2MaskScale.zw) * _Dirt2MaskScale.xy + finalRain * 0.1).b;
                    dirt1 = ExtremeRemap(m1 * m1Mask, 3);
                    dirt2 = ExtremeRemap(m2 * m2Mask, 3);
                    dirt1 = pow(dirt1, _DirtStrength);
                    dirt2 = pow(dirt2, _DirtStrength);
                #endif

                // 加入边缘积灰
                float dustMask = 0;
                #if _USE_DUST
                    #if _USE_DUSTEX
                        dustMask = SAMPLE_TEXTURE2D(_DustMask, sampler_DustMask, i.uv).r;
                    #else
                        float cloud1 = SAMPLE_TEXTURE2D(_CloudMaskTex, sampler_CloudMaskTex, (i.uv + _Cloud1Scale.zw) * _Cloud1Scale.xy + finalRain * 0.1).r;
                        float cloud2 = SAMPLE_TEXTURE2D(_CloudMaskTex, sampler_CloudMaskTex, (i.uv + _Cloud2Scale.zw) * _Cloud2Scale.xy + finalRain * 0.1).g;
                        float cloud3 = SAMPLE_TEXTURE2D(_CloudMaskTex, sampler_CloudMaskTex, (i.uv + _Cloud3Scale.zw) * _Cloud3Scale.xy + finalRain * 0.1).b;
                        float baseMask = SAMPLE_TEXTURE2D(_CloudMaskTex, sampler_CloudMaskTex, i.uv + finalRain * 0.1).a;
                        float blend1 = max(cloud1, cloud2);
                        float blend2 = max(blend1, cloud3);
                        dustMask = max(0, blend2 - baseMask);
                        dustMask = pow(dustMask, 2.2);
                    #endif
                #endif
                
                // 加入窗框
                float4 frameTex = float4(0,0,0,0);
                #if _USE_FRAME
                    frameTex = SAMPLE_TEXTURE2D(_FrameTex, sampler_FrameTex, i.uv);
                #endif
                
                float3 glassFresnelColor = lerp(windowWithGauss, cubeMapOutside, fresnel);

                float3 glassWithDirt = lerp(lerp(glassFresnelColor, _Dirt1Color.xyz, dirt1), _Dirt2Color, dirt2);

                float3 glassWithDust = lerp(glassWithDirt, _DustColor.xyz, pow(dustMask, _DustStrength));

                float3 glassWithFrame = lerp(glassWithDust, frameTex.xyz, frameTex.a);
                
                float3 finalRGB = glassWithFrame * _GlassColor;
                return half4(finalRGB, 1);
            }
            ENDHLSL
        }
    }
}
