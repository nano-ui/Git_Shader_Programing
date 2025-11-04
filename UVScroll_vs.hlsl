#include "UVScroll.hlsli"

VS_OUT main(float4 position : POSITION, float4 color : COLOR, float2 texcoord : TEXCOORD)
{
    VS_OUT vont;
    vont.position = position;
    vont.color = color;
    //vont.texcoord = texcoord + options.z;
    vont.texcoord = texcoord + scroll_direction * options.zz;
    
    return vont;
}