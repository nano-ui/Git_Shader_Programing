#include "sprite_dissolve.hlsli"

Texture2D color_map : register(t0); //スプライトのカラー用テクスチャを定義
SamplerState color_sampler_state : register(s0); //テクスチャをサンプリング（読み取る）ときの補間や繰り返し設定を指定
Texture2D mask_texture : register(t1); //ディゾルブ用マスクテクスチャを定義

float4 main(VS_OUT pin) : SV_TARGET
{
    float4 color = color_map.Sample(color_sampler_state, pin.texcoord) * pin.color; //基本の色を決定
    float mask_value = mask_texture.Sample(color_sampler_state, pin.texcoord); //溶け具合を決める
    //color.a *= mask_value; //透明度を変化させる
    float alpha = step(parameters.x, mask_value);
    color.a *= alpha;
    return color; //画面に描画
}
