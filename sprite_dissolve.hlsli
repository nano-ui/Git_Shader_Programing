struct VS_OUT
{
    float4 position : SV_POSITION; //頂点の位置情報
    float4 color : COLOR; //頂点カラー
    float2 texcoord : TEXCOORD; //テクスチャ座標（UV座標）
};

//定数バッファ（Constant Buffer）を定義
cbuffer SCENE_CONSTANT_BUFFER : register(b1)
{
    row_major float4x4 view_projection; //ワールド→ビュー→プロジェクション変換
    float4 options; //追加パラメータ用の自由な4つの値
}

cbuffer DISSOLVE_CONSTANT_BUFFER : register(b3)
{
    float4 parameters; //x : ディゾルブ適応量、yzw : 空き
}