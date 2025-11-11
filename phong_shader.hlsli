//頂点シェーダーの出力構造
struct VS_OUT
{
    float4 position : SV_POSITION; //クリップ空間の座標
    float4 world_position : POSITION; //頂点のワールド座標
    //float4 world_normal : NORMAL; //頂点の法線ベクトル
    float3 tangent : TANGENT;//接線ベクトル
    float3 binormal : BINORMAL;//従法線ベクトル
    float3 normal : NORMAL; //法線ベクトル
    float2 texcoord : TEXCOORD; //頂点のUV座標
};

//各オブジェクト固有の情報をまとめた定数バッファ
cbuffer OBJECT_CONSTANT_BUFFER : register(b0)
{
    row_major float4x4 world; //モデル行列
    float4 ka; //環境反射色
    float4 kd; //拡散反射色
    float4 ks; //鏡面反射色
};

//シーン全体の情報
cbuffer SCENE_CONSTANT_BUFFER : register(b1)
{
    row_major float4x4 view_projection; //ビュー行列×プロジェクション行列
    float4 options; //任意の追加オプション
    float4 camera_position; //カメラのワールド座標位置
};

//光源の設定
cbuffer LIGHT_CONSTANT_BUFFER : register(b2)
{
    float4 ambient_color; //環境光
    float4 directional_light_direction; //平行光の方向
    float4 directional_light_color; //平行光の色
};

//半球ライト
cbuffer HEMISPHERE_LIGHT_CONSTNT_BUFFER : register(b4)
{
    float4 sky_color;           //空の色
    float4 groud_color;          //地面の色
    float4 hemisphere_weight;    //空と地面の影響度
};

cbuffer FOG_CONSTANT_BUFFER : register(b5)
{
    
}

#include "shading_functions.hlsli"