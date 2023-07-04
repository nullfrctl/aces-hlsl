#ifndef _ACES_CSC_ACES_TO_ACEScg
#define _ACES_CSC_ACES_TO_ACEScg

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACEScsc.Academy.ACES_to_ACEScg.a1.0.3</ACEStransformID>
// <ACESuserName>ACES2065-1 to ACEScg</ACESuserName>

//
// ACES Color Space Conversion - ACES to ACEScg
//
// converts ACES2065-1 (AP0 w/ linear encoding) to 
//          ACEScg (AP1 w/ linear encoding)
//

#include "../../lib/ACESlib.Transform_Common.hlsl"

float3 ACES_to_ACEScg( float3 ACES)
{
  float3 ACEScg = mult_f3_f33( ACES, AP0_2_AP1_MAT);
  return ACEScg;
}

#endif // _ACES_CSC_ACES_TO_ACEScg