///**********************************************
///痕迹增强shader
///**********************************************
Shader "Custom/MarkEnhancement" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		//a 通道代表痕迹深浅
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		//遮罩贴图 r通道标记需要增强的区域
		_Mask("Mask",2D) = "white"{}
		//痕迹深浅程度
		[Space(10)]_Depth("Depth",Range(0,1)) = 0
		//痕迹的最深颜色
		_FinalColor("FinalColor",Color) = (1,1,1,1)

		[Space(10)]_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Emission("Emission",2D) = "white"{}
		_EmColor("EmColor",Color) = (1,1,1,1)

		
		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Mask;
		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _Depth;
		float4 _FinalColor;
		sampler2D _Emission;
		float4 _EmColor;
		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			//当前痕迹的深浅度
			float deep = c.a;
			//是否要剔除
			float isClip = tex2D(_Mask, IN.uv_MainTex).r;
			//是否需要更深的漆
			float isNeedDeeperColor = step(deep, _Depth);

			//计算基本颜色
			float3 albedo = (1 - isClip) * c.rgb + isClip * ( lerp(c.rgb, _FinalColor, _Depth) * isNeedDeeperColor + (1 - isNeedDeeperColor) * c.rgb);
			//另一种效果
			//float3 albedo = (1 - isNeedClip) * c.rgb + isNeedClip * lerp(c.rgb, _FinalColor, _Depth);
			o.Albedo = float4(albedo,1) * _Color;

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
			o.Emission = tex2D(_Emission, IN.uv_MainTex)*_EmColor;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
