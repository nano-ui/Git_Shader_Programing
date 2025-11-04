#include "phong_shader.hlsli"

VS_OUT main(
float4 position : POSITION,
float4 normal : NORMAL,
float2 texcoord : TEXCOORD)
{
    VS_OUT vont = (VS_OUT) 0; //出力構造体 VS_OUT の初期化
    float4 world_position = mul(float4(position.xyz, 1), world); //モデル空間の頂点を「ワールド座標系」に変換
    vont.position = mul(world_position, view_projection); //ワールド座標を「ビュー行列×射影行列」で変換し、画面上の位置に変換
    //vont.world_normal = normalize(mul(float4(normal.xyz, 0), world)); //法線ベクトルをワールド空間へ変換して正規化
    
    ////簡易接空間三軸算出方法
    //float3 vN = wN;//ワールド法線
    //float3 vB = { 0, 1, -0.001f };//ワールド上方向
    //float3 vT;
    //vB = normalize(vB);
    //vT = normalize(cross(vT, vN));
    //vB = normalize(cross(vN, vT));
    
    vont.normal = normalize(mul(float4(normal.xyz, 0), world)).xyz;
    vont.binormal = float3(0.0f, 1.0f, 0.001f);//仮の上ベクトル
    vont.binormal = normalize(vont.binormal);
    vont.tangent = normalize(cross(vont.binormal, vont.normal));//外積
    vont.binormal = normalize(cross(vont.binormal, vont.tangent));
    vont.world_position = world_position;
    vont.texcoord = texcoord; //UV座標をそのままピクセルシェーダーに渡す
    return vont;
}