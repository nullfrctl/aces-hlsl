#ifndef _ACES_CSC_ACEScc_TO_ACES
#define _ACES_CSC_ACEScc_TO_ACES

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACEScsc.Academy.ACEScc_to_ACES.a1.0.3</ACEStransformID>
// <ACESuserName>ACEScc to ACES2065-1</ACESuserName>

//
// ACES Color Space Conversion - ACEScc to ACES
//
// converts ACEScc (AP1 w/ ACESlog encoding) to 
//          ACES2065-1 (AP0 w/ linear encoding)
//
// This transform follows the formulas from section 4.4 in S-2014-003
//

// *-*-*-*-*-*-*-*-*
// ACEScc is intended to be transient and internal to software or hardware 
// systems, and is specifically not intended for interchange or archiving.
// ACEScc should NOT be written into a container file in actual implementations!
// *-*-*-*-*-*-*-*-*

#include "../../lib/ACESlib.Transform_Common.hlsl"

float ACEScc_to_lin( float _in)
{
  if ( _in < -0.3013698630)
    return ( exp2( _in * 17.52 - 9.72) - exp2( -16.)) * 2.;
  else if ( _in < ( log2( 65504.) + 9.72) / 17.52)
    return exp2( _in * 17.52 - 9.72);
  else // ( _in >= ( log2( 65504.) + 9.72) / 17.52)
    return 65504.;
}

float3 ACEScc_to_ACES( float3 ACEScc)
{
  float3 lin_AP1;
  lin_AP1.r = ACEScc_to_lin( ACEScc.r);
  lin_AP1.g = ACEScc_to_lin( ACEScc.g);
  lin_AP1.b = ACEScc_to_lin( ACEScc.b);

  float3 ACES = mult_f3_f33( lin_AP1, AP1_2_AP0_MAT);

  return ACES;
}

#endif // _ACES_CSC_ACEScc_TO_ACES