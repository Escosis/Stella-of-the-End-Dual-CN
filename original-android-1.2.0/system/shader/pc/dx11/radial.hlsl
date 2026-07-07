struct SVertexShaderResult
{
	float4 position : SV_POSITION;
	float2 texCoord0 : TEXCOORD0;
	float2 texCoord1 : TEXCOORD1;
};
cbuffer ConstantBuffer
{
	//--------------------------------------
	// スクリーン合成
	//--------------------------------------
	float  alpha;
	float3 colorMultiply;
	float  maskTransitionVague;
	float  maskTransitionStep;
};
cbuffer ConstantBuffer
{
	float  ax;
	float  ay;
	float  size;
	float  fade;
};

SamplerState samplerBack : register(s0);
Texture2D textureBack : register(t0);
Texture2D textureFore : register(t1);
Texture2D textureMask : register(t2);

float4 main(SVertexShaderResult vertexShaderResult) : SV_TARGET
{
	float4 mask = textureMask.Sample(samplerBack, vertexShaderResult.texCoord1);
	float2 uv = vertexShaderResult.texCoord1;
	float2 cent = float2(ax, ay);			// 中心値
	float2 poss = uv - cent;				// 中心を基準にする
	float dist = length(poss);				// 中心からの距離
	float factor = size / 8.0 * dist;		// 配分
	float ave = 1.0 / 8.0;					// 一個あたりの割合
	float4 fadd = float4(0.0, 0.0, 0.0, 0.0);
	float4 back = textureBack.Sample(samplerBack, vertexShaderResult.texCoord0);
	float4 fore = textureFore.Sample(samplerBack, vertexShaderResult.texCoord1);
	fadd += textureFore.Sample(samplerBack, poss * (1.0 - factor * 1.0) + cent) * ave;
	fadd += textureFore.Sample(samplerBack, poss * (1.0 - factor * 2.0) + cent) * ave;
	fadd += textureFore.Sample(samplerBack, poss * (1.0 - factor * 3.0) + cent) * ave;
	fadd += textureFore.Sample(samplerBack, poss * (1.0 - factor * 4.0) + cent) * ave;
	fadd += textureFore.Sample(samplerBack, poss * (1.0 - factor * 5.0) + cent) * ave;
	fadd += textureFore.Sample(samplerBack, poss * (1.0 - factor * 6.0) + cent) * ave;
	fadd += textureFore.Sample(samplerBack, poss * (1.0 - factor * 7.0) + cent) * ave;
	fore *= (ave + (1.0 - ave) * (1.0 - fade));
	fore += fadd * fade;
	float mask_a = 1.0;
	fore.a   *= mask_a * alpha;
	return fore;
}
