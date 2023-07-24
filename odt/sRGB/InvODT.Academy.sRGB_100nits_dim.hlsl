#ifndef _ACES_InvODT_sRGB_100nits_DIM
#define _ACES_InvODT_sRGB_100nits_DIM

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:InvODT.Academy.RGBmonitor_100nits_dim.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Inverse Output - sRGB</ACESuserName>

// 
// Inverse Output Device Transform - RGB computer monitor
//

#include "../../lib/ACESlib.Utilities.hlsl"
#include "../../lib/ACESlib.Transform_Common.hlsl"
#include "../../lib/ACESlib.ODT_Common.hlsl"
#include "../../lib/ACESlib.Tonescales.hlsl"

/* --- ODT Parameters --- */
#ifndef __RESHADE__
static const Chromaticities DISPLAY_PRI = REC709_PRI;
static const float3x3 DISPLAY_PRI_2_XYZ_MAT = RGBtoXYZ( DISPLAY_PRI, 1.0);
#else
#define DISPLAY_PRI REC709_PRI
#define DISPLAY_PRI_2_XYZ_MAT RGBtoXYZ( DISPLAY_PRI, 1.0)
#endif

static const float DISPGAMMA = 2.4; 
static const float OFFSET = 0.055;

float3 InvODT_RGB_monitor( float3 outputCV)
{
  // Decode to linear code values with inverse transfer function
  float3 linearCV = moncurve_f_f3( outputCV, DISPGAMMA, OFFSET);

  // Convert from display primary encoding
  // Display primaries to CIE XYZ
  float3 XYZ = mult_f3_f33( linearCV, DISPLAY_PRI_2_XYZ_MAT);

  // Apply CAT from assumed observer adapted white to ACES white point
  XYZ = mult_f3_f33( XYZ, invert_f33( D60_2_D65_CAT));

  // CIE XYZ to rendering space RGB
  linearCV = mult_f3_f33( XYZ, XYZ_2_AP1_MAT);

  // Undo desaturation to compensate for luminance difference
  linearCV = mult_f3_f33( linearCV, invert_f33( ODT_SAT_MAT));

  // Undo gamma adjustment to compensate for dim surround
  linearCV = dimSurround_to_darkSurround( linearCV);

  // Scale linear code value to luminance
  float3 rgbPre;
  rgbPre.r = linCV_2_Y( linearCV.r, CINEMA_WHITE, CINEMA_BLACK);
  rgbPre.g = linCV_2_Y( linearCV.g, CINEMA_WHITE, CINEMA_BLACK);
  rgbPre.b = linCV_2_Y( linearCV.b, CINEMA_WHITE, CINEMA_BLACK);

  // Apply the tonescale independently in rendering-space RGB
  float3 rgbPost;
  rgbPost.r = segmented_spline_c9_rev( rgbPre.r);
  rgbPost.g = segmented_spline_c9_rev( rgbPre.g);
  rgbPost.b = segmented_spline_c9_rev( rgbPre.b);

  // Rendering space RGB to OCES
  float3 oces = mult_f3_f33( rgbPost, AP1_2_AP0_MAT);
  return oces;
}

#undef DISPLAY_PRI
#undef DISPLAY_PRI_2_XYZ_MAT

#endif // _ACES_ODT_sRGB_100nits_DIM