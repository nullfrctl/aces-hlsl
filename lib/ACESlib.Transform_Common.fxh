#pragma once

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACESlib.Transform_Common.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Lib - Transform Common</ACESuserName>

//
// Contains functions and constants shared by multiple forward and inverse 
// transforms 
//

#include "ACESlib.CTL.fxh"
#include "ACESlib.Utilities_Color.fxh"
#include "ACESlib.Utilities.fxh"

float3x3 _AP0_2_XYZ_MAT()
{
  return RGBtoXYZ( AP0, 1.0);
}
#define AP0_2_XYZ_MAT (_AP0_2_XYZ_MAT())

float3x3 _XYZ_2_AP0_MAT()
{
  return invert_f33(AP0_2_XYZ_MAT);
}
#define XYZ_2_AP0_MAT (_XYZ_2_AP0_MAT())

float3x3 _AP1_2_XYZ_MAT()
{
  return RGBtoXYZ( AP1, 1.0);
}
#define AP1_2_XYZ_MAT (_AP1_2_XYZ_MAT())

float3x3 _XYZ_2_AP1_MAT()
{
  return invert_f33(AP1_2_XYZ_MAT);
}
#define XYZ_2_AP1_MAT (_XYZ_2_AP1_MAT())

float3x3 _AP0_2_AP1_MAT()
{
  return mult_f33_f33( AP0_2_XYZ_MAT, XYZ_2_AP1_MAT);
}
#define AP0_2_AP1_MAT (_AP0_2_AP1_MAT())

float3x3 _AP1_2_AP0_MAT()
{
  return mult_f33_f33( AP1_2_XYZ_MAT, XYZ_2_AP0_MAT);
}
#define AP1_2_AP0_MAT (_AP1_2_AP0_MAT())

float3 _AP1_RGB2Y()
{
  return float3( AP1_2_XYZ_MAT[0][1], AP1_2_XYZ_MAT[1][1], AP1_2_XYZ_MAT[2][1]);
}
#define AP1_RGB2Y (_AP1_RGB2Y())

#define TINY (1e-10)

float rgb_2_saturation( float3 rgb)
{
  // return ( max( max_f3( rgb), TINY) - max( min_f3( rgb), TINY)) / max( max_f3( rgb), 1e-2);
  float _min = min_f3( rgb);
  float _max = max_f3( rgb);
  return ( max( _max, TINY) - max( _min, TINY)) / max( _max, 1e-2);
}