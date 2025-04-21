Shader "Custom/CartoonWater"
{
    Properties
    {
        [Header(Color Settings)]
        _ShallowColor("ǳˮ��ɫ", Color) = (0.3, 0.8, 1.0, 0.6)
        _DeepColor("��ˮ��ɫ", Color) = (0.1, 0.4, 0.7, 0.8)
        _EdgeFoamColor("��Ե��ĭ", Color) = (1,1,1,1)
        _ColorSteps("��ɫ�ֲ�", Range(1, 5)) = 3
        _DepthFade("��Ƚ���", Range(0, 5)) = 1.0

        [Header(Wave Settings)]
        _WaveSpeed("�����ٶ�", Range(0, 2)) = 0.8
        _WaveScale("���Ƴߴ�", Range(0, 0.3)) = 0.1
        _WaveStrength("����ǿ��", Range(0, 1)) = 0.5

        [Header(Edge Effects)]
        _FresnelPower("��Եǿ��", Range(0, 10)) = 3.0
        _FoamThreshold("��ĭ��ֵ", Range(0, 1)) = 0.7

        [Header(Refraction)]
        _RefractionStrength("����ǿ��", Range(0, 0.2)) = 0.05
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

        TEXTURE2D_X(_CameraOpaqueTexture);
        SAMPLER(sampler_CameraOpaqueTexture);

        CBUFFER_START(UnityPerMaterial)
            half4 _ShallowColor;
            half4 _DeepColor;
            half4 _EdgeFoamColor;
            float _WaveSpeed;
            float _WaveScale;
            float _WaveStrength;
            float _FresnelPower;
            float _FoamThreshold;
            float _RefractionStrength;
            float _ColorSteps;
            float _DepthFade;
        CBUFFER_END

        struct Attributes
        {
            float4 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float2 uv : TEXCOORD0;
        };

        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS : TEXCOORD0;
            float3 normalWS : TEXCOORD1;
            float4 screenPos : TEXCOORD2;
            float3 viewDir : TEXCOORD3;
            float sceneDepth : TEXCOORD4;
        };
        ENDHLSL

        Pass
        {
            Name "WaterPass"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS

            Varyings vert(Attributes input)
            {
                Varyings output;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);

                // ���ƶ��㶯��
                float wave = sin(_Time.y * _WaveSpeed + input.positionOS.x * 2) * _WaveStrength;
                input.positionOS.y += wave * 0.1;

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = vertexInput.positionWS;
                output.normalWS = normalInput.normalWS;
                output.viewDir = GetWorldSpaceViewDir(vertexInput.positionWS);
                output.screenPos = ComputeScreenPos(output.positionCS);
                
                // ��ȼ���
                float4 clipPos = TransformWorldToHClip(vertexInput.positionWS);
                output.sceneDepth = ComputeFogFactor(clipPos.z);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                // ��ȡ�����Ϣ
                float2 screenUV = input.screenPos.xy / input.screenPos.w;
                float rawDepth = SampleSceneDepth(screenUV);
                float sceneDepth = LinearEyeDepth(rawDepth, _ZBufferParams);
                float waterDepth = sceneDepth - input.positionCS.w;
                float depthLerp = saturate(waterDepth * _DepthFade);

                // �Ľ��ķ���������
                float3 viewDir = normalize(input.viewDir);
                float fresnel = 1.0 - saturate(dot(viewDir, input.normalWS));
                fresnel = pow(fresnel, _FresnelPower);
                
                // ����ʽ��ɫ�ֲ�
                float steppedFresnel = floor(fresnel * _ColorSteps) / _ColorSteps;
                half4 baseColor = lerp(_DeepColor, _ShallowColor, depthLerp);
                half4 waterColor = lerp(baseColor * 0.8, baseColor * 1.2, steppedFresnel);

                // ��̬����Ч��
                float2 waveUV = screenUV * _WaveScale + _Time.y * _WaveSpeed;
                float2 waveOffset = sin(waveUV * 5.0) * _WaveStrength * 0.1;
                
                // ����Ч��
                half4 sceneColor = SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, screenUV + waveOffset);
                
                // ��Ե��ĭ
                float foam = smoothstep(_FoamThreshold - 0.1, _FoamThreshold + 0.1, fresnel);
                waterColor.rgb = lerp(waterColor.rgb, _EdgeFoamColor.rgb, foam);

                // ���ջ��
                return lerp(sceneColor, waterColor, waterColor.a);
            }
            ENDHLSL
        }

        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
    FallBack "Universal Render Pipeline/Simple Lit"
}
