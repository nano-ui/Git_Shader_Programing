#ifndef SHADING_FUNCTIONS_INCLUDED
#define SHADING_FUNCTIONS_INCLUDED

//--------------------------------------------
//	ランバート拡散反射計算関数
//--------------------------------------------
// N:法線(正規化済み)
// L:入射ベクトル(正規化済み)
// C:入射光(色・強さ)
// K:反射率

float3 CalcLambert(float3 N, float3 L, float3 C, float3 K)
{
    
    float power = saturate( //値を 0?1 の範囲に制限
    dot(N, -L) //光の当たり具合（角度） を表す内積
    );
    return C * power * K; //最終的な見た目の明るさ（色）を計算
}

//--------------------------------------------
//	フォンの鏡面反射計算関数
//--------------------------------------------
// N:法線(正規化済み)
// L:入射ベクトル(正規化済み)
// E:視線ベクトル(正規化済み)
// C:入射光(色・強さ)
// K:反射率

float3 CalcPhongSpecular(float3 N, float3 L, float3 E, float3 C, float3 K)
{
    float3 R = reflect(L, N); //光ベクトル L が法線 N に当たって跳ね返る方向（R)を計算
    float power = max( //反射しない部分を暗くする=負の値
    dot(-E, R), //カメラの方向（視線） と 反射方向 の角度を求める
    0);
    
    power = pow(power, 128);
    
    return C * power * K; //最終的な反射の色（ハイライトの色）を出す
}

//--------------------------------------------
//	ハーフランバート拡散反射計算関数
//--------------------------------------------
// N:法線(正規化済み)
// L:入射ベクトル(正規化済み)
// C:入射光(色・強さ)
// K:反射率

float3 ClacHalfLambert(float3 N, float3 L, float3 C, float3 K)
{
    /*
     saturate(...)
     過剰な明るさや負の値を防ぐ     
     dot(N, -L)
     光の当たり具合を求める  
     * 0.5f + 0.5f
     裏側でも「完全な0」にはならず、少し光が回り込むような効果
    */
    float D = saturate(dot(N, -L) * 0.5f + 0.5f);
    return C * D * K; //光の色 C × 当たり具合 D × 材質の反射率 Kで、最終的な色を求める
}

/*リムライト

  N:法線(正規化済み)
  E:視点方向ベクトル(正規化済み)
  L:入射ベクトル(正規化済み)
  C:ライト色
  RimPower:リムライトの強さ(初期値はテキトーなので自分で設定するが吉)
*/

float3 CalcRimLight(float3 N,float3 E,float3 L,float3 C,float RimPower = 3.0f)
{
    /*
        dot(N, -E)は表面カメラをどのくらい向いているか
        1.0-dot(...)で正面では暗く、輪郭ほど明るくする
        saturate()で範囲を[0,1]に制限
    */
    float rim = 1.0f - saturate(dot(N, -E));
    
    /*
        pow(rim, RimPower)
        rimの値をべき乗して、リムの鋭さを調整
        saturate(dot(L,-E))
        視点とライトの位置関係で強さが変わるように調整
        return ...
        最終的なリムライトの色を返す
    */
    return C * pow(rim, RimPower) * saturate(dot(L, -E));
}

/*
    ランプシェーディング

    tex:ランプシェーディング用テクスチャ
    samp:ランプシェーディング用サンプラーステイト
    N:法線(正規化済み)
    L:入射ベクトル(正規化済み)
    C:入射光(色・強さ)
    K:反射率
*/

float3 CalcRampShading(Texture2D tex,SamplerState samp,float3 N,float3 L,float3 C,float3 K)
{
    /*
     saturate(...)
     過剰な明るさや負の値を防ぐ     
     dot(N, -L)
     光の当たり具合を求める  
     * 0.5f + 0.5f
     裏側でも「完全な0」にはならず、少し光が回り込むような効果
    */
    float D = saturate(dot(N, -L) * 0.5f + 0.5f);
    
    /*
    tex.Sample(samp,・・・)
    トゥーンシェーディング用のランプテクスチャを読み取る
    float2(D, 0.5f)
    光の強さ（D値）を横軸にして、どんな色にするかを指定する
    .rは赤チャンネル(モノクロ強度)を取り出している
    */
    float Ramp = tex.Sample(samp, float2(D, 0.5f)).r;
    return C * Ramp * K.rgb;//色を適用して出力
}

//球体環境マッピング
/*
tex     :ランプシェーディング用テクスチャ
samp    :ランプシェーディング用サンプラーステート
color   :現在のピクセル色
N       :法線(正規化済み)
C       :入射光(正規化済み)
value   :適応率
*/
float3 CalcSphereEnvironment(Texture2D tex,SamplerState samp,in float3 color,float3 N,float3 E,float value)
{
    float3 R = reflect(E, N);//反射ベクトルを計算
    float2 texcoord = R.xy * 0.5f + 0.5f;//反射ベクトルを2Dテクスチャ座標に変換
    
    /*
    tex.Sample(samp, texcoord).rgb
    テクスチャから反射色を取得
    lerp(color.rgb, tex.Sample(samp, texcoord).rgb, value)
    元の色と反射色をブレンド
    */
    return lerp(color.rgb, tex.Sample(samp, texcoord).rgb, value);
}

//半球ライティング
/*
normal             :法線(正規化済み)
up                 :上方向(片方)
sky_color          :空の色
ground_color       :地面の色
hemisphere_weight  :空と地面の影響度
*/
float3 CalcHemiSphereLight(float3 normal,float3 up,float3 sky_color,float3 ground_color,float4 hemisphere_weight)
{
    float factor = dot(normal, up) * 0.5f + 0.5f;
    return lerp(ground_color, sky_color, factor) * hemisphere_weight.x;
}

//フォグ
/*
color       :現在のピクセル
fog_color   :フォグの色
fog_range   :フォグからの範囲情報
eye_length  :視点からの距離
*/
float4 CalFog(in float4 color,float4 fog_color,float2 fog_range,float eye_length)
{
    float fogAlpha = saturate((eye_length - fog_range.x) / (fog_range.y - fog_range.x));
    return lerp(color, fog_color, fogAlpha);
}


#endif