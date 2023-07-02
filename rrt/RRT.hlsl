#ifndef _ACES_RRT
#define _ACES_RRT

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:RRT.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 - RRT</ACESuserName>

// 
// Reference Rendering Transform (RRT)
//
//   Input is ACES
//   Output is OCES
//

#include "../lib/ACESlib.Utilities.hlsl"
#include "../lib/ACESlib.Transform_Common.hlsl"
#include "../lib/ACESlib.RRT_Common.hlsl"
#include "../lib/ACESlib.Tonescales.hlsl"

float3 RRT( float3 aces)
{
  /*
  // --- Glow module --- //
  float saturation = rgb_2_saturation( aces);
  float ycIn = rgb_2_yc( aces);
  float s = sigmoid_shaper( (saturation - 0.4) * 0.5);
  float addedGlow = 1. + glow_fwd( ycIn, RRT_GLOW_GAIN *s, RRT_GLOW_MID);

  aces = mult_f_f3( addedGlow, aces);

  // --- Red modifier --- //
  float hue = rgb_2_hue( aces);
  float centeredHue = center_hue( hue, RRT_RED_HUE);
  float hueWeight = cubic_basis_shaper( centeredHue, RRT_RED_WIDTH);

  aces.r += hueWeight * saturation * ( RRT_RED_PIVOT - aces.r) * (1. - RRT_RED_SCALE);

  // --- ACES to RGB rendering space --- //
  aces = clamp_f3( aces, 0., 65504.);
  
  float3 rgbPre = mult_f3_f33( aces, AP0_2_AP1_MAT);
  rgbPre = clamp_f3( rgbPre, 0., 65504.);

  // --- Global desaturation --- //
  rgbPre = mult_f3_f33( rgbPre, RRT_SAT_MAT);
  */

  float3 rgbPre = rrt_sweeteners( aces);

  // --- Apply the tonescale independently in rendering-space RGB --- //
  float3 rgbPost;
  rgbPost.r = segmented_spline_c5_fwd( rgbPre.r);
  rgbPost.g = segmented_spline_c5_fwd( rgbPre.g);
  rgbPost.b = segmented_spline_c5_fwd( rgbPre.b);

  // --- RGB rendering space to OCES --- //
  float3 rgbOces = mult_f3_f33( rgbPost, AP1_2_AP0_MAT);

  return rgbOces;
}

#endif // _ACES_RRT