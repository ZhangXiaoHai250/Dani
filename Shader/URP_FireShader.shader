Shader "Custom/URP_FireShader"
{
    Properties
    {
        _MainTex ("Fire Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "gray" {}
        _Color ("Color", Color) = (1, 0.5, 0, 1)
        _Intensity ("Intensity", Range(0, 5)) = 1
        _Speed ("Speed", Range(0, 5)) = 1
        _Distortion ("Distortion", Range(0, 1)) = 0.2
        _EdgeSoftness ("Edge Softness", Range(0, 1)) = 0.5
        _AlphaCutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
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
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _Color;
                float _Intensity;
                float _Speed;
                float _Distortion;
                float _EdgeSoftness;
                float _AlphaCutoff;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                
                // 创建动态UV动画
                float2 uv = IN.uv;
                float time = _Time.y * _Speed;
                
                // 噪声扭曲效果
                float2 noiseUV = uv + float2(0, time * 0.5);
                float noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseUV).r;
                
                // 应用扭曲
                uv.y -= time;
                uv.x += (noise - 0.5) * _Distortion;
                
                // 采样主纹理
                half4 fireTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                
                // 计算火焰边缘
                float gradient = 1.0 - IN.uv.y;
                float alpha = fireTex.a * gradient;
                
                // 应用软边
                alpha = smoothstep(_AlphaCutoff, _AlphaCutoff + _EdgeSoftness, alpha);
                
                // 组合颜色
                half3 fireColor = fireTex.rgb * _Color.rgb * _Intensity;
                
                return half4(fireColor, alpha);
            }
            ENDHLSL
        }
    }
}
