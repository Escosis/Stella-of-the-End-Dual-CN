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
	float  angle;	// vsync‚Å“n‚·’l(Šp“x)
	float  inter;	// ‚¤‚Ë‚¤‚Ë‚ÌŠÔŠu
	float  size;	// ‚¤‚Ë‚¤‚Ë‚ÌƒTƒCƒY
};

SamplerState samplerBack : register(s0);
Texture2D textureBack : register(t0);
Texture2D textureFore : register(t1);
Texture2D textureMask : register(t2);

float4 main(SVertexShaderResult vertexShaderResult) : SV_TARGET
{
	float2 uv = vertexShaderResult.texCoord1;
	uv.x += sin(radians(uv.y * inter - angle)) * size;
	float4 back = textureBack.Sample(samplerBack, vertexShaderResult.texCoord0);
	float4 fore = textureFore.Sample(samplerBack, uv);
	float4 mask = textureMask.Sample(samplerBack, vertexShaderResult.texCoord1);
	float mask_a = 1.0;
	fore.a *= mask_a * alpha;
	return fore;
}
