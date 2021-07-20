// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SmartWaveParticleLWRP"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_FinalColor("Final Color", Color) = (1,1,1,1)
		_FinalPower("Final Power", Range( 0 , 10)) = 1
		_Core("Core", 2D) = "white" {}
		_Mask("Mask", 2D) = "white" {}
		[Toggle(_STARTPOINTENABLED_ON)] _StartPointEnabled("Start Point Enabled", Float) = 0
		_StartPointMaskAdd("Start Point Mask Add", Float) = 0
		_StartPointMaskMultiply("Start Point Mask Multiply", Range( 0 , 10)) = 0
		[Toggle(_WAVEENABLED_ON)] _WaveEnabled("Wave Enabled", Float) = 0
		_WaveLength("Wave Length", Float) = 1

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Back
		HLSLINCLUDE
		#pragma target 2.0
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 70108

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _WAVEENABLED_ON
			#pragma shader_feature_local _STARTPOINTENABLED_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			float4 _ControlParticlePosition0;
			float _ControlParticleSize0;
			float _PSLossyScale;
			float4 _ControlParticlePosition1;
			float _ControlParticleSize1;
			float4 _ControlParticlePosition2;
			float _ControlParticleSize2;
			float4 _ControlParticlePosition3;
			float _ControlParticleSize3;
			float4 _ControlParticlePosition4;
			float _ControlParticleSize4;
			float4 _StartLaserPosition;
			float _StartLaserProgress;
			sampler2D _Core;
			sampler2D _Mask;
			CBUFFER_START( UnityPerMaterial )
			float _FinalPower;
			float4 _FinalColor;
			float _WaveLength;
			float _StartPointMaskAdd;
			float _StartPointMaskMultiply;
			float4 _Core_ST;
			float4 _Mask_ST;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.ase_texcoord;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float WL23 = ( _WaveLength / _PSLossyScale );
				float clampResult58 = clamp( ( ( distance( _ControlParticlePosition0 , float4( WorldPosition , 0.0 ) ) + ( 1.0 - ( _ControlParticleSize0 + 1.0 ) ) ) * WL23 ) , -0.5 , 0.5 );
				float WaveMask065 = abs( ( ( 2.0 * frac( clampResult58 ) ) - 1.0 ) );
				float clampResult76 = clamp( ( ( distance( _ControlParticlePosition1 , float4( WorldPosition , 0.0 ) ) + ( 1.0 - ( _ControlParticleSize1 + 1.0 ) ) ) * WL23 ) , -0.5 , 0.5 );
				float WaveMask183 = abs( ( ( 2.0 * frac( clampResult76 ) ) - 1.0 ) );
				float clampResult94 = clamp( ( ( distance( _ControlParticlePosition2 , float4( WorldPosition , 0.0 ) ) + ( 1.0 - ( _ControlParticleSize2 + 1.0 ) ) ) * WL23 ) , -0.5 , 0.5 );
				float WaveMask2101 = abs( ( ( 2.0 * frac( clampResult94 ) ) - 1.0 ) );
				float clampResult112 = clamp( ( ( distance( _ControlParticlePosition3 , float4( WorldPosition , 0.0 ) ) + ( 1.0 - ( _ControlParticleSize3 + 1.0 ) ) ) * WL23 ) , -0.5 , 0.5 );
				float WaveMask3119 = abs( ( ( 2.0 * frac( clampResult112 ) ) - 1.0 ) );
				float clampResult130 = clamp( ( ( distance( _ControlParticlePosition4 , float4( WorldPosition , 0.0 ) ) + ( 1.0 - ( _ControlParticleSize4 + 1.0 ) ) ) * WL23 ) , -0.5 , 0.5 );
				float WaveMask4137 = abs( ( ( 2.0 * frac( clampResult130 ) ) - 1.0 ) );
				#ifdef _WAVEENABLED_ON
				float staticSwitch145 = ( WaveMask065 + WaveMask183 + WaveMask2101 + WaveMask3119 + WaveMask4137 );
				#else
				float staticSwitch145 = 0.0;
				#endif
				float temp_output_33_0 = ( _PSLossyScale * _StartPointMaskAdd );
				float clampResult39 = clamp( (0.0 + (( ( ( ( 1.0 - distance( _StartLaserPosition , float4( WorldPosition , 0.0 ) ) ) - 1.0 ) + ( 1.0 * _PSLossyScale ) ) + temp_output_33_0 ) - 0.0) * (1.0 - 0.0) / (( 1.0 + temp_output_33_0 ) - 0.0)) , 0.0 , 1.0 );
				float clampResult42 = clamp( _StartLaserProgress , 0.0 , 1.0 );
				float DistanceMask46 = ( ( clampResult39 - ( 1.0 - clampResult42 ) ) * _StartPointMaskMultiply );
				#ifdef _STARTPOINTENABLED_ON
				float staticSwitch148 = DistanceMask46;
				#else
				float staticSwitch148 = 0.0;
				#endif
				float clampResult151 = clamp( ( staticSwitch145 + staticSwitch148 ) , 0.0 , 1.0 );
				float FinalMask152 = clampResult151;
				
				float4 uv0_Core = IN.ase_texcoord3;
				uv0_Core.xy = IN.ase_texcoord3.xy * _Core_ST.xy + _Core_ST.zw;
				float2 appendResult10 = (float2(uv0_Core.x , ( uv0_Core.y + uv0_Core.z )));
				float4 tex2DNode5 = tex2D( _Core, appendResult10 );
				float2 uv0_Mask = IN.ase_texcoord3.xy * _Mask_ST.xy + _Mask_ST.zw;
				float4 tex2DNode6 = tex2D( _Mask, uv0_Mask );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float fresnelNdotV11 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode11 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV11, 1.0 ) );
				float temp_output_12_0 = ( 1.0 - fresnelNode11 );
				float clampResult153 = clamp( ( tex2DNode5.r * tex2DNode6.r * temp_output_12_0 * FinalMask152 ) , 0.0 , 1.0 );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( IN.ase_color * _FinalPower * _FinalColor * FinalMask152 ).rgb;
				float Alpha = clampResult153;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 70108

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _WAVEENABLED_ON
			#pragma shader_feature_local _STARTPOINTENABLED_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Core;
			sampler2D _Mask;
			float4 _ControlParticlePosition0;
			float _ControlParticleSize0;
			float _PSLossyScale;
			float4 _ControlParticlePosition1;
			float _ControlParticleSize1;
			float4 _ControlParticlePosition2;
			float _ControlParticleSize2;
			float4 _ControlParticlePosition3;
			float _ControlParticleSize3;
			float4 _ControlParticlePosition4;
			float _ControlParticleSize4;
			float4 _StartLaserPosition;
			float _StartLaserProgress;
			CBUFFER_START( UnityPerMaterial )
			float _FinalPower;
			float4 _FinalColor;
			float _WaveLength;
			float _StartPointMaskAdd;
			float _StartPointMaskMultiply;
			float4 _Core_ST;
			float4 _Mask_ST;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord2 = v.ase_texcoord;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float4 uv0_Core = IN.ase_texcoord2;
				uv0_Core.xy = IN.ase_texcoord2.xy * _Core_ST.xy + _Core_ST.zw;
				float2 appendResult10 = (float2(uv0_Core.x , ( uv0_Core.y + uv0_Core.z )));
				float4 tex2DNode5 = tex2D( _Core, appendResult10 );
				float2 uv0_Mask = IN.ase_texcoord2.xy * _Mask_ST.xy + _Mask_ST.zw;
				float4 tex2DNode6 = tex2D( _Mask, uv0_Mask );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV11 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode11 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV11, 1.0 ) );
				float temp_output_12_0 = ( 1.0 - fresnelNode11 );
				float WL23 = ( _WaveLength / _PSLossyScale );
				float clampResult58 = clamp( ( ( distance( _ControlParticlePosition0 , float4( WorldPosition , 0.0 ) ) + ( 1.0 - ( _ControlParticleSize0 + 1.0 ) ) ) * WL23 ) , -0.5 , 0.5 );
				float WaveMask065 = abs( ( ( 2.0 * frac( clampResult58 ) ) - 1.0 ) );
				float clampResult76 = clamp( ( ( distance( _ControlParticlePosition1 , float4( WorldPosition , 0.0 ) ) + ( 1.0 - ( _ControlParticleSize1 + 1.0 ) ) ) * WL23 ) , -0.5 , 0.5 );
				float WaveMask183 = abs( ( ( 2.0 * frac( clampResult76 ) ) - 1.0 ) );
				float clampResult94 = clamp( ( ( distance( _ControlParticlePosition2 , float4( WorldPosition , 0.0 ) ) + ( 1.0 - ( _ControlParticleSize2 + 1.0 ) ) ) * WL23 ) , -0.5 , 0.5 );
				float WaveMask2101 = abs( ( ( 2.0 * frac( clampResult94 ) ) - 1.0 ) );
				float clampResult112 = clamp( ( ( distance( _ControlParticlePosition3 , float4( WorldPosition , 0.0 ) ) + ( 1.0 - ( _ControlParticleSize3 + 1.0 ) ) ) * WL23 ) , -0.5 , 0.5 );
				float WaveMask3119 = abs( ( ( 2.0 * frac( clampResult112 ) ) - 1.0 ) );
				float clampResult130 = clamp( ( ( distance( _ControlParticlePosition4 , float4( WorldPosition , 0.0 ) ) + ( 1.0 - ( _ControlParticleSize4 + 1.0 ) ) ) * WL23 ) , -0.5 , 0.5 );
				float WaveMask4137 = abs( ( ( 2.0 * frac( clampResult130 ) ) - 1.0 ) );
				#ifdef _WAVEENABLED_ON
				float staticSwitch145 = ( WaveMask065 + WaveMask183 + WaveMask2101 + WaveMask3119 + WaveMask4137 );
				#else
				float staticSwitch145 = 0.0;
				#endif
				float temp_output_33_0 = ( _PSLossyScale * _StartPointMaskAdd );
				float clampResult39 = clamp( (0.0 + (( ( ( ( 1.0 - distance( _StartLaserPosition , float4( WorldPosition , 0.0 ) ) ) - 1.0 ) + ( 1.0 * _PSLossyScale ) ) + temp_output_33_0 ) - 0.0) * (1.0 - 0.0) / (( 1.0 + temp_output_33_0 ) - 0.0)) , 0.0 , 1.0 );
				float clampResult42 = clamp( _StartLaserProgress , 0.0 , 1.0 );
				float DistanceMask46 = ( ( clampResult39 - ( 1.0 - clampResult42 ) ) * _StartPointMaskMultiply );
				#ifdef _STARTPOINTENABLED_ON
				float staticSwitch148 = DistanceMask46;
				#else
				float staticSwitch148 = 0.0;
				#endif
				float clampResult151 = clamp( ( staticSwitch145 + staticSwitch148 ) , 0.0 , 1.0 );
				float FinalMask152 = clampResult151;
				float clampResult153 = clamp( ( tex2DNode5.r * tex2DNode6.r * temp_output_12_0 * FinalMask152 ) , 0.0 , 1.0 );
				
				float Alpha = clampResult153;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

	
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18001
0;1;1920;1018;2629.418;140.8079;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;68;-5526.49,-3207.822;Float;False;Constant;_Float7;Float 7;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-5504.52,-5296.405;Float;False;Constant;_Float19;Float 19;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-5571.617,-5519.441;Float;False;Global;_ControlParticleSize4;_ControlParticleSize4;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-5593.589,-3430.858;Float;False;Global;_ControlParticleSize1;_ControlParticleSize1;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-5599.218,-2700.236;Float;False;Global;_ControlParticleSize0;_ControlParticleSize0;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-5465.595,-4649.175;Float;False;Constant;_Float15;Float 15;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-5538.399,-4174.261;Float;False;Global;_ControlParticleSize2;_ControlParticleSize2;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-4445.032,-1554.357;Float;False;Property;_WaveLength;Wave Length;8;0;Create;True;0;0;False;0;1;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-5471.302,-3951.225;Float;False;Constant;_Float11;Float 11;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-4465.799,-1472.173;Float;False;Global;_PSLossyScale;_PSLossyScale;4;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-5532.119,-2477.199;Float;False;Constant;_Float3;Float 3;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-5532.693,-4872.21;Float;False;Global;_ControlParticleSize3;_ControlParticleSize3;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;-5239.302,-4055.225;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;89;-5317.302,-4328.225;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;125;-5350.52,-5673.405;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;26;-4602.799,-1072.173;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;103;-5233.595,-4753.175;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;54;-5378.119,-2854.2;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-5272.52,-5400.405;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;24;-4642.799,-1245.173;Float;False;Global;_StartLaserPosition;_StartLaserPosition;5;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;71;-5372.491,-3584.822;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;88;-5400.302,-4497.225;Float;False;Global;_ControlParticlePosition2;_ControlParticlePosition2;7;0;Create;True;0;0;False;0;0.5,0.5,0.5,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;124;-5433.52,-5842.405;Float;False;Global;_ControlParticlePosition4;_ControlParticlePosition4;7;0;Create;True;0;0;False;0;0.5,0.5,0.5,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;52;-5461.119,-3023.2;Float;False;Global;_ControlParticlePosition0;_ControlParticlePosition0;7;0;Create;True;0;0;False;0;0.5,0.5,0.5,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-5300.119,-2581.2;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;70;-5455.49,-3753.822;Float;False;Global;_ControlParticlePosition1;_ControlParticlePosition1;7;0;Create;True;0;0;False;0;0.5,0.5,0.5,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;106;-5394.595,-5195.175;Float;False;Global;_ControlParticlePosition3;_ControlParticlePosition3;7;0;Create;True;0;0;False;0;0.5,0.5,0.5,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;107;-5311.595,-5026.175;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;22;-4190.796,-1534.173;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-5294.491,-3311.822;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-4061.793,-1535.173;Float;False;WL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;87;-5016.302,-4139.225;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;126;-5087.52,-5763.405;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;105;-5010.595,-4837.175;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;123;-5049.52,-5484.405;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;72;-5109.491,-3674.822;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;90;-5054.302,-4418.225;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;53;-5115.118,-2944.2;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;50;-5077.118,-2665.2;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;69;-5071.491,-3395.822;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;108;-5048.595,-5116.175;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;25;-4330.798,-1170.173;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-4806.491,-3532.822;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;127;-4784.52,-5621.405;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-4807.302,-4173.225;Inherit;False;23;WL;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-4801.595,-4871.175;Inherit;False;23;WL;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-4862.491,-3429.822;Inherit;False;23;WL;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;-4840.52,-5518.405;Inherit;False;23;WL;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-4745.595,-4974.175;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-4751.302,-4276.225;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-4182.796,-985.1728;Float;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;27;-4194.796,-1170.173;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-4868.116,-2699.2;Inherit;False;23;WL;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-4812.116,-2802.2;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-4506.595,-4931.175;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-4567.49,-3489.822;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-4512.302,-4233.225;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-3823.793,-853.1728;Float;False;Property;_StartPointMaskAdd;Start Point Mask Add;5;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;-4545.52,-5578.405;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-4573.115,-2759.2;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;28;-3978.793,-1084.173;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-3982.793,-909.1728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;76;-4377.489,-3459.822;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-3802.793,-1084.173;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-3363.793,-911.1728;Float;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;112;-4316.595,-4901.175;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;58;-4383.114,-2729.2;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;130;-4355.52,-5548.405;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-3568.793,-926.1728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;94;-4322.302,-4203.225;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-4259.489,-3548.822;Float;False;Constant;_Float8;Float 8;7;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-3145.793,-844.1728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-3364.793,-986.1728;Float;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;59;-4239.114,-2730.2;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;95;-4178.302,-4204.225;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;113;-4172.595,-4902.175;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;77;-4233.489,-3460.822;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-4237.52,-5637.405;Float;False;Constant;_Float20;Float 20;7;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-3174.009,-1327.065;Float;False;Global;_StartLaserProgress;_StartLaserProgress;6;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-4265.114,-2818.2;Float;False;Constant;_Float4;Float 4;7;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-3349.793,-1080.173;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-4204.302,-4292.225;Float;False;Constant;_Float12;Float 12;7;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;131;-4211.52,-5549.405;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-4198.595,-4990.175;Float;False;Constant;_Float16;Float 16;7;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-4076.114,-2686.2;Float;False;Constant;_Float5;Float 5;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-4009.595,-4858.175;Float;False;Constant;_Float17;Float 17;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;42;-2936.137,-1324.479;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-4066.489,-3524.822;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-4011.302,-4268.225;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-4015.302,-4160.225;Float;False;Constant;_Float13;Float 13;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-4070.489,-3416.822;Float;False;Constant;_Float9;Float 9;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-4005.595,-4966.175;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-4072.114,-2794.2;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;-4044.52,-5613.405;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;38;-2994.793,-1021.173;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-4048.52,-5505.405;Float;False;Constant;_Float21;Float 21;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;135;-3844.52,-5573.405;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;81;-3866.489,-3484.822;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;117;-3805.595,-4926.175;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;39;-2817.793,-1022.173;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;43;-2797.813,-1324.479;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;99;-3811.302,-4228.225;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;62;-3872.114,-2754.2;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-2841.767,-824.1777;Float;False;Property;_StartPointMaskMultiply;Start Point Mask Multiply;6;0;Create;True;0;0;False;0;0;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;118;-3658.595,-4928.175;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;64;-3725.114,-2756.2;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;136;-3697.52,-5575.405;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-2558.651,-1179.689;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;82;-3719.489,-3486.822;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;100;-3664.302,-4230.225;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-3538.302,-4235.225;Float;False;WaveMask2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-3532.595,-4933.175;Float;False;WaveMask3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-3599.114,-2761.2;Float;False;WaveMask0;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-2553.479,-974.1391;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;-3593.489,-3491.822;Float;False;WaveMask1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;137;-3571.52,-5580.405;Float;False;WaveMask4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-2394.469,-974.1385;Float;False;DistanceMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;-2341.134,-1964.645;Inherit;False;65;WaveMask0;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-2342.436,-1805.954;Inherit;False;101;WaveMask2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;141;-2343.737,-1882.698;Inherit;False;83;WaveMask1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-2346.339,-1638.156;Inherit;False;137;WaveMask4;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;143;-2350.241,-1722.706;Inherit;False;119;WaveMask3;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-2006.94,-1349.827;Inherit;False;46;DistanceMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-2011.942,-1900.242;Float;False;Constant;_Float22;Float 22;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-1938.889,-1436.893;Float;False;Constant;_Float23;Float 23;9;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;138;-1992.99,-1814.759;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;148;-1770.761,-1401.867;Float;False;Property;_StartPointEnabled;Start Point Enabled;4;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;145;-1742.704,-1711.249;Float;False;Property;_WaveEnabled;Wave Enabled;7;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;147;-1409.489,-1613.026;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-2120.47,-301.6293;Inherit;False;0;5;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-1852.401,-186.8918;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;151;-1290.399,-1611.024;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-1815.269,-60.44904;Inherit;False;0;6;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;-1154.295,-1610.023;Float;False;FinalMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;-1693.401,-273.8919;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;11;-1646.701,130.408;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-1553.407,-83.60284;Inherit;True;Property;_Mask;Mask;3;0;Create;True;0;0;False;0;-1;None;77d4fb3924534c96930be79c8d6f0658;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;18;-1075.737,702.9338;Inherit;False;152;FinalMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1545.511,-301.6243;Inherit;True;Property;_Core;Core;2;0;Create;True;0;0;False;0;-1;None;75afc57a36ca4de5b65bb82b7691a229;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;12;-1420.701,126.408;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-851.2764,-177.1918;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1174.737,454.9338;Float;False;Property;_FinalPower;Final Power;1;0;Create;True;0;0;False;0;1;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-394.3274,161.8438;Float;False;Constant;_Float24;Float 24;9;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;153;-692.3143,-176.148;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-753.926,271.6964;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;17;-1105.737,534.9338;Float;False;Property;_FinalColor;Final Color;0;0;Create;True;0;0;False;0;1,1,1,1;0,0.4627448,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1138.4,2.108059;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;13;-1446.401,312.1081;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;158;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;159;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;156;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;157;0,0;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;SmartWaveParticleLWRP;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;160;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;85;0;84;0
WireConnection;85;1;86;0
WireConnection;103;0;102;0
WireConnection;103;1;104;0
WireConnection;121;0;120;0
WireConnection;121;1;122;0
WireConnection;48;0;47;0
WireConnection;48;1;49;0
WireConnection;22;0;20;0
WireConnection;22;1;21;0
WireConnection;67;0;66;0
WireConnection;67;1;68;0
WireConnection;23;0;22;0
WireConnection;87;0;85;0
WireConnection;126;0;124;0
WireConnection;126;1;125;0
WireConnection;105;0;103;0
WireConnection;123;0;121;0
WireConnection;72;0;70;0
WireConnection;72;1;71;0
WireConnection;90;0;88;0
WireConnection;90;1;89;0
WireConnection;53;0;52;0
WireConnection;53;1;54;0
WireConnection;50;0;48;0
WireConnection;69;0;67;0
WireConnection;108;0;106;0
WireConnection;108;1;107;0
WireConnection;25;0;24;0
WireConnection;25;1;26;0
WireConnection;73;0;72;0
WireConnection;73;1;69;0
WireConnection;127;0;126;0
WireConnection;127;1;123;0
WireConnection;109;0;108;0
WireConnection;109;1;105;0
WireConnection;91;0;90;0
WireConnection;91;1;87;0
WireConnection;27;0;25;0
WireConnection;51;0;53;0
WireConnection;51;1;50;0
WireConnection;111;0;109;0
WireConnection;111;1;110;0
WireConnection;75;0;73;0
WireConnection;75;1;74;0
WireConnection;93;0;91;0
WireConnection;93;1;92;0
WireConnection;129;0;127;0
WireConnection;129;1;128;0
WireConnection;57;0;51;0
WireConnection;57;1;55;0
WireConnection;28;0;27;0
WireConnection;28;1;29;0
WireConnection;31;0;29;0
WireConnection;31;1;21;0
WireConnection;76;0;75;0
WireConnection;30;0;28;0
WireConnection;30;1;31;0
WireConnection;112;0;111;0
WireConnection;58;0;57;0
WireConnection;130;0;129;0
WireConnection;33;0;21;0
WireConnection;33;1;32;0
WireConnection;94;0;93;0
WireConnection;37;0;36;0
WireConnection;37;1;33;0
WireConnection;59;0;58;0
WireConnection;95;0;94;0
WireConnection;113;0;112;0
WireConnection;77;0;76;0
WireConnection;34;0;30;0
WireConnection;34;1;33;0
WireConnection;131;0;130;0
WireConnection;42;0;41;0
WireConnection;78;0;79;0
WireConnection;78;1;77;0
WireConnection;96;0;97;0
WireConnection;96;1;95;0
WireConnection;114;0;115;0
WireConnection;114;1;113;0
WireConnection;60;0;61;0
WireConnection;60;1;59;0
WireConnection;132;0;133;0
WireConnection;132;1;131;0
WireConnection;38;0;34;0
WireConnection;38;1;35;0
WireConnection;38;2;37;0
WireConnection;38;3;35;0
WireConnection;38;4;36;0
WireConnection;135;0;132;0
WireConnection;135;1;134;0
WireConnection;81;0;78;0
WireConnection;81;1;80;0
WireConnection;117;0;114;0
WireConnection;117;1;116;0
WireConnection;39;0;38;0
WireConnection;43;0;42;0
WireConnection;99;0;96;0
WireConnection;99;1;98;0
WireConnection;62;0;60;0
WireConnection;62;1;63;0
WireConnection;118;0;117;0
WireConnection;64;0;62;0
WireConnection;136;0;135;0
WireConnection;40;0;39;0
WireConnection;40;1;43;0
WireConnection;82;0;81;0
WireConnection;100;0;99;0
WireConnection;101;0;100;0
WireConnection;119;0;118;0
WireConnection;65;0;64;0
WireConnection;44;0;40;0
WireConnection;44;1;45;0
WireConnection;83;0;82;0
WireConnection;137;0;136;0
WireConnection;46;0;44;0
WireConnection;138;0;140;0
WireConnection;138;1;141;0
WireConnection;138;2;142;0
WireConnection;138;3;143;0
WireConnection;138;4;144;0
WireConnection;148;1;149;0
WireConnection;148;0;150;0
WireConnection;145;1;146;0
WireConnection;145;0;138;0
WireConnection;147;0;145;0
WireConnection;147;1;148;0
WireConnection;9;0;4;2
WireConnection;9;1;4;3
WireConnection;151;0;147;0
WireConnection;152;0;151;0
WireConnection;10;0;4;1
WireConnection;10;1;9;0
WireConnection;6;1;7;0
WireConnection;5;1;10;0
WireConnection;12;0;11;0
WireConnection;19;0;5;1
WireConnection;19;1;6;1
WireConnection;19;2;12;0
WireConnection;19;3;18;0
WireConnection;153;0;19;0
WireConnection;15;0;13;0
WireConnection;15;1;16;0
WireConnection;15;2;17;0
WireConnection;15;3;18;0
WireConnection;14;0;5;1
WireConnection;14;1;6;1
WireConnection;14;2;12;0
WireConnection;14;3;13;0
WireConnection;157;2;15;0
WireConnection;157;3;153;0
ASEEND*/
//CHKSM=20D8A86316860905AA8CCE7758DD8A3B25C3A219