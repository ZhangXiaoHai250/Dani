Shader "Custom/URP_SmokeShader"
{
   Properties
    {
        _MainTex ("Smoke Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "gray" {}
        _Color ("Color", Color) = (0.5, 0.5, 0.5, 1)
        _Density ("Density", Range(0, 2)) = 1
        _Speed ("Speed", Range(0, 2)) = 0.5
        _Turbulence ("Turbulence", Range(0, 1)) = 0.3
        _Dissolve ("Dissolve", Range(0, 1)) = 0.5
        _EdgeFade ("Edge Fade", Range(0, 1)) = 0.2
        _ScrollDirection ("Scroll Direction", Vector) = (0, 1, 0, 0)
    }

    SubShader
    {
        Tags 
        { 
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _Color;
                float _Density;
                float _Speed;
                float _Turbulence;
                float _Dissolve;
                float _EdgeFade;
                float4 _ScrollDirection;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                // 添加简单的顶点动画模拟烟雾飘动
                float noise = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, IN.uv * 2.0 + _Time.y * 0.1, 0).r;
                float3 offset = float3(
                    (noise - 0.5) * 0.1 * _Turbulence,
                    noise * 0.2 * _Turbulence,
                    (noise - 0.5) * 0.1 * _Turbulence
                );
                
                float3 positionOS = IN.positionOS.xyz + offset;
                OUT.positionHCS = TransformObjectToHClip(positionOS);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.color = IN.color;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                
                // 基础UV动画
                float2 uv = IN.uv;
                float time = _Time.y * _Speed;
                
                // 添加滚动效果
                uv += _ScrollDirection.xy * time;
                
                // 噪声扭曲效果
                float2 noiseUV = uv * 2.0 + float2(time * 0.3, time * 0.2);
                float noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseUV).r;
                uv.xy += (noise - 0.5) * _Turbulence * 0.1;
                
                // 采样主纹理
                half4 smokeTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                
                // 应用溶解效果
                float dissolve = 1.0 - _Dissolve;
                float alpha = saturate((smokeTex.a - dissolve) / _EdgeFade);
                
                // 应用密度和颜色
                half3 smokeColor = smokeTex.rgb * _Color.rgb * _Density * IN.color.rgb;
                
                // 基于UV的渐变淡出
                float verticalFade = 1.0 - saturate(IN.uv.y * 1.5);
                alpha *= verticalFade;
                
                return half4(smokeColor, alpha * IN.color.a);
            }
            ENDHLSL
        }
    }
    
    Fallback "Universal Render Pipeline/Unlit"
}
