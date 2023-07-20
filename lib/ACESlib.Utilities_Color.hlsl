#ifndef _ACES_LIB_UTILITIES_COLOR
#define _ACES_LIB_UTILITIES_COLOR

// <ACEStransformID>urn:ampas:aces:transformId:v1.5:ACESlib.Utilities_Color.a1.1.0</ACEStransformID>
// <ACESuserName>ACES 1.0 Lib - Color Utilities</ACESuserName>

//
// Color related static constants and functions
//

#include "CTLlib.hlsl"
#include "ACESlib.Utilities.hlsl"

/* ---- Chromaticities of some common primary sets ---- */

#ifndef __RESHADE__
static const Chromaticities AP0 = // ACES Primaries from SMPTE ST2065-1
{
  { 0.73470,  0.26530},
  { 0.00000,  1.00000},
  { 0.00010, -0.07700},
  { 0.32168,  0.33767}
};

static const Chromaticities AP1 = // Working space and rendering primaries for ACES 1.0
{
  { 0.713,    0.293},
  { 0.165,    0.830},
  { 0.128,    0.044},
  { 0.32168,  0.33767}
};

static const Chromaticities REC709_PRI =
{
  { 0.64000,  0.33000},
  { 0.30000,  0.60000},
  { 0.15000,  0.06000},
  { 0.31270,  0.32900}
};

static const Chromaticities P3D60_PRI =
{
  { 0.68000,  0.32000},
  { 0.26500,  0.69000},
  { 0.15000,  0.06000},
  { 0.32168,  0.33767}
};

static const Chromaticities P3D65_PRI =
{
  { 0.68000,  0.32000},
  { 0.26500,  0.69000},
  { 0.15000,  0.06000},
  { 0.31270,  0.32900}
};

static const Chromaticities P3DCI_PRI =
{
  { 0.68000,  0.32000},
  { 0.26500,  0.69000},
  { 0.15000,  0.06000},
  { 0.31400,  0.35100}
};

static const Chromaticities ARRI_ALEXA_WG_PRI =
{
  { 0.68400,  0.31300},
  { 0.22100,  0.84800},
  { 0.08610, -0.10200},
  { 0.31270,  0.32900}
};

static const Chromaticities REC2020_PRI = 
{
  { 0.70800,  0.29200},
  { 0.17000,  0.79700},
  { 0.13100,  0.04600},
  { 0.31270,  0.32900}
};

static const Chromaticities RIMMROMM_PRI = 
{
  { 0.7347,  0.2653},
  { 0.1596,  0.8404},
  { 0.0366,  0.0001},
  { 0.3457,  0.3585}
};

static const Chromaticities SONY_SGAMUT3_PRI =
{
  { 0.730,  0.280},
  { 0.140,  0.855},
  { 0.100, -0.050},
  { 0.3127,  0.3290}
};

static const Chromaticities SONY_SGAMUT3_CINE_PRI =
{
  { 0.766,  0.275},
  { 0.225,  0.800},
  { 0.089, -0.087},
  { 0.3127,  0.3290}
};

// Note: No official published primaries exist as of this day for the
// Sony VENICE SGamut3 and Sony VENICE SGamut3.Cine colorspaces. The primaries
// have thus been derived from the IDT matrices.
static const Chromaticities SONY_VENICE_SGAMUT3_PRI =
{
  { 0.740464264304292,  0.279364374750660},
  { 0.089241145423286,  0.893809528608105},
  { 0.110488236673827, -0.052579333080476},
  { 0.312700000000000,  0.329000000000000}
};

static const Chromaticities SONY_VENICE_SGAMUT3_CINE_PRI =
{
  { 0.775901871567345,  0.274502392854799},
  { 0.188682902773355,  0.828684937020288},
  { 0.101337382499301, -0.089187517306263},
  { 0.312700000000000,  0.329000000000000}
};

static const Chromaticities CANON_CGAMUT_PRI =
{
  { 0.7400,  0.2700},
  { 0.1700,  1.1400},
  { 0.0800, -0.1000},
  { 0.3127,  0.3290}
};

static const Chromaticities RED_WIDEGAMUTRGB_PRI =
{
  { 0.780308,  0.304253},
  { 0.121595,  1.493994},
  { 0.095612, -0.084589},
  { 0.3127,  0.3290}
};

static const Chromaticities PANASONIC_VGAMUT_PRI =
{
  { 0.730,  0.280},
  { 0.165,  0.840},
  { 0.100, -0.030},
  { 0.3127,  0.3290}
};

static const Chromaticities BMD_CAM_WG_GEN5_PRI =
{
  { 0.7177215,  0.3171181},
  { 0.2280410,  0.8615690},
  { 0.1005841, -0.0820452},
  { 0.3127170,  0.3290312}
};
#else
Chromaticities _AP0() // ACES Primaries from SMPTE ST2065-1
{ 
  Chromaticities ap0;
  ap0.red   = float2( 0.73470, 0.26530);
  ap0.green = float2( 0.00000, 1.00000);
  ap0.blue  = float2( 0.0010, -0.07700);
  ap0.white = float2( 0.32168, 0.33767);

  return ap0;
}
#define AP0 _AP0()

Chromaticities _AP1() // Working space and rendering primaries for ACES 1.0
{
  Chromaticities ap1;
  ap1.red   = float2( 0.713,    0.293);
  ap1.green = float2( 0.165,    0.830);
  ap1.blue  = float2( 0.128,    0.044);
  ap1.white = float2( 0.32168,  0.33767);

  return ap1;
}
#define AP1 _AP1()

Chromaticities _REC709_PRI()
{
  Chromaticities rec709;
  rec709.red   = float2( 0.64000,  0.33000);
  rec709.green = float2( 0.30000,  0.60000);
  rec709.blue  = float2( 0.15000,  0.06000);
  rec709.white = float2( 0.31270,  0.32900);

  return rec709;
}
#define REC709_PRI _REC709_PRI()

Chromaticities _P3D60_PRI()
{
  Chromaticities p3d60;
  p3d60.red   = float2( 0.68000,  0.32000);
  p3d60.green = float2( 0.26500,  0.69000);
  p3d60.blue  = float2( 0.15000,  0.06000);
  p3d60.white = float2( 0.32168,  0.33767);

  return p3d60;
}
#define P3D60_PRI _P3D60_PRI()

Chromaticities _P3D65_PRI()
{
  Chromaticities p3d65;
  p3d65.red   = float2( 0.68000,  0.32000);
  p3d65.green = float2( 0.26500,  0.69000);
  p3d65.blue  = float2( 0.15000,  0.06000);
  p3d65.white = float2( 0.31270,  0.32900);

  return p3d65;
}
#define P3D65_PRI _P3D65_PRI()

Chromaticities _P3DCI_PRI()
{
  Chromaticities p3dci;
  p3dci.red   = float2( 0.68000,  0.32000);
  p3dci.green = float2( 0.26500,  0.69000);
  p3dci.blue  = float2( 0.15000,  0.06000);
  p3dci.white = float2( 0.31400,  0.35100);

  return p3dci;
}
#define P3DCI_PRI _P3DCI_PRI()

Chromaticities _ARRI_ALEXA_WG_PRI()
{
  Chromaticities awg;
  awg.red   = float2( 0.68400,  0.31300);
  awg.green = float2( 0.22100,  0.84800);
  awg.blue  = float2( 0.08610, -0.10200);
  awg.white = float2( 0.31270,  0.32900);

  return awg;
}
#define ARRI_ALEXA_WG_PRI _ARRI_ALEXA_WG_PRI()

Chromaticities _REC2020_PRI()
{
  Chromaticities rec2020;
  rec2020.red   = float2( 0.70800,  0.29200);
  rec2020.green = float2( 0.17000,  0.79700);
  rec2020.blue  = float2( 0.13100,  0.04600);
  rec2020.white = float2( 0.31270,  0.32900);

  return rec2020;
}
#define REC2020_PRI _REC2020_PRI()

Chromaticities _RIMMROMM_PRI()
{
  Chromaticities rimmromm;
  rimmromm.red   = float2( 0.7347,  0.2653);
  rimmromm.green = float2( 0.1596,  0.8404);
  rimmromm.blue  = float2( 0.0366,  0.0001);
  rimmromm.white = float2( 0.3457,  0.3585);

  return rimmromm;
}
#define RIMMROMM_PRI _RIMMROMM_PRI()

Chromaticities _SONY_SGAMUT3_PRI()
{
  Chromaticities sgamut3;
  sgamut3.red   = float2( 0.730,   0.280);
  sgamut3.green = float2( 0.140,   0.855);
  sgamut3.blue  = float2( 0.100,  -0.050);
  sgamut3.white = float2( 0.3127,  0.3290);

  return sgamut3;
}
#define SONY_SGAMUT3_PRI _SONY_SGAMUT3_PRI()

Chromaticities _SONY_SGAMUT3_CINE_PRI()
{
  Chromaticities sgamut3_cine;
  sgamut3_cine.red   = float2( 0.766,   0.275);
  sgamut3_cine.green = float2( 0.225,   0.800);
  sgamut3_cine.blue  = float2( 0.089,  -0.087);
  sgamut3_cine.white = float2( 0.3127,  0.3290);
}
#define SONY_SGAMUT3_CINE_PRI _SONY_SGAMUT3_CINE_PRI()

// Note: No official published primaries exist as of this day for the
// Sony VENICE SGamut3 and Sony VENICE SGamut3.Cine colorspaces. The primaries
// have thus been derived from the IDT matrices.
Chromaticities _SONY_VENICE_SGAMUT3_PRI()
{
  Chromaticities venice;
  venice.red   = float2( 0.740464264304292,  0.279364374750660);
  venice.green = float2( 0.089241145423286,  0.893809528608105);
  venice.blue  = float2( 0.110488236673827, -0.052579333080476);
  venice.white = float2( 0.312700000000000,  0.329000000000000);

  return venice;
}
#define SONY_VENICE_SGAMUT3_PRI _SONY_VENICE_SGAMUT3_PRI()

Chromaticities _SONY_VENICE_SGAMUT3_CINE_PRI()
{
  Chromaticities venice_cine;
  venice_cine.red   = float2( 0.775901871567345,  0.274502392854799);
  venice_cine.green = float2( 0.188682902773355,  0.828684937020288);
  venice_cine.blue  = float2( 0.101337382499301, -0.089187517306263);
  venice_cine.white = float2( 0.312700000000000,  0.329000000000000);

  return venice_cine;
}
#define SONY_VENICE_SGAMUT3_CINE_PRI _SONY_VENICE_SGAMUT3_CINE_PRI()

Chromaticities _CANON_CGAMUT_PRI()
{
  Chromaticities cgamut;
  cgamut.red   = float2( 0.7400,  0.2700);
  cgamut.green = float2( 0.1700,  1.1400);
  cgamut.blue  = float2( 0.0800, -0.1000);
  cgamut.white = float2( 0.3127,  0.3290);

  return cgamut;
}
#define CANON_CGAMUT_PRI _CANON_CGAMUT_PRI()

Chromaticities _RED_WIDEGAMUTRGB_PRI()
{
  Chromaticities rwg;
  rwg.red   = float2( 0.780308,  0.304253);
  rwg.green = float2( 0.121595,  1.493994);
  rwg.blue  = float2( 0.095612, -0.084589);
  rwg.white = float2( 0.3127,    0.3290);

  return rwg;
}
#define RED_WIDEGAMUTRGB_PRI _RED_WIDEGAMUTRGB_PRI()

Chromaticities _PANASONIC_VGAMUT_PRI()
{
  Chromaticities vgamut;
  vgamut.red   = float2( 0.730,  0.280);
  vgamut.green = float2( 0.165,  0.840);
  vgamut.blue  = float2( 0.100, -0.030);
  vgamut.white = float2( 0.3127,  0.3290);

  return vgamut;
}
#define PANASONIC_VGAMUT_PRI _PANASONIC_VGAMUT_PRI()

Chromaticities _BMD_CAM_WG_GEN5_PRI()
{
  Chromaticities bmdwg;
  bmdwg.red   = float2( 0.7177215,  0.3171181);
  bmdwg.green = float2( 0.2280410,  0.8615690);
  bmdwg.blue  = float2( 0.1005841, -0.0820452);
  bmdwg.white = float2( 0.3127170,  0.3290312);

  return bmdwg;
}
#define BMD_CAM_WG_GEN5_PRI _BMD_CAM_WG_GEN5_PRI()
#endif

/* ---- Conversion Functions ---- */
// Various transformations between color encodings and data representations
//

// Transformations between CIE XYZ tristimulus values and CIE x,y 
// chromaticity coordinates

/* Both of these are implemented differently but should work exactly the same
 * as the CTL implementations. */

float3 XYZ_2_xyY( float3 XYZ)
{
  float3 xyY;
  float divisor = rcp( max( XYZ.x + XYZ.y + XYZ.z, 1e-10));

  xyY.xy = XYZ.xy * divisor;
  xyY.z = XYZ.y;

  return xyY;
}

float3 xyY_2_XYZ( float3 xyY)
{
  float3 XYZ;
  float divisor = rcp( max( xyY.y, 1e-10));

  XYZ.x = xyY.x * xyY.z * divisor;
  XYZ.y = xyY.z;
  XYZ.z = ( 1. - xyY.x - xyY.y) * xyY.z * divisor;

  return XYZ;
}

// Transformations from RGB to other color representations

/* Note that the "quiet NaN value" is now replaced with zero as NaNs in HLSL
 * are a pesky thing. */

float rgb_2_hue( float3 rgb)
{
  // Returns a geometric hue angle in degrees (0-360) based on RGB values.
  // For neutral colors, hue is undefined and the function will return a quiet NaN value. 

  float hue;

  if ( all( rgb == rgb)) {
    hue = 0.;
  } else {
    hue = ( 180. / M_PI) * atan2( sqrt(3.) * ( rgb.y - rgb.z), 2. * rgb.x - rgb.y - rgb.z);
  }

  if (hue < 0.) hue += 360.;

  return hue;
}

float rgb_2_yc( float3 rgb, float ycRadiusWeight)
{
  // Converts RGB to a luminance proxy, here called YC
  // YC is ~ Y + K * Chroma
  // Constant YC is a cone-shaped surface in RGB space, with the tip on the 
  // neutral axis, towards white.
  // YC is normalized: RGB 1 1 1 maps to YC = 1
  //
  // ycRadiusWeight defaults to 1.75, although can be overridden in function 
  // call to rgb_2_yc
  // ycRadiusWeight = 1 -> YC for pure cyan, magenta, yellow == YC for neutral 
  // of same value
  // ycRadiusWeight = 2 -> YC for pure red, green, blue  == YC for  neutral of 
  // same value.

  float r = rgb.r;
  float g = rgb.g;
  float b = rgb.b;
  float chroma = sqrt( b * ( b - g) + g * ( g - r) + r * ( r - b));
  
  return ( b + g + r + ycRadiusWeight * chroma) / 3.;
}

float rgb_2_yc( float3 rgb)
{
  return rgb_2_yc( rgb, 1.75);
}

/* ---- Chromatic Adaptation ---- */

static const float3x3 CONE_RESP_MAT_BRADFORD = float3x3(
   0.89510, -0.75020,  0.03890,
   0.26640,  1.71350, -0.06850,
  -0.16140,  0.03670,  1.02960
);

static const float3x3 CONE_RESP_MAT_CAT02 = float3x3(
   0.73280, -0.70360,  0.00300,
   0.42960,  1.69750,  0.01360,
  -0.16240,  0.00610,  0.98340
);

float3x3 calculate_cat_matrix
  ( float2 src_xy, // x,y chromaticity of source white
    float2 des_xy, // x,y chromaticity of destination white
    float3x3 coneRespMat
  )
{
  //
  // Calculates and returns a 3x3 Von Kries chromatic adaptation transform 
  // from src_xy to des_xy using the cone response primaries defined 
  // by coneRespMat. By default, coneRespMat is set to CONE_RESP_MAT_BRADFORD. 
  // The default coneRespMat can be overridden at runtime. 
  //

  float3 src_XYZ = xyY_2_XYZ( float3( src_xy, 1.0));
  float3 des_XYZ = xyY_2_XYZ( float3( des_xy, 1.0));

  float3 src_coneResp = mult_f3_f33( src_XYZ, coneRespMat);
  float3 des_coneResp = mult_f3_f33( des_XYZ, coneRespMat);

  float3 vkVec = des_coneResp / src_coneResp;
  float3x3 vkMat = float3x3(
    vkVec[0], 0., 0.,
    0., vkVec[1], 0.,
    0., 0., vkVec[2]
  );

  return mult_f33_f33( coneRespMat, mult_f33_f33( vkMat, invert_f33(coneRespMat)));
}

float3x3 calculate_cat_matrix
  ( float2 src_xy,
    float2 des_xy
  )
{
  return calculate_cat_matrix(src_xy, des_xy, CONE_RESP_MAT_BRADFORD);
}

float3x3 calculate_rgb_to_rgb_matrix
  ( Chromaticities SOURCE_PRIMARIES,
    Chromaticities DEST_PRIMARIES,
    float3x3 coneRespMat
  )
{
  //
  // Calculates and returns a 3x3 RGB-to-RGB matrix from the source primaries to the 
  // destination primaries. The returned matrix is effectively a concatenation of a 
  // conversion of the source RGB values into CIE XYZ tristimulus values, conversion to
  // cone response values or other space in which reconciliation of the encoding white is 
  // done, a conversion back to CIE XYZ tristimulus values, and finally conversion from 
  // CIE XYZ tristimulus values to the destination RGB values.
  //
  // By default, coneRespMat is set to CONE_RESP_MAT_BRADFORD. 
  // The default coneRespMat can be overridden at runtime. 
  //

  const float3x3 RGBtoXYZ_MAT = RGBtoXYZ( SOURCE_PRIMARIES, 1.0);

  // Chromatic adaptation from source white to destination white chromaticity
  // Bradford cone response matrix is the default method
  const float3x3 CAT = calculate_cat_matrix( SOURCE_PRIMARIES.white,
                                             DEST_PRIMARIES.white,
                                             coneRespMat);

  const float3x3 XYZtoRGB_MAT = XYZtoRGB( DEST_PRIMARIES, 1.);

  return mult_f33_f33( RGBtoXYZ_MAT, mult_f33_f33( CAT, XYZtoRGB_MAT));
}

float3x3 calculate_rgb_to_rgb_matrix
  ( Chromaticities SOURCE_PRIMARIES,
    Chromaticities DEST_PRIMARIES
  )
{
  return calculate_rgb_to_rgb_matrix(SOURCE_PRIMARIES, DEST_PRIMARIES, CONE_RESP_MAT_BRADFORD);
}

float3x3 calc_sat_adjust_matrix
  ( float sat,
    float3 rgb2Y
  )
{
  //
  // This function determines the terms for a 3x3 saturation matrix that is
  // based on the luminance of the input.
  //

  float3x3 M;

  M[0][0] = ( 1. - sat) * rgb2Y[0] + sat;
  M[1][0] = ( 1. - sat) * rgb2Y[0];
  M[2][0] = ( 1. - sat) * rgb2Y[0];
  
  M[0][1] = ( 1. - sat) * rgb2Y[1];
  M[1][1] = ( 1. - sat) * rgb2Y[1] + sat;
  M[2][1] = ( 1. - sat) * rgb2Y[1];
  
  M[0][2] = ( 1. - sat) * rgb2Y[2];
  M[1][2] = ( 1. - sat) * rgb2Y[2];
  M[2][2] = ( 1. - sat) * rgb2Y[2] + sat;

  M = transpose_f33(M);

  return M;
}

/* ---- Signal encode/decode functions ---- */

float moncurve_f( float x, float gamma, float offs)
{
  // Forward monitor curve
  float y;
  const float fs = (( gamma - 1.0) / offs) * pow( offs * gamma / ( ( gamma - 1.0) * ( 1.0 + offs)), gamma);
  const float xb = offs / ( gamma - 1.0);

  if ( x >= xb)
    y = pow( ( x + offs) / ( 1.0 + offs), gamma);
  else
    y = x * fs;
  
  return y;
}

float moncurve_r( float y, float gamma, float offs)
{
  // Reverse monitor curve
  float x;
  const float yb = pow( offs * gamma / ( ( gamma - 1.0) * ( 1.0 + offs)), gamma);
  const float rs = pow( ( gamma - 1.0) / offs, gamma - 1.0) * pow( ( 1.0 + offs) / gamma, gamma);

  if ( y >= yb)
    x = ( 1.0 + offs) * pow( y, 1.0 / gamma) - offs;
  else
    x = y * rs;

  return x;
}

float3 moncurve_f_f3( float3 x, float gamma, float offs)
{
  float3 y;

  y.r = moncurve_f( x.r, gamma, offs);
  y.g = moncurve_f( x.g, gamma, offs);
  y.b = moncurve_f( x.b, gamma, offs);

  return y;
}

float3 moncurve_r_f3( float3 y, float gamma, float offs)
{
  float3 x;

  x.r = moncurve_r( y.r, gamma, offs);
  x.g = moncurve_r( y.g, gamma, offs);
  x.b = moncurve_r( y.b, gamma, offs);

  return x;
}

float bt1886_f( float V, float gamma, float Lw, float Lb)
{
  // The reference EOTF specified in Rec. ITU-R BT.1886
  // L = a(max[(V+b),0])^g
  float a = pow( pow( Lw, rcp( gamma)) - pow( Lb, rcp( gamma)), gamma);
  float b = pow( Lb, rcp(gamma)) / ( pow( Lw, rcp( gamma)) - pow( Lb, rcp( gamma)));
  float L = a * pow( max( V + b, 0.), gamma);
  return L;
}

float bt1886_r( float L, float gamma, float Lw, float Lb)
{
  // The reference EOTF specified in Rec. ITU-R BT.1886
  // L = a(max[(V+b),0])^g
  float a = pow( pow( Lw, rcp( gamma)) - pow( Lb, rcp( gamma)), gamma);
  float b = pow( Lb, rcp( gamma)) / ( pow( Lw, rcp( gamma)) - pow( Lb, rcp( gamma)));
  float V = pow( max( L / a, 0.), rcp( gamma)) - b;
  return V;
}

float3 bt1886_f_f3( float3 V, float gamma, float Lw, float Lb)
{
  float3 L;
  L.x = bt1886_f( V.x, gamma, Lw, Lb);
  L.y = bt1886_f( V.y, gamma, Lw, Lb);
  L.z = bt1886_f( V.z, gamma, Lw, Lb);
  return L;
}

float3 bt1886_r_f3( float3 L, float gamma, float Lw, float Lb)
{
  float3 V;
  V.x = bt1886_r( L.x, gamma, Lw, Lb);
  V.y = bt1886_r( L.y, gamma, Lw, Lb);
  V.z = bt1886_r( L.z, gamma, Lw, Lb);
  return V;
}

// SMPTE Range vs Full Range scaling formulas
float smpteRange_to_fullRange( float _in)
{
  const float REFBLACK = (  64. / 1023.);
  const float REFWHITE = ( 940. / 1023.);

  return (( _in - REFBLACK) / (REFWHITE - REFBLACK));
}

float fullRange_to_smpteRange( float _in)
{
  const float REFBLACK = (  64. / 1023.);
  const float REFWHITE = ( 940. / 1023.);

  return ( _in * ( REFWHITE - REFBLACK) + REFBLACK);
}

float3 smpteRange_to_fullRange_f3( float3 rgbIn)
{
  float3 rgbOut;
  rgbOut.r = smpteRange_to_fullRange( rgbIn.r);
  rgbOut.g = smpteRange_to_fullRange( rgbIn.g);
  rgbOut.b = smpteRange_to_fullRange( rgbIn.b);

  return rgbOut;
}

float3 fullRange_to_smpteRange_f3( float3 rgbIn)
{
  float3 rgbOut;
  rgbOut.r = fullRange_to_smpteRange( rgbIn.r);
  rgbOut.g = fullRange_to_smpteRange( rgbIn.g);
  rgbOut.b = fullRange_to_smpteRange( rgbIn.b);

  return rgbOut;
}

// SMPTE 431-2 defines the DCDM color encoding equations. 
// The equations for the decoding of the encoded color information are the 
// inverse of the encoding equations
// Note: Here the 4095 12-bit scalar is not used since the output of CTL is 0-1.
float3 dcdm_decode( float3 XYZp)
{
  const float d = ( 52.37 / 48.);
  float3 XYZ;
  XYZ.x = d * pow( XYZp.x, 2.6);
  XYZ.y = d * pow( XYZp.y, 2.6);
  XYZ.z = d * pow( XYZp.z, 2.6);

  return XYZ;
}

float3 dcdm_encode( float3 XYZ)
{
  const float d = ( 48. / 52.37);
  const float g = 1./2.6;
  float3 XYZp;
  XYZp.x = d * pow( d * XYZ.x, g);
  XYZp.y = d * pow( d * XYZ.y, g);
  XYZp.z = d * pow( d * XYZ.z, g);

  return XYZp;
}

// Base functions from SMPTE ST 2084-2014

// Constants from SMPTE ST 2084-2014
static const float pq_m1 = 0.1593017578125; // ( 2610.0 / 4096.0 ) / 4.0;
static const float pq_m2 = 78.84375; // ( 2523.0 / 4096.0 ) * 128.0;
static const float pq_c1 = 0.8359375; // 3424.0 / 4096.0 or pq_c3 - pq_c2 + 1.0;
static const float pq_c2 = 18.8515625; // ( 2413.0 / 4096.0 ) * 32.0;
static const float pq_c3 = 18.6875; // ( 2392.0 / 4096.0 ) * 32.0;

static const float pq_C = 10000.;

// Converts from the non-linear perceptually quantized space to linear cd/m^2
// Note that this is in float, and assumes normalization from 0 - 1
// (0 - pq_C for linear) and does not handle the integer coding in the Annex 
// sections of SMPTE ST 2084-2014
float ST2084_2_Y( float N)
{
  // Note that this does NOT handle any of the signal range
  // considerations from 2084 - this assumes full range (0 - 1)
  float Np = pow( N, rcp( pq_m2));
  float L = Np - pq_c1;

  if ( L < 0.0)
    L = 0.0;
  
  L /= pq_c2 - pq_c3 * Np;
  L = pow( L, rcp(pq_m1));

  return L * pq_C;
}

// Converts from linear cd/m^2 to the non-linear perceptually quantized space
// Note that this is in float, and assumes normalization from 0 - 1
// (0 - pq_C for linear) and does not handle the integer coding in the Annex 
// sections of SMPTE ST 2084-2014
float Y_2_ST2084( float C)
{
  // Note that this does NOT handle any of the signal range
  // considerations from 2084 - this returns full range (0 - 1)
  float L = C / pq_C;
  float Lm = pow( L, pq_m1);
  float N = ( pq_c1 + pq_c2 * Lm) / ( 1. + pq_c3 * Lm);
  N = pow( N, pq_m2);

  return N;
}

float3 Y_2_ST2084_f3( float3 _in)
{
  // converts from linear cd/m^2 to PQ cod

  float3 _out;
  _out.x = Y_2_ST2084( _in.x);
  _out.y = Y_2_ST2084( _in.y);
  _out.z = Y_2_ST2084( _in.z);

  return _out;
}

float3 ST2084_2_Y_f3( float3 _in)
{
  // converts from linear cd/m^2 to PQ cod

  float3 _out;
  _out.x = ST2084_2_Y( _in.x);
  _out.y = ST2084_2_Y( _in.y);
  _out.z = ST2084_2_Y( _in.z);

  return _out;
}

// Conversion of PQ signal to HLG, as detailed in Section 7 of ITU-R BT.2390-0
float3 ST2084_2_HLG_1000nits_f3( float3 PQ)
{
  // ST.2084 EOTF (non-linear PQ to display light)
  float3 displayLinear = ST2084_2_Y_f3( PQ);

  // HLG Inverse EOTF (i.e. HLG inverse OOTF followed by the HLG OETF)
  // HLG Inverse OOTF (display linear to scene linear)
  float Y_d = dot( displayLinear, float3( 0.2627, 0.6780, 0.0593));
  const float L_w = 1000.;
  const float L_b = 0.;
  const float alpha = ( L_w - L_b);
  const float beta = L_b;
  const float gamma = 1.2;

  float3 sceneLinear;
  if (Y_d == 0.) {
    /* This case is to protect against pow(0,-N)=Inf error. The ITU document
     * does not offer a recommendation for this corner case. There may be a 
     * better way to handle this, but for now, this works. */

    sceneLinear = 0.;
  } else {
    sceneLinear = pow( ( Y_d - beta) / alpha, ( 1. - gamma) / gamma) * ( ( displayLinear - beta) / alpha);
  }

  // HLG OETF (scene linear to non-linear signal value)
  const float a = 0.17883277;
  const float b = 0.28466892; // 1.-4.*a;
  const float c = 0.55991073; // 0.5-a*log(4.*a);

  float3 HLG = sceneLinear <= rcp( 12.) ? sqrt( 3. * sceneLinear) : a * log( 12. * sceneLinear - b) + c;

  return HLG;
}

// Conversion of HLG to PQ signal, as detailed in Section 7 of ITU-R BT.2390-0
float3 HLG_2_ST2084_1000nits_f3( float3 HLG)
{
  const float a = 0.17883277;
  const float b = 0.28466892; // 1.-4.*a;
  const float c = 0.55991073; // 0.5-a*log(4.*a);

  const float L_w = 1000.;
  const float L_b = 0.;
  const float alpha = ( L_w - L_b);
  const float beta = L_b;
  const float gamma = 1.2;

  // HLG EOTF (non-linear signal value to display linear)
  // HLG to scene linear
  float3 sceneLinear = ( HLG >= 0. && HLG <= 0.5) ? ( HLG * HLG) / 3. : ( exp( (HLG - c) / a) + b) / 12.;

  float Y_s = dot( sceneLinear, float3( 0.2627, 0.6780, 0.0593));

  // Scene-linear to display-linear
  float3 displayLinear;
  displayLinear = alpha * pow( Y_s, gamma - 1.) * sceneLinear + beta;

  // ST.2084 Inverse EOTF
  float3 PQ = Y_2_ST2084_f3( displayLinear);

  return PQ;
}

#endif // _ACES_LIB_UTILITIES_COLOR