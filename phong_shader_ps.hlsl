#include "phong_shader.hlsli"
#include "shading_functions.hlsli"

//テクスチャとサンプラーの宣言
Texture2D color_map : register(t0);
SamplerState color_sampler_state : register(s0);
Texture2D normal_map : register(t1);

float4 main(VS_OUT pin) : SV_TARGET
{
    float4 diffuse_color = color_map.Sample(color_sampler_state, pin.texcoord); //クスチャ（画像）からUV座標を使って色を取得
    
    //向きベクトルの計算
    float3 E = normalize(pin.world_position.xyz - camera_position.xyz);
    float3 L = normalize(directional_light_direction.xyz);
    //float3 N = normalize(pin.world_normal.xyz);
    float3x3 mat = { normalize(pin.tangent), normalize(pin.binormal), normalize(pin.normal) };
    float3 N = normal_map.Sample(color_sampler_state, pin.texcoord).rgb;
    //ノーマルテクスチャ法線をワールドへ変換
    N = normalize(mul(N * 2.0f - 1.0f, mat));
    
    float3 ambient = ambient_color.rgb * ka.rgb; //環境光
    
    
    //float3 directional_diffuse = CalcLambert(N, L, directional_light_color.rgb, kd.rgb);
    float3 directional_diffuse = ClacHalfLambert(N, L, directional_light_color.rgb, kd.rgb);
   
    float3 directional_specular = CalcPhongSpecular(N, L, E, directional_light_color.rgb, ks.rgb);
    float3 rim_color = CalcRimLight(N, E, L, directional_light_color.rgb);
    
    //色の合成
    float4 color = float4(diffuse_color.rgb * (ambient + directional_diffuse), diffuse_color.a);
    color.rgb += directional_specular;
    color.rgb += rim_color;
    
    return color;
}