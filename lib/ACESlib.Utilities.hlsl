#ifndef _ACES_LIB_UTILITIES
#define _ACES_LIB_UTILITIES

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACESlib.Utilities.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Lib - Utilities</ACESuserName>

//
// Generic functions that may be useful for writing CTL programs
//

/* min and max functions are excluded due to being HLSL intrinsics. */

float min_f3( float3 a) 
{
  return min( a.x, min( a.y, a.z));
}

float max_f3(float3 a) 
{
  return max( a.x, max( a.y, a.z));
}

float clip( float v)
{
  return min( v, 1.0);
}

/* Equivalent to the CTL implementation of `clip_f3()` */
float3 clip_f3( float3 _in)
{
  return min( _in, 1.0);
}

/* `clamp()` is already an HLSL intrinsic, implement `clamp_f3()` as an alias. */

float3 clamp_f3( float3 _in, float clampMin, float clampMax)
{
  // Note: Numeric constants can be used in place of a min or max value (i.e. 
  // use HALF_NEG_INF in place of clampMin or HALF_POS_INF in place of clampMax)

  return clamp( _in, clampMin, clampMax);
}

/* Functionally irrelevant in HLSL, a float can be added to a float3 natively,
 * only here for compatibility purposes */

float3 add_f_f3( float a, float3 b)
{
  return a + b;
}

/* Also functionally irrelevant, the `pow()` intrinsic can use a float as the 
 * power to a float3 natively. Included for the same reasons as `add_f_f3()` */

float3 pow_f3( float3 a, float b)
{
  return pow( a, b);
}

float3 pow10_f3( float3 a)
{
  return pow( 10., a);
}

/* Functionaly irrelevant as `log10()` supports float3 parameters natively.
 * Also here for compatibility, same as `pow_f3()` and `add_f_f3()` */

float3 log10_f3( float3 a)
{
  return log10( a);
}

/* A different implementation than the CTL lib used but functionally
 * equivalent to the lengthier CTL implementation. */

float round( float x)
{
  return trunc( x < 0. ? x - 0.5 : x + 0.5);
}

/* `log2()` excluded as `log2()` is already an HLSL intrinsic and would cause
 * errors during compilation if re-defined */

/* A slightly different implementation but works the same. */
int sign( float x)
{
  // Signum function:
  //  sign(X) returns 1 if the element is greater than zero, 0 if it equals zero 
  //  and -1 if it is less than zero

  if (x < 0) {
    return -1;
  } else if (x > 0) {
    return 1;
  } else {
    return 0;
  }
}

/* The rest of the functions in the file are diagnostic and only work in the CTL
 * interpreter. HLSL doesn't have the ability to write to debug output. */

#endif // _ACES_LIB_UTILITIES