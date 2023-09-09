#ifndef _ACES_LIB_SSTS
#define _ACES_LIB_SSTS

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACESlib.SSTS.a1.1.0</ACEStransformID>
// <ACESuserName>ACES 1.0 Lib - SSTS</ACESuserName>

#include "ACESlib.CTL.hlsl"
#include "ACESlib.Transform_Common.hlsl"

//
// Contains functions used for forward and inverse tone scale
//

// Textbook monomial to basis-function conversion matrix.
const float3x3 M1 = {
  {  0.5, -1.0, 0.5 },
  { -1.0,  1.0, 0.5 },
  {  0.5,  0.0, 0.0 }
};

struct TsPoint
{
  float x;     // ACES
  float y;     // luminance
  float slope; //
};

struct TsParams
{
  TsPoint Min;
  TsPoint Mid;
  TsPoint Max;
  float coefsLow[6];
  float coefsHigh[6];
};

// TODO: Move all "magic numbers" (i.e. values in interpolation tables, etc.) to top
// and define as constants

const float MIN_STOP_SDR = -6.5;
const float MAX_STOP_SDR = 6.5;

const float MIN_STOP_RRT = -15.;
const float MAX_STOP_RRT = 18.;

const float MIN_LUM_SDR = 0.02;
const float MAX_LUM_SDR = 48.0;

const float MIN_LUM_RRT = 0.0001;
const float MAX_LUM_RRT = 10000.0;

float lookup_ACESmin( float minLum)
{
  const float2 minTable[2] = { float2( log10( MIN_LUM_RRT), MIN_STOP_RRT),
                               float2( log10( MIN_LUM_SDR), MIN_STOP_SDR) };

  return 0.18 * exp2( HACK_interpolate1D( minTable, log10( minLum)));
}

float lookup_ACESmax( float maxLum)
{
  const float2 maxTable[2] = { float2( log10( MAX_LUM_SDR), MAX_STOP_SDR),
                               float2( log10( MAX_LUM_RRT), MAX_STOP_RRT) };

  return 0.18 * exp2( HACK_interpolate1D( maxTable, log10( maxLum)));
}

void init_coefsLow
( TsPoint TsPointLow,
  TsPoint TsPointMid,
  out float coefsLow[5]
)
{
  float knotIncLow = ( log10(TsPointMid.x) - log10( TsPointLow.x)) / 3.;

  // Determine the two lowest coefficients (straddling min point)
  coefsLow[0] = ( TsPointLow.slope * ( log10( TsPointLow.x) - 0.5 * knotIncLow)) + ( log10( TsPointLow.y) - TsPointLow.slope * log10( TsPointLow.x));
  coefsLow[1] = ( TsPointLow.slope * ( log10( TsPointLow.x) + 0.5 * knotIncLow)) + ( log10( TsPointLow.y) - TsPointLow.slope * log10( TsPointLow.x));

  // Determine two highest coefficients (straddling mid point)
  coefsLow[3] = ( TsPointMid.slope * ( log10( TsPointMid.x) - 0.5 * knotIncLow)) + ( log10( TsPointMid.y) - TsPointMid.slope * log10( TsPointMid.x));
  coefsLow[4] = ( TsPointMid.slope * ( log10( TsPointMid.x) + 0.5 * knotIncLow)) + ( log10( TsPointMid.y) - TsPointMid.slope * log10( TsPointMid.x));

  // Middle coefficient (defines the "sharpness of the bend") is linearly interpolated
  float2 bendsLow[2] = { float2( MIN_STOP_RRT, 0.18),
                         float2( MIN_STOP_SDR, 0.35) };

  float pctLow = HACK_interpolate1D( bendsLow, log2( TsPointLow.x / 0.18));
  coefsLow[2] = log10( TsPointLow.y) + pctLow * ( log10( TsPointMid.y) - log10( TsPointLow.y));
}

void init_coefsHigh
( TsPoint TsPointMid,
  TsPoint TsPointMax,
  out float coefsHigh[5]
)
{
  float knotIncHigh = ( log10( TsPointMax.x) - log10( TsPointMid.x)) / 3.;

  // determine two lowest coefficients (straddling mid point)
  coefsHigh[0] = ( TsPointMid.slope * ( log10( TsPointMid.x) - 0.5 * knotIncHigh)) + ( log10( TsPointMid.y) - TsPointMid.slope * log10( TsPointMid.x));
  coefsHigh[1] = ( TsPointMid.slope * ( log10( TsPointMid.x) + 0.5 * knotIncHigh)) + ( log10( TsPointMid.y) - TsPointMid.slope * log10( TsPointMid.x));

  // Determine two highest coefficients (straddling max point)
  coefsHigh[3] = ( TsPointMax.slope * ( log10( TsPointMax.x) - 0.5 * knotIncHigh)) + ( log10( TsPointMax.y) - TsPointMax.slope * log10( TsPointMax.x));
  coefsHigh[4] = ( TsPointMax.slope * ( log10( TsPointMax.x) + 0.5 * knotIncHigh)) + ( log10( TsPointMax.y) - TsPointMax.slope * log10( TsPointMax.x));

  // Middle coefficient (defines the "sharpness of the bend") is linearly interpolated
  float2 bendsHigh[2] = { float2( MAX_STOP_SDR, 0.89),
                          float2( MAX_STOP_RRT, 0.90) };

  float pctHigh = HACK_interpolate1D( bendsHigh, log2( TsPointMax.x / 0.18));
  coefsHigh[2] = log10( TsPointMid.y) + pctHigh * ( log10( TsPointMax.y) - log10( TsPointMid.y));
}

float shift( float _in, float expShift)
{
  return exp2( ( log2(_in) - expShift));
}

TsParams init_TsParams
( float minLum,
  float maxLum,
  float expShift = 0.0
)
{
  TsPoint MIN_PT = { lookup_ACESmin( minLum), minLum, 0.0 };
  TsPoint MID_PT = { 0.18, 4.8, 1.55 };
  TsPoint MAX_PT = { lookup_ACESmax( maxLum), maxLum, 0.0 };

  float cLow[5]; init_coefsLow( MIN_PT, MID_PT, cLow);
  float cHigh[5]; init_coefsHigh( MID_PT, MAX_PT, cHigh);

  MIN_PT.x = shift( lookup_ACESmin( minLum), expShift);
  MID_PT.x = shift( 0.18, expShift);
  MAX_PT.x = shift( lookup_ACESmax( maxLum), expShift);

  TsParams P = {
    MIN_PT,
    MID_PT,
    MAX_PT,
    { cLow[0], cLow[1], cLow[2], cLow[3], cLow[4], cLow[4] },
    { cHigh[0], cHigh[1], cHigh[2], cHigh[3], cHigh[4], cHigh[4] }
  };

  return P;
}

float ssts
( const float x,
  const TsParams C
)
{
  const int N_KNOTS_LOW = 4;
  const int N_KNOTS_HIGH = 4;

  // Check for negatives or zero before taking the log. If negative or zero,
  // set to HALF_MIN
  float logx = log10( max( x, HALF_MIN));
  float logy;

  if ( logx <= log10( C.Min.x)) {
    logy = logx * C.Min.slope + ( log10( C.Min.y) - C.Min.slope * log10( C.Min.x));
  } 
  else if ( ( logx > log10( C.Min.x)) && ( logx < log10( C.Mid.x))) {
    float knot_coord = ( N_KNOTS_LOW - 1) * ( logx - log10( C.Min.x)) / ( log10( C.Mid.x) - log10( C.Min.x));
    int j = knot_coord;
    float t = knot_coord - j;

    float3 cf = { C.coefsLow[j], C.coefsLow[j + 1], C.coefsLow[j + 2] };

    float3 monomials = { t * t, t, 1.0 };
    logy = dot_f3_f3( monomials, mult_f3_f33( cf, M1));
  } 
  else if ( ( logx >= log10( C.Mid.x)) && ( logx < log10( C.Max.x))) {
    float knot_coord = ( N_KNOTS_HIGH - 1) * ( logx - log10( C.Mid.x)) / ( log10(C.Max.x) - log10( C.Mid.x));
    int j = knot_coord;
    float t = knot_coord - j;

    float3 cf = { C.coefsHigh[j], C.coefsHigh[j + 1], C.coefsHigh[j + 2] };

    float3 monomials = { t * t, t, 1.0 };
    logy = dot_f3_f3( monomials, mult_f3_f33( cf, M1));
  } 
  else { // if ( logIn >= log10( C.Max.x)) {
    logy = logx * C.Max.slope + ( log10( C.Max.y) - C.Max.slope * log10( C.Max.x));
  }

  return pow10( logy);
}

float inv_ssts
( const float y,
  const TsParams C
)
{
  const int N_KNOTS_LOW = 4;
  const int N_KNOTS_HIGH = 4;

  const float KNOT_INC_LOW = ( log10( C.Mid.x) - log10( C.Min.x)) / ( N_KNOTS_LOW - 1.);
  const float KNOT_INC_HIGH = ( log10( C.Max.x) - log10( C.Mid.x)) / ( N_KNOTS_HIGH - 1.);

  // KNOT_Y is luminance of the spline at each knot
  float KNOT_Y_LOW[N_KNOTS_LOW];
  for ( int i = 0; i < N_KNOTS_LOW; i++) {
    KNOT_Y_LOW[i] = ( C.coefsLow[i] + C.coefsLow[i + 1]) * 0.5;
  }

  float KNOT_Y_HIGH[N_KNOTS_HIGH];
  for (int i = 0; i < N_KNOTS_HIGH; i++) {
    KNOT_Y_HIGH[i] = ( C.coefsHigh[i] + C.coefsHigh[i + 1]) * 0.5;
  }

  float logy = log10( max( y, 1e-10));

  float logx;
  if ( logy <= log10( C.Min.y)) {
    logx = log10( C.Min.x);
  } 
  else if ( ( logy > log10( C.Min.y)) && ( logy <= log10( C.Mid.y))) {
    int j;
    float3 cf;

    if ( logy > KNOT_Y_LOW[0] && logy <= KNOT_Y_LOW[1]) {
      cf.x = C.coefsLow[0];
      cf.y = C.coefsLow[1];
      cf.z = C.coefsLow[2];
      j = 0;
    } 
    else if (logy > KNOT_Y_LOW[1] && logy <= KNOT_Y_LOW[2]) {
      cf.x = C.coefsLow[1];
      cf.y = C.coefsLow[2];
      cf.z = C.coefsLow[3];
      j = 1;
    } 
    else if (logy > KNOT_Y_LOW[2] && logy <= KNOT_Y_LOW[3]) {
      cf.x = C.coefsLow[2];
      cf.y = C.coefsLow[3];
      cf.z = C.coefsLow[4];
      j = 2;
    }

    const float3 tmp = mult_f3_f33( cf, M1);

    float a = tmp.x;
    float b = tmp.y;
    float c = tmp.z;
    c -= logy;

    const float d = sqrt( b * b - 4. * a * c);

    const float t = ( 2. * c) / ( -d - b);

    logx = log10( C.Min.x) + ( t + j) * KNOT_INC_LOW;
  } 
  else if ( ( logy > log10( C.Mid.y)) && ( logy < log10( C.Max.y))) {
    int j;
    float3 cf;

    if ( logy >= KNOT_Y_HIGH[0] && logy <= KNOT_Y_HIGH[1]) {
      cf.x = C.coefsHigh[0];
      cf.y = C.coefsHigh[1];
      cf.z = C.coefsHigh[2];
      j = 0;
    } 
    else if (logy > KNOT_Y_HIGH[1] && logy <= KNOT_Y_HIGH[2]) {
      cf.x = C.coefsHigh[1];
      cf.y = C.coefsHigh[2];
      cf.z = C.coefsHigh[3];
      j = 1;
    } 
    else if (logy > KNOT_Y_HIGH[2] && logy <= KNOT_Y_HIGH[3]) {
      cf.x = C.coefsHigh[2];
      cf.y = C.coefsHigh[3];
      cf.z = C.coefsHigh[4];
      j = 2;
    }

    const float3 tmp = mult_f3_f33(cf, M1);

    float a = tmp.x;
    float b = tmp.y;
    float c = tmp.z;
    c -= logy;

    const float d = sqrt( b * b - 4. * a * c);

    const float t = ( 2. * c) / ( -d - b);

    logx = log10( C.Mid.x) + ( t + j) * KNOT_INC_HIGH;
  } 
  else { //if ( logy >= log10(C.Max.y) ) {
    logx = log10( C.Max.x);
  }

  return pow10( logx);
}

float3 ssts_f3
( const float3 x,
  const TsParams C
)
{
  float3 _out;
  _out.x = ssts( x.x, C);
  _out.y = ssts( x.y, C);
  _out.z = ssts( x.z, C);

  return _out;
}

float3 inv_ssts_f3
( const float3 x,
  const TsParams C
)
{
  float3 _out;
  _out.x = inv_ssts( x.x, C);
  _out.y = inv_ssts( x.y, C);
  _out.z = inv_ssts( x.z, C);

  return _out;
}

#endif