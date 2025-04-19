Shader "Custom/WavingGrass"
{
   Properties
    {
        [MainTexture] _BaseMap("Base Texture", 2D) = "white" {}
        [MainColor] _BaseColor("Base Color", Color) = (1,1,1,1)
        _WindDirection("Wind Direction", Vector) = (1, 0, 0.5, 0)
        _WindStrength("Wind Strength", Range(0, 2)) = 0.5
        _WindSpeed("Wind Speed", Range(0, 5)) = 2.0
        _WaveFrequency("Wave Frequency", Range(0, 5)) = 1.5
    }

    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        
        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            float4 _WindDirection;
            float _WindStrength;
            float _WindSpeed;
            float _WaveFrequency;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            Cull Off
            ZWrite On
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma instancing_options procedural:SetupGrassWind
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };

            // 风力计算函数
            float3 ApplyWindEffect(float3 positionOS, float2 uv)
            {
                float windTime = _Time.y * _WindSpeed;
                float3 windDirection = normalize(_WindDirection.xyz);
                
                // 正弦波叠加噪声
                float wave = sin(positionOS.x * _WaveFrequency + windTime);
                float noise = frac(sin(dot(positionOS.xyz, float3(12.9898,78.233,45.543))) * 43758.5453);
                wave += noise * 0.3;
                
                // 根据UV的V方向（草的高度）增强顶部摆动
                float heightFactor = uv.y;
                float3 displacement = windDirection * wave * _WindStrength * heightFactor;
                
                return positionOS + displacement * 0.1;
            }

            Varyings vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                
                // 应用顶点动画
                float3 modifiedPositionOS = ApplyWindEffect(input.positionOS.xyz, input.uv);
                input.positionOS.xyz = modifiedPositionOS;
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;
                output.positionWS = vertexInput.positionWS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
                return baseColor;
            }
            ENDHLSL
        }

        // 阴影投射Pass（可选）
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            HLSLPROGRAM
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            
            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output;
                input.positionOS.xyz = ApplyWindEffect(input.positionOS.xyz, input.uv);
                output.positionCS = GetShadowPositionHClip(input);
                return output;
            }
            
            half4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
                return 0;
            }
            ENDHLSL
        }
    }
}
