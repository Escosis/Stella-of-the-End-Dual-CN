struct SVertexShaderResult
{
	float4 position : SV_POSITION;
	float2 texCoord0 : TEXCOORD0;
	float2 texCoord1 : TEXCOORD1;
};
cbuffer ConstantBuffer
{
	//--------------------------------------
	// î‰är(ñæ)
	//--------------------------------------
	float  alpha;
	float3 colorMultiply;
	float  maskTransitionVague;
	float  maskTransitionStep;
};
cbuffer ConstantBuffer
{
	float  param;
};

SamplerState samplerBack : register(s0);
Texture2D textureBack : register(t0);
Texture2D textureFore : register(t1);
Texture2D textureMask : register(t2);
Texture2D textureUser : register(t3);

float4 main(SVertexShaderResult vertexShaderResult) : SV_TARGET
{
//	float4 back = textureBack.Sample(samplerBack, vertexShaderResult.texCoord0);
	float4 back = textureBack.Sample(samplerBack, vertexShaderResult.texCoord0);
	float4 fore = textureFore.Sample(samplerBack, vertexShaderResult.texCoord1);
	float4 user = textureUser.Sample(samplerBack, vertexShaderResult.texCoord1);
	float4 mask = textureMask.Sample(samplerBack, vertexShaderResult.texCoord1);
	float mask_a = 1.0;
	float fore_a = fore.a * (1.0 - user.a) + user.a;
	user.r = max(fore.r, user.r);
	user.g = max(fore.g, user.g);
	user.b = max(fore.b, user.b);
	fore.rgb = (fore.rgb * fore.a * (1.0 - user.a) + user.rgb * user.a) / fore_a * param;
	fore.a  *= mask_a * alpha;
	return fore;
}
