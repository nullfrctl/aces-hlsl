#ifndef _ACES_CSC_ACES_TO_ACEScc
#define _ACES_CSC_ACES_TO_ACEScc

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACEScsc.Academy.ACES_to_ACEScc.a1.0.3</ACEStransformID>
// <ACESuserName>ACES2065-1 to ACEScc</ACESuserName>

//
// ACES Color Space Conversion - ACES to ACEScc
//
// converts ACES2065-1 (AP0 w/ linear encoding) to 
//          ACEScc (AP1 w/ logarithmic encoding)
//
// This transform follows the formulas from section 4.4 in S-2014-003
//

// *-*-*-*-*-*-*-*-*
// ACEScc is intended to be transient and internal to software or hardware 
// systems, and is specifically not intended for interchange or archiving.
// ACEScc should NOT be written into a container file in actual implementations!
// *-*-*-*-*-*-*-*-*

#include "../../lib/ACESlib.Transform_Common.hlsl"

float lin_to_ACEScc( float _in)
{
  if ( _in <= 0.)
    return -0.3584474886; // ( log2( pow( 2., -16.)) + 9.72) / 17.52
  else if ( _in < exp2( -15.))
    return ( log2( exp2( -16.) + _in * 0.5) + 9.72) / 17.52;
  else // (_in >= exp2( -15.))
    return ( log2( _in) + 9.72) / 17.52;
}

float3 ACES_to_ACEScc( float3 ACES)
{
  ACES = clamp_f3( ACES, 0., 65504.);
  // NOTE: (from Annex A of S-2014-003)
  // When ACES values are matrixed into the smaller AP1 space, colors outside 
  // the AP1 gamut can generate negative values even before the log encoding. 
  // If these values are clipped, a conversion back to ACES will not restore 
  // the original colors. A specific method of reserving negative values 
  // produced by the transformation matrix has not been defined in part to 
  // help ease adoption across various color grading systems that have 
  // different capabilities and methods for handling negative values. Clipping 
  // these values has been found to have minimal visual impact when viewed 
  // through the RRT and ODT on currently available display technology. 
  // However, to preserve creative choice in downstream processing and to 
  // provide the highest quality archival master, developers implementing 
  // ACEScc encoding are encouraged to adopt a method of preserving negative 
  // values so that a conversion from ACES to ACEScc and back can be made 
  // lossless.

  float3 lin_AP1 = mult_f3_f33( ACES, AP0_2_AP1_MAT);

  float3 ACEScc;
  ACEScc.r = lin_to_ACEScc( lin_AP1.r);
  ACEScc.g = lin_to_ACEScc( lin_AP1.g);
  ACEScc.b = lin_to_ACEScc( lin_AP1.b);

  return ACEScc;
}

#endif // _ACES_CSC_ACES_TO_ACEScc