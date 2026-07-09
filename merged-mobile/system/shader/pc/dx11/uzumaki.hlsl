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
	float  width;
	float  height;
	float  size;
	float  radius;
};

SamplerState samplerBack : register(s0);
Texture2D textureBack : register(t0);
Texture2D textureFore : register(t1);
Texture2D textureMask : register(t2);

float4 main(SVertexShaderResult vertexShaderResult) : SV_TARGET
{
	float2 uv = vertexShaderResult.texCoord1;
	float2 screen = float2( width, height );
	float2 center = float2( width / 2, height / 2 );
	float2 pos = (uv * screen) - center;
	float len = length(pos);
	if(len < radius) {
		float uzu = min(max(1.0 - (len / radius), 0.0), 1.0) * size; 
		float x = pos.x * cos(uzu) - pos.y * sin(uzu); 
		float y = pos.x * sin(uzu) + pos.y * cos(uzu);
		uv = (float2(x, y) + center) / screen;
	}
	float4 back = textureBack.Sample(samplerBack, vertexShaderResult.texCoord0);
	float4 fore = textureFore.Sample(samplerBack, uv);
	fore.a *= alpha;
	return fore;
}
