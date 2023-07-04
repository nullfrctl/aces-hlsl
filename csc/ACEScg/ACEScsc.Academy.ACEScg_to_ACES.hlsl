#ifndef _ACES_CSC_ACEScg_TO_ACES
#define _ACES_CSC_ACEScg_TO_ACES

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACEScsc.Academy.ACEScg_to_ACES.a1.0.3</ACEStransformID>
// <ACESuserName>ACEScg to ACES2065-1</ACESuserName>

//
// ACES Color Space Conversion - ACEScg to ACES
//
// converts ACEScg (AP1 w/ linear encoding) to
//          ACES2065-1 (AP0 w/ linear encoding)
//

#include "../../lib/ACESlib.Transform_Common.hlsl"

float3 ACEScg_to_ACES( float3 ACEScg)
{
  float3 ACES = mult_f3_f33( ACEScg, AP1_2_AP0_MAT);
  return ACES;
}

#endif // _ACES_CSC_ACEScg_TO_ACES