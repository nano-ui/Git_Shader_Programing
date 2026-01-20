#include "skymap.hlsli"

VS_OUT main(float4 positon:POSITION,float4 color:COLOR,float2 texcoord:TEXCOORD)
{
    VS_OUT vout;
    vout.position = positon;
    vout.color = color;
    
    vout.texcoord = texcoord;
    
    return vout;
}