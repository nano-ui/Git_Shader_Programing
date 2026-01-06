#include "filter_functions.hlsli"

struct VS_OUT
{
    float4 position : SV_POSITION;
    float4 color : COLOR;
    float2 texcoord : TEXCOORD;
};

cbuffer COLOR_FILTER : register(b4)
{
    float hue_shift;    //РFН╩Т▓Ро
    float saturation;   //Н╩УxТ▓Ро
    float brightness;   //Ц╛УxТ▓Ро
    float dummy;
}
