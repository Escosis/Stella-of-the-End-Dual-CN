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
	float4 weights[2];
	float  height;
};

SamplerState samplerBack : register(s0);
Texture2D textureBack : register(t0);
Texture2D textureFore : register(t1);
Texture2D textureMask : register(t2);

float4 main(SVertexShaderResult vertexShaderResult) : SV_TARGET
{
	float4 back = textureBack.Sample(samplerBack, vertexShaderResult.texCoord0);
	float4 fore = textureFore.Sample(samplerBack, vertexShaderResult.texCoord1) * weights[0][0];
	float4 mask = textureMask.Sample(samplerBack, vertexShaderResult.texCoord1);
	float mask_a = 1.0;
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height *  1.0)) * weights[0][1];
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height * -1.0)) * weights[0][1];
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height *  2.0)) * weights[0][2];
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height * -2.0)) * weights[0][2];
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height *  3.0)) * weights[0][3];
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height * -3.0)) * weights[0][3];
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height *  4.0)) * weights[1][0];
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height * -4.0)) * weights[1][0];
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height *  5.0)) * weights[1][1];
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height * -5.0)) * weights[1][1];
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height *  6.0)) * weights[1][2];
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height * -6.0)) * weights[1][2];
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height *  7.0)) * weights[1][3];
	fore += textureFore.Sample(samplerBack, vertexShaderResult.texCoord1 + float2(0.0, height * -7.0)) * weights[1][3];
	fore.a *= mask_a * alpha;
	return fore;
}
