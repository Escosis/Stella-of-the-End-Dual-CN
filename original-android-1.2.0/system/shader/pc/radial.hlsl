//--------------------------------------
// スクリーン合成
//--------------------------------------
texture textureBack;
texture textureFore;
texture textureMask;

sampler samplerBack = sampler_state { texture = <textureBack>; MinFilter = LINEAR; MagFilter = LINEAR; AddressU = Clamp; AddressV = Clamp; };
sampler samplerFore = sampler_state { texture = <textureFore>; MinFilter = LINEAR; MagFilter = LINEAR; AddressU = Clamp; AddressV = Clamp; };
sampler samplerMask = sampler_state { texture = <textureMask>; MinFilter = LINEAR; MagFilter = LINEAR; AddressU = Clamp; AddressV = Clamp; };

float  alpha;
float3 colorMultiply;
float  maskTransitionVague;
float  maskTransitionStep;
float  ax;
float  ay;
float  size;
float  fade;

void vs(float4 position : POSITION, float2 texCoord0 : TEXCOORD0, float2 texCoord1 : TEXCOORD1, out float4 resultPosition : POSITION, out float2 resultTexCoord0 : TEXCOORD0, out float2 resultTexCoord1 : TEXCOORD1)
{
	resultPosition  = position;
	resultTexCoord0 = texCoord0;
	resultTexCoord1 = texCoord1;
}

void ps(float2 texCoord0 : TEXCOORD0, float2 texCoord1 : TEXCOORD1, out float4 result : COLOR0)
{
	float4 mask = tex2D(samplerMask, texCoord1);
	float2 uv = texCoord1;
	float2 cent = float2(ax, ay);			// 中心値
	float2 poss = uv - cent;				// 中心を基準にする
	float dist = length(poss);				// 中心からの距離
	float factor = size / 8.0 * dist;		// 配分

	float ave = 1.0 / 8.0;					// 一個あたりの割合

	float4 fadd = 0;
	float4 fore = tex2D(samplerFore, texCoord1);
	fadd += tex2D(samplerFore, poss * (1.0 - factor * 1.0) + cent) * ave;
	fadd += tex2D(samplerFore, poss * (1.0 - factor * 2.0) + cent) * ave;
	fadd += tex2D(samplerFore, poss * (1.0 - factor * 3.0) + cent) * ave;
	fadd += tex2D(samplerFore, poss * (1.0 - factor * 4.0) + cent) * ave;
	fadd += tex2D(samplerFore, poss * (1.0 - factor * 5.0) + cent) * ave;
	fadd += tex2D(samplerFore, poss * (1.0 - factor * 6.0) + cent) * ave;
	fadd += tex2D(samplerFore, poss * (1.0 - factor * 7.0) + cent) * ave;
	fore *= (ave + (1.0 - ave) * (1.0 - fade));
	fore += fadd * fade;

	float mask_a = mask.a;
	fore.a   *= mask_a * alpha;
	result = fore;
}

technique technique0
{
	pass p0
	{
		VertexShader     = compile vs_2_0 vs();
		PixelShader      = compile ps_3_0 ps();
		CullMode         = NONE;
		ZEnable          = false;
		AlphaBlendEnable = true;
	}
}
