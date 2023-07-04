#ifndef _ACES_CSC_ACES_TO_ACEScct
#define _ACES_CSC_ACES_TO_ACEScct

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACEScsc.Academy.ACES_to_ACEScct.a1.0.3</ACEStransformID>
// <ACESuserName>ACES2065-1 to ACEScct</ACESuserName>

//
// ACES Color Space Conversion - ACES to ACEScct
//
// converts ACES2065-1 (AP0 w/ linear encoding) to 
//          ACEScct (AP1 w/ logarithmic encoding)
//

// *-*-*-*-*-*-*-*-*
// ACEScct is intended to be transient and internal to software or hardware 
// systems, and is specifically not intended for interchange or archiving.
// ACEScct should NOT be written into a container file in actual implementations!
// *-*-*-*-*-*-*-*-*

#include "../../lib/ACESlib.Transform_Common.hlsl"

float lin_to_ACEScct( float _in)
{
  const float X_BRK = 0.0078125;
  const float Y_BRK = 0.155251141552511;
  const float A = 10.5402377416545;
  const float B = 0.0729055341958355;

  if ( _in <= X_BRK)
    return A * _in + B;
  else // (_in > X_BRK)
    return ( log2( _in) + 9.72) / 17.52;
}

float3 ACES_to_ACEScct( float3 ACES)
{
  float3 lin_AP1 = mult_f3_f33( ACES, AP0_2_AP1_MAT);

  float3 ACEScct;
  ACEScct.r = lin_to_ACEScct( lin_AP1.r);
  ACEScct.g = lin_to_ACEScct( lin_AP1.g);
  ACEScct.b = lin_to_ACEScct( lin_AP1.b);

  return ACEScct;
}

#endif // _ACES_CSC_ACES_TO_ACEScct