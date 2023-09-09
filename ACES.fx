// ACES test file

#include "ReShade.fxh"
#include "lib/ACESlib.Utilities.fxh"
#include "lib/ACESlib.Utilities_Color.fxh"
#include "lib/ACESlib.Transform_Common.fxh"
#include "lib/ACESlib.ODT_Common.fxh"
#include "lib/ACESlib.RRT_Common.fxh"
#include "lib/ACESlib.Tonescales.fxh"
#include "lib/ACESlib.SSTS.fxh"
#include "lib/ACESlib.OutputTransforms.fxh"

uniform bool sRGB < ui_label = "correct for sRGB";
> = true;

uniform bool ACES < ui_label = "go to ACES";
> = true;

uniform float ADD_AMOUNT < ui_label = "amount to add";
ui_type = "drag";
> = 0.0;

void PS_main(in float4 position
             : SV_Position, in float2 texcoord
             : TEXCOORD, out float3 c
             : SV_Target) {
  c = tex2D(ReShade::BackBuffer, texcoord.xy).rgb;

  float3 aces;
  aces = invOutputTransform(c, 0.0001, 18.0, 100.0, REC709_PRI, REC709_PRI, 2, 1, true, false, false);
  aces += ADD_AMOUNT;
  c = outputTransform(aces, 0.02, 4.8, 48.0, REC709_PRI, REC709_PRI, 2, 1, true, true, false);
}

technique ACEStest < ui_label = "ACEStest";
> {
  pass {
    PixelShader = PS_main;
    VertexShader = PostProcessVS;
  }
}