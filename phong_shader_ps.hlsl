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
    ambient += CalcHemiSphereLight(N, float3(0, 1, 0), sky_color.rgb, groud_color.rgb, hemisphere_weight);
    
    //float3 directional_diffuse = CalcLambert(N, L, directional_light_color.rgb, kd.rgb);
    float3 directional_diffuse = ClacHalfLambert(N, L, directional_light_color.rgb, kd.rgb);
   
    float3 directional_specular = CalcPhongSpecular(N, L, E, directional_light_color.rgb, ks.rgb);
    
    float3 rim_color = CalcRimLight(N, E, L, directional_light_color.rgb);
    
    //点光源の処理
    float3 point_diffuse = 0.0f;
    float3 point_specular = 0.0f;
    for (int i = 0; i < 8;i++)
    {
        float3 LP = pin.world_position.xyz - point_light[i].position.xyz;
        float len = length(LP);
        if (len >= point_light[i].range)
            continue;
        float attenuate_length = saturate(1.0f - len / point_light[i].range);
        float attenuation = attenuate_length * attenuate_length;
        LP /= len;
        point_diffuse += CalcLambert(N, LP, point_light[i].color.rgb, kd.rgb) * attenuation;
        point_specular += CalcPhongSpecular(N, LP, E, point_light[i].color.rgb, ks.rgb) * attenuation;
    }
    
    //スポットライトの処理
    float3 spot_diffuse = 0.0f;
    float3 spot_specular = 0.0f;
    for (int j = 0; j < 8; j++)
    {
        float3 LP = pin.world_position.xyz - spot_light[j].position.xyz;
        float len = length(LP);
        if (len >= spot_light[j].range)
            continue;
        float attenuate_length = saturate(1.0f - len / spot_light[j].range);
        float attenuation = attenuate_length * attenuate_length;
        LP /= len;
        float3 spot_direction = normalize(spot_light[j].direction.xyz);
        float angle = dot(spot_direction, -LP);
        float area = spot_light[j].inner_corn - spot_light[j].outer_corn;
        attenuation *= saturate(1.0f - (spot_light[j].inner_corn - angle) / area);
        spot_diffuse += CalcLambert(N, LP, spot_light[j].color.rgb, kd.rgb) * attenuation;
        spot_specular += CalcPhongSpecular(N, LP, E, spot_light[j].color.rgb, ks.rgb) * attenuation;
    }
      
    //色の合成
    float4 color = float4(diffuse_color.rgb * (ambient + directional_diffuse + point_diffuse + spot_diffuse), diffuse_color.a);
    color.rgb += directional_specular + spot_specular + point_specular;
    color.rgb += rim_color;
    color = CalFog(color, fog_color, fog_range.xy, length(pin.world_position.xyz - camera_position.xyz));
    
    return color;
}