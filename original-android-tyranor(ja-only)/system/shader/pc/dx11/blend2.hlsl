struct SVertexShaderResult
{
	float4 position : SV_POSITION;
	float2 texCoord0 : TEXCOORD0;
	float2 texCoord1 : TEXCOORD1;
};
cbuffer ConstantBuffer
{
	float  alpha;
	float3 colorMultiply;
	float  maskTransitionVague;
	float  maskTransitionStep;
};
cbuffer ConstantBuffer
{
};

SamplerState samplerBack : register(s0);
Texture2D textureBack : register(t0);
Texture2D textureFore : register(t1);
Texture2D textureMask : register(t2);

float4 main(SVertexShaderResult vertexShaderResult) : SV_TARGET
{
	const float3 graydata = float3(0.298912, 0.586611, 0.114478);
	float4 back = textureBack.Sample(samplerBack, vertexShaderResult.texCoord0);
	float4 fore = textureFore.Sample(samplerBack, vertexShaderResult.texCoord1);
	float4 mask = textureMask.Sample(samplerBack, vertexShaderResult.texCoord1);
	float mask_a = 1.0;
	float f = float3(fore.r, fore.g, fore.b);
	float a = f > 0.78 ? 1.0 - f : 1.0;
	fore.a = mask_a * alpha * a;
	return fore;
}
