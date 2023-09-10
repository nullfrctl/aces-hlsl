// ACES test file

#include "ReShade.fxh"
#include "csc/ACEScct/ACEScsc.Academy.ACES_to_ACEScct.fxh"
#include "csc/ACEScct/ACEScsc.Academy.ACEScct_to_ACES.fxh"
#include "lib/ACESlib.ODT_Common.fxh"
#include "lib/ACESlib.OutputTransforms.fxh"
#include "lib/ACESlib.RRT_Common.fxh"
#include "lib/ACESlib.SSTS.fxh"
#include "lib/ACESlib.Tonescales.fxh"
#include "lib/ACESlib.Transform_Common.fxh"
#include "lib/ACESlib.Utilities.fxh"
#include "lib/ACESlib.Utilities_Color.fxh"

uniform float3 PARAMS_IN < ui_label = "In params (min, mid, max)";
ui_type = "drag";
ui_min = float3(0.001, 1.0, 4000.0);
> = float3(0.02, 4.8, 48.0);

uniform float3 PARAMS_OUT < ui_label = "Out params (min, mid, max)";
ui_type = "drag";
ui_min = float3(0.001, 1.0, 4000.0);
> = float3(0.02, 4.8, 48.0);

uniform bool D60_SIM < ui_label = "Output D60 sim.";
> = true;

uniform bool LEGAL_RANGE < ui_label = "SMPTE range";
> = false;

uniform bool GAIN < ui_label = "Output grey correction";
> = false;

uniform float EXPOSURE < ui_label = "Exposure (EV)";
ui_type = "drag";
> = 0.0;

uniform float SATURATION < ui_label = "Saturation";
ui_type = "drag";
ui_min = 0.0;
> = 1.0;

struct VSInfo {
  float4 position : SV_POSITION;
  float2 texcoord : TEXCOORD;
};

void main_PS(in VSInfo v, out float4 c : SV_TARGET) {
  float3 outputCV;
  outputCV = tex2D(ReShade::BackBuffer, v.texcoord.xy).rgb;

  float3 aces;
  aces = invOutputTransform(outputCV, PARAMS_IN[0], PARAMS_IN[1], PARAMS_IN[2],
                            REC709_PRI, REC709_PRI, 2, 1, true, false, false);

  aces *= exp2(EXPOSURE);

  {
    float3 acescct;

    acescct = ACES_to_ACEScct(aces);

    float luma = dot(acescct, AP1_RGB2Y);
    acescct = lerp(luma, acescct, SATURATION);

    aces = ACEScct_to_ACES(acescct);
  }

  outputCV =
      outputTransform(aces, PARAMS_OUT[0], PARAMS_OUT[1], PARAMS_OUT[2],
                      REC709_PRI, REC709_PRI, 2, 1, true, D60_SIM, LEGAL_RANGE);

  c.rgb = outputCV;
  c.a = 1.0;
}

technique ACEStest < ui_label = "ACEStest";
> {
  pass {
    PixelShader = main_PS;
    VertexShader = PostProcessVS;
  }
}