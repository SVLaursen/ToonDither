Shader "Cutface/ToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DitherPattern("Dithering Pattern", 2D) = "white" {}
        _DitherMult("Dithering Multiplier", Range(0.0, 1.0)) = 0.3
        _Brightness("Brightness", Range(0.0, 1.0)) = 0.3
        _Strength("Strenght", Range(0.0, 1.0)) = 0.5
        _Color("Color", COLOR) = (1, 1, 1, 1)
        _Detail("Detail", Range(0.0, 1.0)) = 0.3
        _LightPos("Light Position", Vector) = (0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 worldNormal : NORMAL;
                float4 screenPosition : TEXCOORD1;
            };

            struct Colors
            {
                fixed4 col1;
                fixed4 col2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            sampler2D _DitherPattern;
            float4 _DitherPattern_TexelSize;
            float _DitherMult;
            
            float _Brightness;
            float _Strength;
            float4 _Color;
            float _Detail;
            float3 _LightPos;

            float4 Toon(float3 normal, float3 lighDir, float4 screenPosition)
            {
                float nDotL = max(0.0, dot(normalize(normal), normalize(lighDir)));
                float floored = floor(nDotL / _Detail);
                
                float2 screenPos = screenPosition.xy / screenPosition.w;
                
                float2 ditherCoordinate = screenPos * _ScreenParams.xy * _DitherPattern_TexelSize.xy;
                float ditherValue = tex2D(_DitherPattern, ditherCoordinate).r;
                float dithered = step(ditherValue , nDotL);
                
                return lerp(dithered, floored, _DitherMult);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.screenPosition = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= _Color;
                col *= Toon(i.worldNormal, _WorldSpaceLightPos0.xyz * _LightPos, i.screenPosition) * _Strength + _Brightness;
                return col;
            }
            
            ENDCG
        }
    }
}
