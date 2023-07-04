#ifndef _ACES_CSC_ACEScct_TO_ACES
#define _ACES_CSC_ACEScct_TO_ACES

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACEScsc.Academy.ACEScct_to_ACES.a1.0.3</ACEStransformID>
// <ACESuserName>ACEScct to ACES2065-1</ACESuserName>

//
// ACES Color Space Conversion - ACEScct to ACES
//
// converts ACEScct (AP1 w/ ACESlog encoding) to 
//          ACES2065-1 (AP0 w/ linear encoding)
//

// *-*-*-*-*-*-*-*-*
// ACEScct is intended to be transient and internal to software or hardware 
// systems, and is specifically not intended for interchange or archiving.
// ACEScct should NOT be written into a container file in actual implementations!
// *-*-*-*-*-*-*-*-*

#include "../../lib/ACESlib.Transform_Common.hlsl"

float ACEScct_to_lin( float _in)
{
  const float X_BRK = 0.0078125;
  const float Y_BRK = 0.155251141552511;
  const float A = 10.5402377416545;
  const float B = 0.0729055341958355;

  if ( _in > Y_BRK)
    return exp2( _in * 17.52 - 9.72);
  else
    return ( _in - B) / A;
}

float3 ACEScct_to_ACES( float3 ACEScct)
{
  float3 lin_AP1;
  lin_AP1.r = ACEScct_to_lin( ACEScct.r);
  lin_AP1.g = ACEScct_to_lin( ACEScct.g);
  lin_AP1.b = ACEScct_to_lin( ACEScct.b);

  float3 ACES = mult_f3_f33( lin_AP1, AP1_2_AP0_MAT);

  return ACES;
}

#endif // _ACES_CSC_ACEScct_TO_ACES