#include "environment_mapping_shader.hlsli"

Texture2D color_map : register(t0);
SamplerState color_sampler_state : register(s0);

Texture2D environment_map : register(t3);

float4 main(VS_OUT pin) : SV_TARGET
{
   
    float4 diffuse_color = color_map.Sample(color_sampler_state, pin.texcoord); //モデルのテクスチャから基本の色を取得
    
    float3 E = normalize(pin.world_position.xyz - camera_position.xyz); //カメラからピクセルへの視線ベクトルを計算
    float3 N = normalize(pin.world_normal.xyz); //ピクセルの法線ベクトルを正規化
    float4 color = diffuse_color;
    
    /*
    球体環境マッピング関数を呼び出して、
    法線 N と視線 E から反射ベクトルを求め、
    environment_mapを使って反射して見える色をサンプリング
    */
    color.rgb = CalcSphereEnvironment(environment_map, color_sampler_state,
                color.rgb, N, E, environment_value);
    
    return color;
}