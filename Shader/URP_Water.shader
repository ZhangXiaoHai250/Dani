Shader "Custom/URP_Water"
{
    Properties
    {
        [Header(Base Settings)]
        _BaseColor("Base Color", Color) = (0.1, 0.5, 0.8, 0.8)
        _WaveSpeed("Wave Speed", Range(0, 2)) = 0.5
        _WaveScale("Wave Scale", Range(0, 0.5)) = 0.1
        
        [Header(Normal Map)]
        _NormalMap("Normal Map", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Range(0, 2)) = 1
        
        [Header(Transparency)]
        _DepthFade("Depth Fade", Range(0, 5)) = 1
        
        [Header(Reflection)]
        _FresnelPower("Fresnel Power", Range(0, 5)) = 2
        _SpecularIntensity("Specular Intensity", Range(0, 5)) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent+300"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
                float3 normalOS     : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS      : SV_POSITION;
                float2 uv              : TEXCOORD0;
                float3 viewDirWS       : TEXCOORD1;
                float4 screenPos       : TEXCOORD2;
                float3 worldNormal    : TEXCOORD3;
                float3 worldPos        : TEXCOORD4;
            };

            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            
            CBUFFER_START(UnityPerMaterial)
                float4 _NormalMap_ST;
                half4 _BaseColor;
                float _WaveSpeed;
                float _WaveScale;
                float _NormalStrength;
                float _DepthFade;
                float _FresnelPower;
                float _SpecularIntensity;
            CBUFFER_END

            // 法线混合函数（移动端优化版）
            half3 BlendNormalsCustom(half3 n1, half3 n2)
            {
                return normalize(half3(n1.xy + n2.xy, n1.z * n2.z));
            }

            Varyings vert(Attributes v)
            {
                Varyings o;
                
                // 顶点位置计算
                float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
                o.positionCS = TransformWorldToHClip(positionWS);

                // 波浪动画（PC端启用，移动端建议注释）
                #if !defined(SHADER_API_MOBILE)
                float wave = sin(_Time.y * _WaveSpeed + positionWS.x * 5) * _WaveScale;
                o.positionCS.y += wave;
                #endif

                // 其他参数传递
                o.uv = TRANSFORM_TEX(v.uv, _NormalMap);
                o.viewDirWS = GetWorldSpaceViewDir(positionWS);
                o.screenPos = ComputeScreenPos(o.positionCS);
                o.worldNormal = TransformObjectToWorldNormal(v.normalOS);
                o.worldPos = positionWS;
                
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                // 法线贴图采样与混合
                float2 uv1 = i.uv + float2(_Time.y * 0.1, 0);
                float2 uv2 = i.uv + float2(0, _Time.y * 0.1);
                
                half3 normal1 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv1), _NormalStrength);
                half3 normal2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv2), _NormalStrength);
                half3 blendedNormal = BlendNormalsCustom(normal1, normal2);
                
                // 世界空间法线计算
                float3 worldNormal = normalize(i.worldNormal);
                worldNormal = normalize(worldNormal + blendedNormal);

                // 深度透明度计算
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                #if UNITY_UV_STARTS_AT_TOP
                    screenUV.y = 1.0 - screenUV.y;
                #endif
                float depth = SampleSceneDepth(screenUV);
                float surfaceDepth = depth - i.screenPos.w;
                float alpha = saturate(exp(-surfaceDepth * _DepthFade));

                // 菲涅尔反射
                float3 viewDir = normalize(i.viewDirWS);
                float fresnel = pow(saturate(1.0 - dot(viewDir, worldNormal)), _FresnelPower);
                fresnel = saturate(fresnel * _SpecularIntensity);

                // 基础颜色混合
                half4 waterColor = _BaseColor;
                waterColor.rgb += fresnel * 0.5;
                waterColor.a *= alpha;

                // 光照计算
                Light mainLight = GetMainLight(TransformWorldToShadowCoord(i.worldPos));
                float3 lightDir = mainLight.direction;
                float NdotL = saturate(dot(worldNormal, lightDir));
                
                // 最终颜色合成
                waterColor.rgb *= NdotL * mainLight.color;
                return waterColor;
            }
            ENDHLSL
        }

        // 阴影投射Pass（保证水面投射正确阴影）
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}
