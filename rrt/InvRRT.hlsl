#ifndef _ACES_InvRRT
#define _ACES_InvRRT

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:InvRRT.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 - Inverse RRT</ACESuserName>

// 
// Inverse Reference Rendering Transform (RRT)
//
//   Input is OCES
//   Output is ACES
//

#include "../lib/ACESlib.Utilities.hlsl"
#include "../lib/ACESlib.Transform_Common.hlsl"
#include "../lib/ACESlib.RRT_Common.hlsl"
#include "../lib/ACESlib.Tonescales.hlsl"

float3 InvRRT( float3 oces)
{

  // --- OCES to RGB rendering space --- //
  float3 rgbPre = mult_f3_f33( oces, AP0_2_AP1_MAT);

  // --- Apply the tonescale independently in rendering-space RGB --- //
  float3 rgbPost;
  rgbPost.r = segmented_spline_c5_rev( rgbPre.r);
  rgbPost.g = segmented_spline_c5_rev( rgbPre.g);
  rgbPost.b = segmented_spline_c5_rev( rgbPre.b);

	// --- Global desaturation --- //
	rgbPost = mult_f3_f33( rgbPost, invert_f33(RRT_SAT_MAT));
	rgbPost = clamp_f3( rgbPost, 0., 65504.);

	// --- RGB rendering space to ACES --- //
	float3 aces = mult_f3_f33( rgbPost, AP1_2_AP0_MAT);
	aces = clamp_f3( aces, 0., 65504.);

	// --- Red modifier --- //
	float hue = rgb_2_hue( aces);
	float centeredHue = center_hue( hue, RRT_RED_HUE);
	float hueWeight = cubic_basis_shaper( centeredHue, RRT_RED_WIDTH);

	float minChan;
	if (centeredHue < 0) {
		minChan = aces.g;
	} else {
		minChan = aces.b;
	}

	float a = hueWeight* (1. - RRT_RED_SCALE) - 1.;
	float b = aces.r - hueWeight * (RRT_RED_PIVOT + minChan) * (1. - RRT_RED_SCALE);
	float c = hueWeight * RRT_RED_PIVOT * minChan * (1. - RRT_RED_SCALE);

	aces.r = ( -b - sqrt( b * b - 4. * a * c)) / ( 2. * a);

	// --- Glow module --- //
	float saturation = rgb_2_saturation( aces);
	float ycOut = rgb_2_yc( aces);
	float s = sigmoid_shaper( ( saturation - 0.4) / 0.2);
	float reducedGlow = 1. + glow_inv( ycOut, RRT_GLOW_GAIN *s, RRT_GLOW_MID);

	aces = mult_f_f3( ( reducedGlow), aces);

	return aces;
}

#endif // _ACES_RRT