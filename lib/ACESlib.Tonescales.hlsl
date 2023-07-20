#ifndef _ACES_LIB_TONESCALES
#define _ACES_LIB_TONESCALES

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACESlib.Tonescales.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Lib - Tonescales</ACESuserName>

#include "CTLlib.hlsl"
#include "ACESlib.Transform_Common.hlsl"
#include "ACESlib.Utilities.hlsl"
#include "ACESlib.Utilities_Color.hlsl"

// Textbook monomial to basis-function conversion matrix.
static const float3x3 M = float3x3(
   0.5, -1.0, 0.5,
  -1.0,  1.0, 0.5,
   0.5,  0.0, 0.0
);

#ifndef __RESHADE__
typedef float2 SplineMapPoint;
#else
#define SplineMapPoint float2
#endif

struct SegmentedSplineParams_c5
{
  float coefsLow[6]; // coefs for B-spline between minPoint and midPoint (units of log luminance)
  float coefsHigh[6]; // coefs for B-spline between midPoint and maxPoint (units of log luminance)
  SplineMapPoint minPoint; // {luminance, luminance} linear extension below this
  SplineMapPoint midPoint; // {luminance, luminance} 
  SplineMapPoint maxPoint; // {luminance, luminance} linear extension above this
  float slopeLow; // log-log slope of low linear extension
  float slopeHigh; // log-log slope of high linear extension
};

struct SegmentedSplineParams_c9
{
  float coefsLow[10];    // coefs for B-spline between minPoint and midPoint (units of log luminance)
  float coefsHigh[10];   // coefs for B-spline between midPoint and maxPoint (units of log luminance)
  SplineMapPoint minPoint; // {luminance, luminance} linear extension below this
  SplineMapPoint midPoint; // {luminance, luminance} 
  SplineMapPoint maxPoint; // {luminance, luminance} linear extension above this
  float slopeLow;       // log-log slope of low linear extension
  float slopeHigh;      // log-log slope of high linear extension
};

#ifndef __RESHADE__
static const SegmentedSplineParams_c5 RRT_PARAMS =
{
  // coefsLow[6]
  { -4.0000000000, -4.0000000000, -3.1573765773, -0.4852499958, 1.8477324706, 1.8477324706 },
  // coefsHigh[6]
  { -0.7185482425, 2.0810307172, 3.6681241237, 4.0000000000, 4.0000000000, 4.0000000000 },
  { 0.18*pow(2.,-15), 0.0001},    // minPoint
  { 0.18,                4.8},    // midPoint  
  { 0.18*pow(2., 18), 10000.},    // maxPoint
  0.0,  // slopeLow
  0.0   // slopeHigh
};
#else
SegmentedSplineParams_c5 _RRT_PARAMS()
{
  SegmentedSplineParams_c5 params;
  // coefsLow[6]
  params.coefsLow = { -4.0000000000, -4.0000000000, -3.1573765773, -0.4852499958, 1.8477324706, 1.8477324706 };
  // coefsHigh[6]
  params.coefsHigh = { -0.7185482425, 2.0810307172, 3.6681241237, 4.0000000000, 4.0000000000, 4.0000000000 };
  params.minPoint = float2( 0.18*pow(2.,-15), 0.0001);    // minPoint
  params.midPoint = float2( 0.18,                4.8);    // midPoint  
  params.maxPoint = float2( 0.18*pow(2., 18), 10000.);    // maxPoint
  params.slopeLow = 0.0;  // slopeLow
  params.slopeHigh = 0.0;  // slopeHigh

  return params;
}
#define RRT_PARAMS _RRT_PARAMS()
#endif

float segmented_spline_c5_fwd
  ( float x,
    SegmentedSplineParams_c5 C
  )
{
  const int N_KNOTS_LOW = 4;
  const int N_KNOTS_HIGH = 4;

  // Check for negatives or zero before taking the log. If negative or zero,
  // set to HALF_MIN.
  float logx = log10( max( x, 6.10352e-5)); 

  float logy;

  if ( logx <= log10( C.minPoint.x)) {
    logy = logx * C.slopeLow + ( log10( C.minPoint.y) - C.slopeLow * log10( C.minPoint.x));
  } else if ( ( logx > log10( C.minPoint.x)) && ( logx < log10( C.midPoint.x))) {
    float knot_coord = ( N_KNOTS_LOW - 1) * ( logx - log10( C.minPoint.x)) / ( log10( C.midPoint.x) - log10( C.minPoint.x));
    int j = knot_coord;
    float t = knot_coord - j;

    float3 cf = float3( C.coefsLow[j], C.coefsLow[j + 1], C.coefsLow[j + 2]);
    
    float3 monomials = float3( t * t, t, 1.);
    logy = dot_f3_f3( monomials, mult_f3_f33( cf, M));
  } else if ( ( logx >= log10( C.midPoint.x)) && ( logx < log10( C.maxPoint.x))) {
    float knot_coord = ( N_KNOTS_HIGH - 1) * ( logx - log10( C.midPoint.x)) / ( log10( C.maxPoint.x) - log10( C.midPoint.x));
    int j = knot_coord;
    float t = knot_coord - j;

    float3 cf = float3( C.coefsHigh[j], C.coefsHigh[j + 1], C.coefsHigh[j + 2]); 

    float3 monomials = float3( t * t, t, 1.);
    logy = dot_f3_f3( monomials, mult_f3_f33( cf, M));
  } else { //if ( logIn >= log10(C.maxPoint.x) ) { 
    logy = logx * C.slopeHigh + ( log10(C.maxPoint.y) - C.slopeHigh * log10(C.maxPoint.x) );
  }

  return pow10(logy);
}

float segmented_spline_c5_fwd(float x)
{
  return segmented_spline_c5_fwd(x, RRT_PARAMS);
}

float segmented_spline_c5_rev
  ( float y,
    SegmentedSplineParams_c5 C
  )
{  
  const int N_KNOTS_LOW = 4;
  const int N_KNOTS_HIGH = 4;

  const float KNOT_INC_LOW = ( log10( C.midPoint.x) - log10( C.minPoint.x)) / ( N_KNOTS_LOW - 1);
  const float KNOT_INC_HIGH = ( log10( C.maxPoint.x) - log10( C.midPoint.x)) / ( N_KNOTS_HIGH - 1);
  
  // KNOT_Y is luminance of the spline at each knot
  float KNOT_Y_LOW[N_KNOTS_LOW];
  for ( int i = 0; i < N_KNOTS_LOW; i++)
    KNOT_Y_LOW[i] = ( C.coefsLow[i] + C.coefsLow[i + 1]) * 0.5;

  float KNOT_Y_HIGH[N_KNOTS_HIGH];
  for ( int i = 0; i < N_KNOTS_HIGH; i++)
    KNOT_Y_HIGH[i] = ( C.coefsHigh[i] + C.coefsHigh[i + 1]) * 0.5;

  float logy = log10( max( y, TINY));

  float logx;
  if ( logy <= log10( C.minPoint.y))
    logx = log10( C.minPoint.x);
  else if ( ( logy > log10( C.minPoint.y)) && ( logy <= log10( C.midPoint.y))) {
    uint j;
    float3 cf;

    if ( logy > KNOT_Y_LOW[0] && logy <= KNOT_Y_LOW[1]) {
      cf.x = C.coefsLow[0];  
      cf.y = C.coefsLow[1];
      cf.z = C.coefsLow[2];  
      j = 0;
    } else if ( logy > KNOT_Y_LOW[1] && logy <= KNOT_Y_LOW[2]) {
      cf.x = C.coefsLow[1];  
      cf.y = C.coefsLow[2];  
      cf.z = C.coefsLow[3];  
      j = 1;
    } else if ( logy > KNOT_Y_LOW[2] && logy <= KNOT_Y_LOW[3]) {
      cf.x = C.coefsLow[2];
      cf.y = C.coefsLow[3];  
      cf.z = C.coefsLow[4];  
      j = 2;
    } 
    
    const float3 tmp = mult_f3_f33( cf, M);

    float a = tmp.x;
    float b = tmp.y;
    float c = tmp.z;
    c -= logy;

    const float d = sqrt( b * b - 4. * a * c);
    const float t = ( 2. * c) / ( -d - b);

    logx = log10( C.minPoint.x) + ( t + j) * KNOT_INC_LOW;
  } else if ( ( logy > log10( C.midPoint.y)) && ( logy < log10( C.maxPoint.y))) {
    uint j;
    float3 cf;
    
    if ( logy > KNOT_Y_HIGH[0] && logy <= KNOT_Y_HIGH[1]) {
        cf.x = C.coefsHigh[0];  
        cf.y = C.coefsHigh[1];  
        cf.z = C.coefsHigh[2];  
        j = 0;
    } else if ( logy > KNOT_Y_HIGH[1] && logy <= KNOT_Y_HIGH[2]) {
        cf.x = C.coefsHigh[1];  
        cf.y = C.coefsHigh[2];  
        cf.z = C.coefsHigh[3];  
        j = 1;
    } else if ( logy > KNOT_Y_HIGH[2] && logy <= KNOT_Y_HIGH[3]) {
        cf.x = C.coefsHigh[2];  
        cf.y = C.coefsHigh[3];  
        cf.z = C.coefsHigh[4];  
        j = 2;
    } 
    
    const float3 tmp = mult_f3_f33( cf, M);

    float a = tmp.x;
    float b = tmp.y;
    float c = tmp.z;
    c -= logy;

    const float d = sqrt( b * b - 4. * a * c);
    const float t = ( 2. * c) / ( -d - b);

    logx = log10( C.midPoint.x) + ( t + j) * KNOT_INC_HIGH;

  } else //if ( logy >= log10(C.maxPoint.y) ) {
    logx = log10( C.maxPoint.x);
  
  return pow10( logx);
}

float segmented_spline_c5_rev(float y)
{
  return segmented_spline_c5_rev(y, RRT_PARAMS);
}

#ifndef __RESHADE__
static const SegmentedSplineParams_c9 ODT_48nits =
{
  // coefsLow[10]
  { -1.6989700043, -1.6989700043, -1.4779000000, -1.2291000000, -0.8648000000, -0.4480000000, 0.0051800000, 0.4511080334, 0.9113744414, 0.9113744414},
  // coefsHigh[10]
  { 0.5154386965, 0.8470437783, 1.1358000000, 1.3802000000, 1.5197000000, 1.5985000000, 1.6467000000, 1.6746091357, 1.6878733390, 1.6878733390 },
  {segmented_spline_c5_fwd( 0.18*pow(2.,-6.5) ),  0.02},    // minPoint
  {segmented_spline_c5_fwd( 0.18 ),                4.8},    // midPoint  
  {segmented_spline_c5_fwd( 0.18*pow(2.,6.5) ),   48.0},    // maxPoint
  0.0,  // slopeLow
  0.04  // slopeHigh
};

static const SegmentedSplineParams_c9 ODT_1000nits =
{
  // coefsLow[10]
  { -4.9706219331, -3.0293780669, -2.1262, -1.5105, -1.0578, -0.4668, 0.11938, 0.7088134201, 1.2911865799, 1.2911865799 },
  // coefsHigh[10]
  { 0.8089132070, 1.1910867930, 1.5683, 1.9483, 2.3083, 2.6384, 2.8595, 2.9872608805, 3.0127391195, 3.0127391195 },
  {segmented_spline_c5_fwd( 0.18*pow(2.,-12.) ), 0.0001},    // minPoint
  {segmented_spline_c5_fwd( 0.18 ),                10.0},    // midPoint  
  {segmented_spline_c5_fwd( 0.18*pow(2.,10.) ),  1000.0},    // maxPoint
  3.0,  // slopeLow
  0.06  // slopeHigh
};

static const SegmentedSplineParams_c9 ODT_2000nits =
{
  // coefsLow[10]
  { -4.9706219331, -3.0293780669, -2.1262, -1.5105, -1.0578, -0.4668, 0.11938, 0.7088134201, 1.2911865799, 1.2911865799 },
  // coefsHigh[10]
  { 0.8019952042, 1.1980047958, 1.5943000000, 1.9973000000, 2.3783000000, 2.7684000000, 3.0515000000, 3.2746293562, 3.3274306351, 3.3274306351 },
  {segmented_spline_c5_fwd( 0.18*pow(2.,-12.) ), 0.0001},    // minPoint
  {segmented_spline_c5_fwd( 0.18 ),                10.0},    // midPoint  
  {segmented_spline_c5_fwd( 0.18*pow(2.,11.) ),  2000.0},    // maxPoint
  3.0,  // slopeLow
  0.12  // slopeHigh
};

static const SegmentedSplineParams_c9 ODT_4000nits =
{
  // coefsLow[10]
  { -4.9706219331, -3.0293780669, -2.1262, -1.5105, -1.0578, -0.4668, 0.11938, 0.7088134201, 1.2911865799, 1.2911865799 },
  // coefsHigh[10]
  { 0.7973186613, 1.2026813387, 1.6093000000, 2.0108000000, 2.4148000000, 2.8179000000, 3.1725000000, 3.5344995451, 3.6696204376, 3.6696204376 },
  {segmented_spline_c5_fwd( 0.18*pow(2.,-12.) ), 0.0001},    // minPoint
  {segmented_spline_c5_fwd( 0.18 ),                10.0},    // midPoint  
  {segmented_spline_c5_fwd( 0.18*pow(2.,12.) ),  4000.0},    // maxPoint
  3.0,  // slopeLow
  0.3   // slopeHigh
};
#else
SegmentedSplineParams_c9 _ODT_48nits()
{
  SegmentedSplineParams_c9 params;
  // coefsLow[10]
  params.coefsLow = { -1.6989700043, -1.6989700043, -1.4779000000, -1.2291000000, -0.8648000000, -0.4480000000, 0.0051800000, 0.4511080334, 0.9113744414, 0.9113744414};
  // coefsHigh[10]
  params.coefsHigh = { 0.5154386965, 0.8470437783, 1.1358000000, 1.3802000000, 1.5197000000, 1.5985000000, 1.6467000000, 1.6746091357, 1.6878733390, 1.6878733390 };
  params.minPoint = float2( segmented_spline_c5_fwd( 0.18*pow(2.,-6.5) ),  0.02);    // minPoint
  params.midPoint = float2( segmented_spline_c5_fwd( 0.18 ),                4.8);    // midPoint  
  params.maxPoint = float2( segmented_spline_c5_fwd( 0.18*pow(2.,6.5) ),   48.0);    // maxPoint
  params.slopeLow = 0.0;  // slopeLow
  params.slopeHigh = 0.04;  // slopeHigh
  return params;
}
#define ODT_48nits _ODT_48nits()

SegmentedSplineParams_c9 _ODT_1000nits()
{
  SegmentedSplineParams_c9 params;
  // coefsLow[10]
  params.coefsLow = { -4.9706219331, -3.0293780669, -2.1262, -1.5105, -1.0578, -0.4668, 0.11938, 0.7088134201, 1.2911865799, 1.2911865799 };
  // coefsHigh[10]
  params.coefsHigh = { 0.8089132070, 1.1910867930, 1.5683, 1.9483, 2.3083, 2.6384, 2.8595, 2.9872608805, 3.0127391195, 3.0127391195 };
  params.minPoint = float2( segmented_spline_c5_fwd( 0.18*pow(2.,-12.) ), 0.0001);    // minPoint
  params.midPoint = float2( segmented_spline_c5_fwd( 0.18 ),                10.0);    // midPoint  
  params.maxPoint = float2( segmented_spline_c5_fwd( 0.18*pow(2.,10.) ),  1000.0);    // maxPoint
  params.slopeLow = 3.0;  // slopeLow
  params.slopeHigh = 0.06;  // slopeHigh
  params;
}
#define ODT_1000nits _ODT_1000nits()

SegmentedSplineParams_c9 _ODT_2000nits()
{
  SegmentedSplineParams_c9 params;
  // coefsLow[10]
  params.coefsLow = { -4.9706219331, -3.0293780669, -2.1262, -1.5105, -1.0578, -0.4668, 0.11938, 0.7088134201, 1.2911865799, 1.2911865799 };
  // coefsHigh[10]
  params.coefsHigh = { 0.8019952042, 1.1980047958, 1.5943000000, 1.9973000000, 2.3783000000, 2.7684000000, 3.0515000000, 3.2746293562, 3.3274306351, 3.3274306351 };
  params.minPoint = float2( segmented_spline_c5_fwd( 0.18*pow(2.,-12.) ), 0.0001);    // minPoint
  params.midPoint = float2( segmented_spline_c5_fwd( 0.18 ),                10.0);    // midPoint  
  params.maxPoint = float2( segmented_spline_c5_fwd( 0.18*pow(2.,11.) ),  2000.0);    // maxPoint
  params.slopeLow = 3.0;  // slopeLow
  params.slopeHigh = 0.12;  // slopeHigh
  return params;
}
#define ODT_2000nits _ODT_2000nits()

SegmentedSplineParams_c9 _ODT_4000nits()
{
  SegmentedSplineParams_c9 params;
  // coefsLow[10]
  params.coefsLow = { -4.9706219331, -3.0293780669, -2.1262, -1.5105, -1.0578, -0.4668, 0.11938, 0.7088134201, 1.2911865799, 1.2911865799 };
  // coefsHigh[10]
  params.coefsHigh = { 0.7973186613, 1.2026813387, 1.6093000000, 2.0108000000, 2.4148000000, 2.8179000000, 3.1725000000, 3.5344995451, 3.6696204376, 3.6696204376 };
  params.minPoint = float2( segmented_spline_c5_fwd( 0.18*pow(2.,-12.) ), 0.0001);    // minPoint
  params.midPoint = float2( segmented_spline_c5_fwd( 0.18 ),                10.0);    // midPoint  
  params.maxPoint = float2( segmented_spline_c5_fwd( 0.18*pow(2.,12.) ),  4000.0);    // maxPoint
  params.slopeLow = 3.0;  // slopeLow
  params.slopeHigh = 0.3;   // slopeHigh
  return params;
}
#define ODT_4000nits _ODT_4000nits()
#endif

float segmented_spline_c9_fwd
  ( float x,
    SegmentedSplineParams_c9 C
  )
{    
  const int N_KNOTS_LOW = 8;
  const int N_KNOTS_HIGH = 8;

  // Check for negatives or zero before taking the log. If negative or zero,
  // set to HALF_MIN.
  float logx = log10( max( x, 6.10352e-5f)); 
  float logy;

  if ( logx <= log10( C.minPoint.x) )
    logy = logx * C.slopeLow + ( log10( C.minPoint.y) - C.slopeLow * log10( C.minPoint.x));
  else if ( ( logx > log10( C.minPoint.x)) && ( logx < log10( C.midPoint.x))) {
    float knot_coord = ( N_KNOTS_LOW - 1) * ( logx - log10( C.minPoint.x)) / ( log10( C.midPoint.x) - log10( C.minPoint.x));
    int j = knot_coord;
    float t = knot_coord - j;

    float3 cf = float3( C.coefsLow[j], C.coefsLow[j + 1], C.coefsLow[j + 2]);
    
    float3 monomials = float3( t * t, t, 1.);
    logy = dot_f3_f3( monomials, mult_f3_f33( cf, M));
  } else if (( logx >= log10(C.midPoint.x) ) && ( logx < log10(C.maxPoint.x) )) {
    float knot_coord = ( N_KNOTS_HIGH - 1) * ( logx - log10( C.midPoint.x)) / ( log10( C.maxPoint.x) - log10( C.midPoint.x));
    int j = knot_coord;
    float t = knot_coord - j;

    float3 cf = float3( C.coefsHigh[j], C.coefsHigh[j + 1], C.coefsHigh[j + 2]); 

    float3 monomials = float3( t * t, t, 1.);
    logy = dot_f3_f3( monomials, mult_f3_f33( cf, M));

  } else //if ( logIn >= log10(C.maxPoint.x) ) { 
    logy = logx * C.slopeHigh + ( log10( C.maxPoint.y) - C.slopeHigh * log10( C.maxPoint.x));

  return pow10( logy);
}


float segmented_spline_c9_rev
  ( float y,
    SegmentedSplineParams_c9 C
  )
{  
  const int N_KNOTS_LOW = 8;
  const int N_KNOTS_HIGH = 8;

  const float KNOT_INC_LOW = ( log10( C.midPoint.x) - log10( C.minPoint.x)) / ( N_KNOTS_LOW - 1.);
  const float KNOT_INC_HIGH = ( log10( C.maxPoint.x) - log10( C.midPoint.x)) / ( N_KNOTS_HIGH - 1.);
  
  // KNOT_Y is luminance of the spline at each knot
  float KNOT_Y_LOW[N_KNOTS_LOW];
  for ( int i = 0; i < N_KNOTS_LOW; i++)
    KNOT_Y_LOW[ i] = ( C.coefsLow[i] + C.coefsLow[i+1]) * 0.5;

  float KNOT_Y_HIGH[N_KNOTS_HIGH];
  for ( int i = 0; i < N_KNOTS_HIGH; i++)
    KNOT_Y_HIGH[i] = ( C.coefsHigh[i] + C.coefsHigh[i + 1]) * 0.5;

  float logy = log10( max( y, TINY));
  float logx;

  if ( logy <= log10( C.minPoint.y))
    logx = log10( C.minPoint.x);
  else if ( ( logy > log10( C.minPoint.y)) && ( logy <= log10( C.midPoint.y))) {
    uint j;
    float3 cf;

    if ( logy > KNOT_Y_LOW[ 0] && logy <= KNOT_Y_LOW[ 1]) {
        cf.x = C.coefsLow[0];  
        cf.y = C.coefsLow[1];  
        cf.z = C.coefsLow[2];  
        j = 0;
    } else if ( logy > KNOT_Y_LOW[1] && logy <= KNOT_Y_LOW[2]) {
        cf.x = C.coefsLow[1];  
        cf.y = C.coefsLow[2];  
        cf.z = C.coefsLow[3];  
        j = 1;
    } else if ( logy > KNOT_Y_LOW[2] && logy <= KNOT_Y_LOW[3]) {
        cf.x = C.coefsLow[2];  
        cf.y = C.coefsLow[3];  
        cf.z = C.coefsLow[4];  
        j = 2;
    } else if ( logy > KNOT_Y_LOW[3] && logy <= KNOT_Y_LOW[4]) {
        cf.x = C.coefsLow[3];  
        cf.y = C.coefsLow[4];  
        cf.z = C.coefsLow[5];  
        j = 3;
    } else if ( logy > KNOT_Y_LOW[4] && logy <= KNOT_Y_LOW[5]) {
        cf.x = C.coefsLow[4];  
        cf.y = C.coefsLow[5];  
        cf.z = C.coefsLow[6];  
        j = 4;
    } else if ( logy > KNOT_Y_LOW[5] && logy <= KNOT_Y_LOW[6]) {
        cf.x = C.coefsLow[5];  
        cf.y = C.coefsLow[6];  
        cf.z = C.coefsLow[7];  
        j = 5;
    } else if ( logy > KNOT_Y_LOW[6] && logy <= KNOT_Y_LOW[7]) {
        cf.x = C.coefsLow[6];  
        cf.y = C.coefsLow[7];  
        cf.z = C.coefsLow[8];  
        j = 6;
    }
    
    const float3 tmp = mult_f3_f33( cf, M);

    float a = tmp.x;
    float b = tmp.y;
    float c = tmp.z;
    c -= logy;

    const float d = sqrt( b * b - 4. * a * c);
    const float t = ( 2. * c) / ( -d - b);

    logx = log10( C.minPoint.x) + ( t + j) * KNOT_INC_LOW;
  } else if ( ( logy > log10( C.midPoint.y)) && ( logy < log10( C.maxPoint.y))) {
    uint j;
    float3 cf;

    if ( logy > KNOT_Y_HIGH[0] && logy <= KNOT_Y_HIGH[1]) {
      cf.x = C.coefsHigh[0];  
      cf.y = C.coefsHigh[1];  
      cf.z = C.coefsHigh[2];  
      j = 0;
    } else if ( logy > KNOT_Y_HIGH[1] && logy <= KNOT_Y_HIGH[2]) {
      cf.x = C.coefsHigh[1];  
      cf.y = C.coefsHigh[2];  
      cf.z = C.coefsHigh[3];  
      j = 1;
    } else if ( logy > KNOT_Y_HIGH[2] && logy <= KNOT_Y_HIGH[3]) {
      cf.x = C.coefsHigh[2];  
      cf.y = C.coefsHigh[3];  
      cf.z = C.coefsHigh[4];  
      j = 2;
    } else if ( logy > KNOT_Y_HIGH[3] && logy <= KNOT_Y_HIGH[4]) {
      cf.x = C.coefsHigh[3];  
      cf.y = C.coefsHigh[4];  
      cf.z = C.coefsHigh[5];  
      j = 3;
    } else if ( logy > KNOT_Y_HIGH[4] && logy <= KNOT_Y_HIGH[5]) {
      cf.x = C.coefsHigh[4];  
      cf.y = C.coefsHigh[5];  
      cf.z = C.coefsHigh[6];  
      j = 4;
    } else if ( logy > KNOT_Y_HIGH[5] && logy <= KNOT_Y_HIGH[6]) {
      cf.x = C.coefsHigh[5];  
      cf.y = C.coefsHigh[6];  
      cf.z = C.coefsHigh[7];  
      j = 5;
    } else if ( logy > KNOT_Y_HIGH[6] && logy <= KNOT_Y_HIGH[7]) {
      cf.x = C.coefsHigh[6];  
      cf.y = C.coefsHigh[7];  
      cf.z = C.coefsHigh[8];  
      j = 6;
    }
    
    const float3 tmp = mult_f3_f33( cf, M);

    float a = tmp.x;
    float b = tmp.y;
    float c = tmp.z;
    c -= logy;

    const float d = sqrt( b * b - 4. * a * c);
    const float t = ( 2. * c) / ( -d - b);

    logx = log10( C.midPoint.x) + ( t + j) * KNOT_INC_HIGH;
  } else //if ( logy >= log10(C.maxPoint.y) ) {
    logx = log10( C.maxPoint.x);
  
  return pow10( logx);
}

float segmented_spline_c9_fwd(float x)
{
  return segmented_spline_c9_fwd(x, ODT_48nits);
}

float segmented_spline_c9_rev(float y)
{
  return segmented_spline_c9_rev(y, ODT_48nits);
}

#endif // _ACES_LIB_TONESCALES