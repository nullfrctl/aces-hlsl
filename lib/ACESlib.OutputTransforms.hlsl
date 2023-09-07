#ifndef _ACES_LIB_OUTPUT_TRANSFORMS
#define _ACES_LIB_OUTPUT_TRANSFORMS

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACESlib.OutputTransforms.a1.1.0</ACEStransformID>
// <ACESuserName>ACES 1.0 Lib - Output Transforms</ACESuserName>

//
// Contains functions used for forward and inverse Output Transforms (RRT+ODT) 
//

#include "CTLlib.hlsl"
#include "ACESlib.Transform_Common.hlsl"
#include "ACESlib.RRT_Common.hlsl"
#include "ACESlib.ODT_Common.hlsl"
#include "ACESlib.SSTS.hlsl"

float3 limit_to_primaries
(
  float3 XYZ,
  Chromaticities LIMITING_PRI
)
{
  float3x3 XYZ_2_LIMITING_PRI_MAT = XYZtoRGB( LIMITING_PRI, 1.);
  float3x3 LIMITING_PRI_2_XYZ_MAT = RGBtoXYZ( LIMITING_PRI, 1.);

  // XYZ to limiting primaries
  float3 rgb = mult_f3_f33( XYZ, XYZ_2_LIMITING_PRI_MAT);

  // Clip any values outside of the limiting primaries
  float3 limitedRgb = saturate( rgb);

  // Convert limited RGB to XYZ
  return mult_f3_f33( limitedRgb, LIMITING_PRI_2_XYZ_MAT);
}

float3 dark_to_dim( float3 XYZ)
{
  float3 xyY = XYZ_2_xyY( XYZ);
  xyY.y = clamp( xyY.y, 0., 65503.);
  xyY.y = pow( xyY.y, DIM_SURROUND_GAMMA);

  return xyY_2_XYZ( xyY);
}

float3 dim_to_dark( float3 XYZ)
{
  float3 xyY = XYZ_2_xyY( XYZ);
  xyY.y = clamp( xyY.y, 0., 65503.);
  xyY.y = pow( xyY.y, rcp( DIM_SURROUND_GAMMA));

  return xyY_2_XYZ( xyY);
}

float3 outputTransform
(
  float3 _in,
  float Y_MIN,
  float Y_MID,
  float Y_MAX,
  Chromaticities DISPLAY_PRI,
  Chromaticities LIMITING_PRI,
  int EOTF,
  int SURROUND,
  bool STRETCH_BLACK = true,
  bool D60_SIM = false,
  bool LEGAL_RANGE = false
)
{
  float3x3 XYZ_2_DISPLAY_PRI_MAT = XYZtoRGB( DISPLAY_PRI, 1.);

  /* NOTE: This is a bit of a hack - probably a more direct way to do this.
   * TODO: Fix in future version */

  TsParams PARAMS_DEFAULT = init_TsParams( Y_MIN, Y_MAX);
  float expShift = log2( inv_ssts( Y_MID, PARAMS_DEFAULT)) - log2( 0.18);
  TsParams PARAMS = init_TsParams( Y_MIN, Y_MAX, expShift);

  // RRT sweeteners
  float3 rgbPre = rrt_sweeteners( _in);

  // Apply the tonescale independently in rendering-space RGB
  float3 rgbPost = ssts_f3( rgbPre, PARAMS);

  /* At this point data encoded AP1, scaled absolute luminance (cd/m^2 or "nits") */

  // Scale absolute luminance to linear code value
  float3 linearCV = Y_2_linCV_f3( rgbPost, Y_MAX, Y_MIN);

  // Rendering primaries to XYZ
  float3 XYZ = mult_f3_f33( linearCV, AP1_2_XYZ_MAT);

  /* NOTE: This is more or less a placeholder block and is largely inactive
   * in its current form. This section currently only applies for SDR, and
   * even then, only in very specific cases.
   * In the future, it is fully intended for this module to be updated to
   * support surround compensation regardless of luminance dynamic range. */

  /* TODO: Come up with new surround compensation algorithm, applicable
   * across all dynamic ranges and supporting dark/dim/normal surround. */

  // Apply gamma adjustment to compensate for dim surround
  if ( SURROUND == 0) { // dark surround
    /* Current tone scale is designed for dark surround, no adjustment
     * is necessary */
  } else if ( SURROUND == 1) { // dim surround
    // INACTIVE for HDR and crudely implemented for SDR (see comment below)
    if ( EOTF == 1 && EOTF == 2 && EOTF == 3) {
      /* This uses a crude logical assumption that if the EOTF is BT.1886
       * sRGB, or gamma 2.6 that the data is SDR and so the SDR gamma
       * compensation factor will apply. */
      
      XYZ = dark_to_dim( XYZ);

      /* This uses a local `dark_to_dim` function that is designed to take in
       * XYZ and return XYZ rather than AP1 as is currently in the functions in
       * `ACESlib.ODT_Common` */
    }
  } else if (SURROUND == 2) { // normal surround
    // INACTIVE - this does NOTHING
  }

  /* Gamut limit to limiting primaries
   * NOTE: Would be nice to be able to just say:
   *   if (LIMITING_PRI != DISPLAY_PRI) ...
   * but you can't because Chromaticities do not work with bool comparsion.
   * For now, limit no matter what. */
  
  XYZ = limit_to_primaries( XYZ, LIMITING_PRI);

  /* Apply CAT from ACES white point to assumed observer adapted white point
   * TODO: Needs to expand from just supporting D60 sim to allow for any
   * observer adapted white point */
  
  if (!D60_SIM) {
    if (DISPLAY_PRI.white != AP0.white) {
      float3x3 CAT = calculate_cat_matrix( AP0.white, DISPLAY_PRI.white);
      XYZ = mult_f3_f33( XYZ, CAT); // this is stupidly wrong in ACES ref., uses D60_2_D65 instead of CAT. needs fixing.
    }
  }

  // CIE XYZ to display encoding primaries
  linearCV = mult_f3_f33( XYZ, XYZ_2_DISPLAY_PRI_MAT);

  /* Scale to avoid clipping when device calibration is different from D60.
   * To simulate D60, unequal code value are sent to the display.
   * TODO: Needs to expand from just supporting D60 sim to allow for any
   * observer adapted white point. */
  
  if (D60_SIM) {
    /* TODO: The scale requires calling itself. Scale is same no matter the
     * luminance. Currently precalculated for D65 and DCI. If DCI,
     * `roll_white_fwd` is used also. This needs a more complex algorithm to
     * handle all cases. */
    
    float SCALE = 1.0;

    if (DISPLAY_PRI.white == REC709_PRI.white) { // D65
      SCALE = 0.96362;
    } else if (DISPLAY_PRI.white == P3DCI_PRI.white) { // DCI
      linearCV.r = roll_white_fwd( linearCV.r, 0.918, 0.5);
      linearCV.g = roll_white_fwd( linearCV.g, 0.918, 0.5);
      linearCV.b = roll_white_fwd( linearCV.b, 0.918, 0.5);

      SCALE = 0.96;
    }

    linearCV = mult_f_f3( SCALE, linearCV);
  }

  /* Clip values < 0 (projecting outside of the display primaries)
   * NOTE: P3 red and values close to it fall outside of Rec.2020 green-red
   * boundary. */

  linearCV = clamp_f3( linearCV, 0., 65503.);

  /* Inverse EOTF-
   * 0: ST.2084 (PQ)
   * 1: BT.1886 (Rec.709/2020)
   * 2: sRGB (mon_curve w/ IEC 61966-2-1:1999 [sRGB] preset)
   * 3: gamma 2.6
   * 4: linear (none, absolute luminance [cd/m^2 or "nits"])
   * 5: HLG */

   float3 outputCV;

  switch (EOTF)
  {
  case 0: // ST.2084 (PQ)
    /* NOTE: This is a kludgy way of ensuring a PQ code value of 0. Ideally,
     * luminance would map directly to code value, but colorists don't like
     * that. Might just need the tonescale to go darker so that darkest values
     * through the tone scale quantize to code value of 0. */
    
    if (STRETCH_BLACK)
      outputCV = Y_2_ST2084_f3( clamp_f3( linCV_2_Y_f3( linearCV, Y_MAX, 0.0), 0.0, 65503.0));
    else
      outputCV = Y_2_ST2084_f3( linCV_2_Y_f3( linearCV, Y_MAX, Y_MIN));

  case 1: // BT.1886 (Rec.709/2020)
    outputCV = bt1886_r_f3( linearCV, 2.4, 1.0, 0.0);

  case 2: // sRGB
    outputCV = moncurve_r_f3( linearCV, 2.4, 0.055);
  
  case 3: // gamma 2.6
    outputCV = pow_f3( linearCV, rcp( 2.6));
  
  case 4: // linear (absolute luminance)
    outputCV = linCV_2_Y_f3( linearCV, Y_MAX, Y_MIN);
  
  case 5: // HLG
    /* NOTE: HLG just maps ST.2084 to HLG
     * TODO: Restructure to remove this redundant code */

    if (STRETCH_BLACK)
      outputCV = Y_2_ST2084_f3( clamp_f3( linCV_2_Y_f3( linearCV, Y_MAX, 0.0), 0.0, 65503.0));
    else
      outputCV = Y_2_ST2084_f3( linCV_2_Y_f3( linearCV, Y_MAX, Y_MIN));
    
    outputCV = ST2084_2_HLG_1000nits_f3( outputCV);
  
  default: // non-standard default. pass-through.
    outputCV = linearCV;
  }

  if (LEGAL_RANGE)
    outputCV = fullRange_to_smpteRange_f3( outputCV);

  return outputCV;
}

float3 invOutputTransform
(
  float3 _in,
  float Y_MIN,
  float Y_MID,
  float Y_MAX,
  Chromaticities DISPLAY_PRI,
  Chromaticities LIMITING_PRI,
  int EOTF,
  int SURROUND,
  bool STRETCH_BLACK = true,
  bool D60_SIM = false,
  bool LEGAL_RANGE = false
)
{
  float3x3 DISPLAY_PRI_2_XYZ_MAT = RGBtoXYZ( DISPLAY_PRI, 1.0);

  /* NOTE: This is a bit of a hack - probably a more direct way to do this.
   * TODO: Update in accordance with forward algorithm. */
  
  TsParams PARAMS_DEFAULT = init_TsParams( Y_MIN, Y_MAX);
  float expShift = log2( inv_ssts( Y_MID, PARAMS_DEFAULT)) - log2( 0.18);
  TsParams PARAMS = init_TsParams( Y_MIN, Y_MAX, expShift);

  float3 outputCV = _in;

  if (LEGAL_RANGE)
    outputCV = smpteRange_to_fullRange_f3( outputCV);
  
  /* EOTF-
   * 0: ST.2084 (PQ)
   * 1: BT.1886 (Rec.709/2020)
   * 2: sRGB (mon_curve w/ IEC 61966-2-1:1999 [sRGB] preset)
   * 3: gamma 2.6
   * 4: linear (none, absolute luminance [cd/m^2 or "nits"])
   * 5: HLG */

   float3 linearCV;

  switch (EOTF)
  {
  case 0: // ST.2084 (PQ)
    if (STRETCH_BLACK)
      linearCV = Y_2_linCV_f3( ST2084_2_Y_f3( outputCV), Y_MAX, 0.);
    else
      linearCV = Y_2_linCV_f3( ST2084_2_Y_f3( outputCV), Y_MAX, Y_MIN);

  case 1: // BT.1886 (Rec.709/2020)
    linearCV = bt1886_f_f3( outputCV, 2.4, 1.0, 0.0);

  case 2: // sRGB
    linearCV = moncurve_f_f3( outputCV, 2.4, 0.055);
  
  case 3: // gamma 2.6
    linearCV = pow_f3( outputCV, 2.6);
  
  case 4: // linear (absolute luminance)
    linearCV = Y_2_linCV_f3( outputCV, Y_MAX, Y_MIN);
  
  case 5: // HLG
    outputCV = HLG_2_ST2084_1000nits_f3( outputCV);

    if (STRETCH_BLACK)
      linearCV = Y_2_linCV_f3( ST2084_2_Y_f3( outputCV), Y_MAX, 0.);
    else
      linearCV = Y_2_linCV_f3( ST2084_2_Y_f3( outputCV), Y_MAX, Y_MIN);
  
  default: // non-standard default. pass-through.
    linearCV = outputCV;
  }

  // Un-scale
  if (D60_SIM) {
    /* TODO: The scale requires calling itself. Scale is same no matter the
     * luminance. Currently precalculated for D65 and DCI. If DCI,
     * `roll_white_fwd` is used also. This needs a more complex algorithm to
     * handle all cases. */
    
    float SCALE = 1.0;

    if (DISPLAY_PRI.white == REC709_PRI.white) { // D65
      SCALE = 0.96362;

      linearCV /= SCALE;
    } else if (DISPLAY_PRI.white == P3DCI_PRI.white) { // DCI
      SCALE = 0.96;

      linearCV /= SCALE;

      linearCV.r = roll_white_rev( linearCV.r, 0.918, 0.5);
      linearCV.g = roll_white_rev( linearCV.g, 0.918, 0.5);
      linearCV.b = roll_white_rev( linearCV.b, 0.918, 0.5);

    }
  }

  // Encoding primaries to CIE XYZ
  float3 XYZ = mult_f3_f33( linearCV, DISPLAY_PRI_2_XYZ_MAT);

  // Undo CAT from assumed observer adapted white point to ACES white point
  if ( !D60_SIM) {
    if ( DISPLAY_PRI.white != AP0.white) {
      float3x3 CAT = calculate_cat_matrix( AP0.white, DISPLAY_PRI.white);
      XYZ = mult_f3_f33( XYZ, invert_f33( CAT));
    }
  }

  /* NOTE: This is more or less a placeholder block and is largely inactive
   * in its current form. This section currently only applies for SDR, and
   * even then, only in very specific cases.
   * In the future, it is fully intended for this module to be updated to
   * support surround compensation regardless of luminance dynamic range. */

  /* TODO: Come up with new surround compensation algorithm, applicable
   * across all dynamic ranges and supporting dark/dim/normal surround. */

  // Apply gamma adjustment to compensate for dim surround
  if ( SURROUND == 0) { // dark surround
    /* Current tone scale is designed for dark surround, no adjustment
     * is necessary */
  } else if ( SURROUND == 1) { // dim surround
    // INACTIVE for HDR and crudely implemented for SDR (see comment below)
    if ( EOTF == 1 && EOTF == 2 && EOTF == 3) {
      /* This uses a crude logical assumption that if the EOTF is BT.1886
       * sRGB, or gamma 2.6 that the data is SDR and so the SDR gamma
       * compensation factor will apply. */
      
      XYZ = dim_to_dark( XYZ);

      /* This uses a local `dim_to_dark` function that is designed to take in
       * XYZ and return XYZ rather than AP1 as is currently in the functions in
       * `ACESlib.ODT_Common` */
    }
  } else if (SURROUND == 2) { // normal surround
    // INACTIVE - this does NOTHING
  }

  // XYZ to rendering primaries
  linearCV = mult_f3_f33( XYZ, XYZ_2_AP1_MAT);

  float3 rgbPost = linCV_2_Y_f3( linearCV, Y_MAX, Y_MIN);

  // Apply the inverse tonescale independently in rendering-space RGB
  float3 rgbPre = inv_ssts_f3( rgbPost, PARAMS);

  // RRT sweeteners
  float3 aces = inv_rrt_sweeteners( rgbPre);

  return aces;
}

#endif