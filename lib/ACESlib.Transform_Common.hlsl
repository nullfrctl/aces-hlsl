#ifndef _ACES_LIB_TRANSFORM_COMMON
#define _ACES_LIB_TRANSFORM_COMMON

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACESlib.Transform_Common.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Lib - Transform Common</ACESuserName>

//
// Contains functions and constants shared by multiple forward and inverse 
// transforms 
//

#include "ACESlib.Utilities_Color.hlsl"
#include "ACESlib.Utilities.hlsl"

static const float3x3 AP0_2_XYZ_MAT = RGBtoXYZ( AP0, 1.0);
static const float3x3 XYZ_2_AP0_MAT = invert_f33( AP0_2_XYZ_MAT);

static const float3x3 AP1_2_XYZ_MAT = RGBtoXYZ( AP1, 1.0);
static const float3x3 XYZ_2_AP1_MAT = invert_f33( AP1_2_XYZ_MAT);

static const float3x3 AP0_2_AP1_MAT = mult_f33_f33( AP0_2_XYZ_MAT, XYZ_2_AP1_MAT);
static const float3x3 AP1_2_AP0_MAT = mult_f33_f33( AP1_2_XYZ_MAT, XYZ_2_AP0_MAT);

static const float3 AP1_RGB2Y = float3( AP1_2_XYZ_MAT[0][1], AP1_2_XYZ_MAT[1][1], AP1_2_XYZ_MAT[2][1]);
static const float TINY = 1e-10;

float rgb_2_saturation( float3 rgb)
{
  return ( max( max_f3( rgb), TINY) - max( min_f3( rgb), TINY)) / max( max_f3( rgb), 1e-2);
}

#endif // _ACES_LIB_TRANSFORM_COMMON