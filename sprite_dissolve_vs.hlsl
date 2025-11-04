#include "sprite_dissolve.hlsli"

VS_OUT main(float4 position : POSITION, float4 color : COLOR, float2 texcoord : TEXCOORD)
{
    VS_OUT vout;
    vout.position = position; //頂点座標を設定
    vout.color = color; //頂点カラーを設定
    vout.texcoord = texcoord; //テクスチャ座標を設定
    return vout; //出力データを返す
}
