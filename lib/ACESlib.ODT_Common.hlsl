#ifndef _ACES_LIB_ODT_COMMON
#define _ACES_LIB_ODT_COMMON

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACESlib.ODT_Common.a1.1.0</ACEStransformID>
// <ACESuserName>ACES 1.0 Lib - ODT Common</ACESuserName>

//
// Contains functions and constants shared by forward and inverse ODT transforms 
//

#include "CTLlib.hlsl"
#include "ACESlib.Utilities.hlsl"
#include "ACESlib.Utilities_Color.hlsl"
#include "ACESlib.Transform_Common.hlsl"

// Target white and black points for cinema system tonescale
static const float CINEMA_WHITE = 48.;
#ifndef __RESHADE__
static const float CINEMA_BLACK = pow10( log10( 0.02)); // CINEMA_WHITE / 2400. 
#else
#define CINEMA_BLACK pow10( log10( 0.02))
#endif

// CINEMA_BLACK is defined in this roundabout manner in order to be exactly equal to 
// the result returned by the cinema 48-nit ODT tonescale.
// Though the min point of the tonescale is designed to return 0.02, the tonescale is 
// applied in log-log space, which loses precision on the antilog. The tonescale 
// return value is passed into Y_2_linCV, where CINEMA_BLACK is subtracted. If 
// CINEMA_BLACK is defined as simply 0.02, then the return value of this subfunction
// is very, very small but not equal to 0, and attaining a CV of 0 is then impossible.
// For all intents and purposes, CINEMA_BLACK=0.02

// Gamma compensation factor
static const float DIM_SURROUND_GAMMA = 0.9811;

// Saturation compensation factor
static const float ODT_SAT_FACTOR = 0.93;
#ifndef __RESHADE__
static const float3x3 ODT_SAT_MAT = calc_sat_adjust_matrix( ODT_SAT_FACTOR, AP1_RGB2Y);
static const float3x3 D60_2_D65_CAT = calculate_cat_matrix( AP0.white, REC709_PRI.white);
#else
#define ODT_SAT_MAT calc_sat_adjust_matrix( ODT_SAT_FACTOR, AP1_RGB2Y)
#define D60_2_D65_CAT calculate_cat_matrix( AP0.white, REC709_PRI.white)
#endif

float Y_2_linCV( float Y, float Ymax, float Ymin)
{
  return ( Y - Ymin) / ( Ymax - Ymin);
}

float linCV_2_Y( float linCV, float Ymax, float Ymin)
{
  return linCV * ( Ymax - Ymin) + Ymin;
}

float3 Y_2_linCV_f3( float3 Y, float Ymax, float Ymin)
{
  float3 linCV;
  linCV.x = Y_2_linCV( Y.x, Ymax, Ymin);
  linCV.y = Y_2_linCV( Y.y, Ymax, Ymin);
  linCV.z = Y_2_linCV( Y.z, Ymax, Ymin);
  return linCV;
}

float3 linCV_2_Y_f3( float3 linCV, float Ymax, float Ymin)
{
  float3 Y;
  Y.x = linCV_2_Y( linCV.x, Ymax, Ymin);
  Y.y = linCV_2_Y( linCV.y, Ymax, Ymin);
  Y.z = linCV_2_Y( linCV.z, Ymax, Ymin);
  return Y;
}

float3 darkSurround_to_dimSurround( float3 linearCV)
{
  float3 XYZ = mult_f3_f33( linearCV, AP1_2_XYZ_MAT);
  float3 xyY = XYZ_2_xyY( XYZ);

  xyY.z = clamp( xyY.z, 0., 65504.);
  xyY.z = pow( xyY.z, rcp( DIM_SURROUND_GAMMA));
  XYZ = xyY_2_XYZ(xyY);

  return mult_f3_f33( XYZ, XYZ_2_AP1_MAT);
}

float3 dimSurround_to_darkSurround( float3 linearCV)
{
  float3 XYZ = mult_f3_f33( linearCV, AP1_2_XYZ_MAT);
  float3 xyY = XYZ_2_xyY( XYZ);

  xyY.z = clamp( xyY.z, 0., 65504.);
  xyY.z = pow( xyY.z, rcp( DIM_SURROUND_GAMMA));
  XYZ = xyY_2_XYZ(xyY);

  return mult_f3_f33( XYZ, XYZ_2_AP1_MAT);
}

/* ---- Functions to compress highlights ---- */
// allow for simulated white points without clipping

float roll_white_fwd
  ( float _in, // color value to adjust (white scaled to around 1.0)
    float new_wht, // white adjustment (e.g. 0.9 for 10% darkening)
    float width // adjusted width (e.g. 0.25 for top quarter of the tone scale)
  )
{
  const float x0 = -1.;
  const float x1 = x0 + width;
  const float y0 = -new_wht;
  const float y1 = x1;
  const float m1 = ( x1 - x0);
  const float a = y0 - y1 + m1;
  const float b = 2. * ( y1 - y0) - m1;
  const float c = y0;
  const float t = ( -_in - x0) / ( x1 - x0);

  float _out = 0.;

  if ( t < 0.)
    _out = -( t * b + c);
  else if ( t > 1.)
    _out = _in;
  else
    _out = -( ( t * a + b) * t + c);
  
  return _out;
}

float roll_white_rev
  ( float _in, // color value to adjust (white scaled to around 1.0)
    float new_wht, // white adjustment (e.g. 0.9 for 10% darkening)
    float width // adjusted width (e.g. 0.25 for top quarter of the tone scale)
  )
{
  const float x0 = -1.0;
  const float x1 = x0 + width;
  const float y0 = -new_wht;
  const float y1 = x1;
  const float m1 = ( x1 - x0);
  const float a = y0 - y1 + m1;
  const float b = 2. * ( y1 - y0) - m1;
  float c = y0;

  float _out = 0.;

  if ( -_in < y0)
    _out = -x0;
  else if ( -_in > y1)
    _out = _in;
  else {
    c += _in;
    const float discrim = sqrt( b * b - 4. * a * c);
    const float t = ( 2. * c) / ( -discrim - b);
    _out = -( ( t * ( x1 - x0)) + x0);
  }

  return _out;
}

#endif // _ACES_LIB_ODT_COMMON