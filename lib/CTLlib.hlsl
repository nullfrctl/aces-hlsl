#ifndef _CTL_LIB
#define _CTL_LIB

#define M_PI 3.14159265359

float fabs( float a1)
{
  return abs(a1);
}

float pow10( float a1)
{
  return pow( 10., a1);
}

float3 mult_f_f3(float a1, float3 a2)
{
  return a1 * a2;
}

float3x3 mult_f33_f33(float3x3 a1, float3x3 a2)
{
  return mul(a1, a2);
}

float4x4 mult_f44_f44(float4x4 a1, float4x4 a2)
{
  return mul(a1, a2);
}

float3x3 mult_f_f33(float a1, float3x3 a2)
{
  return mul(a1, a2);
}

float4x4 mult_f_f44(float a1, float4x4 a2)
{
  return mul(a1, a2);
}

float3 mult_f3_f33(float3 a1, float3x3 a2)
{
  return mul(a1, a2);
}

float3x3 transpose_f33(float3x3 a1)
{
  return transpose(a1);
}

float4x4 transpose_f44(float4x4 a1)
{
  return transpose(a1);
}

float dot_f3_f3(float3 a1, float3 a2)
{
  return dot(a1, a2);
}

float3x3 invert_f33(float3x3 m)
{
  float3x3 adj;
  adj[0][0] =  (m[1][1] * m[2][2] - m[1][2] * m[2][1]); 
  adj[0][1] = -(m[0][1] * m[2][2] - m[0][2] * m[2][1]); 
  adj[0][2] =  (m[0][1] * m[1][2] - m[0][2] * m[1][1]);
  adj[1][0] = -(m[1][0] * m[2][2] - m[1][2] * m[2][0]);
  adj[1][1] =  (m[0][0] * m[2][2] - m[0][2] * m[2][0]); 
  adj[1][2] = -(m[0][0] * m[1][2] - m[0][2] * m[1][0]);
  adj[2][0] =  (m[1][0] * m[2][1] - m[1][1] * m[2][0]); 
  adj[2][1] = -(m[0][0] * m[2][1] - m[0][1] * m[2][0]); 
  adj[2][2] =  (m[0][0] * m[1][1] - m[0][1] * m[1][0]); 

  float det = dot(float3(adj[0][0], adj[0][1], adj[0][2]), float3(m[0][0], m[1][0], m[2][0]));
  return adj * rcp(det + (abs(det) < 1e-8));
}

float4x4 invert_f44(float4x4 m)  
{
  float4x4 adj;
  adj[0][0] = m[2][1] * m[3][2] * m[1][3] - m[3][1] * m[2][2] * m[1][3] + m[3][1] * m[1][2] * m[2][3] - m[1][1] * m[3][2] * m[2][3] - m[2][1] * m[1][2] * m[3][3] + m[1][1] * m[2][2] * m[3][3];
  adj[0][1] = m[3][1] * m[2][2] * m[0][3] - m[2][1] * m[3][2] * m[0][3] - m[3][1] * m[0][2] * m[2][3] + m[0][1] * m[3][2] * m[2][3] + m[2][1] * m[0][2] * m[3][3] - m[0][1] * m[2][2] * m[3][3];
  adj[0][2] = m[1][1] * m[3][2] * m[0][3] - m[3][1] * m[1][2] * m[0][3] + m[3][1] * m[0][2] * m[1][3] - m[0][1] * m[3][2] * m[1][3] - m[1][1] * m[0][2] * m[3][3] + m[0][1] * m[1][2] * m[3][3];
  adj[0][3] = m[2][1] * m[1][2] * m[0][3] - m[1][1] * m[2][2] * m[0][3] - m[2][1] * m[0][2] * m[1][3] + m[0][1] * m[2][2] * m[1][3] + m[1][1] * m[0][2] * m[2][3] - m[0][1] * m[1][2] * m[2][3];

  adj[1][0] = m[3][0] * m[2][2] * m[1][3] - m[2][0] * m[3][2] * m[1][3] - m[3][0] * m[1][2] * m[2][3] + m[1][0] * m[3][2] * m[2][3] + m[2][0] * m[1][2] * m[3][3] - m[1][0] * m[2][2] * m[3][3];
  adj[1][1] = m[2][0] * m[3][2] * m[0][3] - m[3][0] * m[2][2] * m[0][3] + m[3][0] * m[0][2] * m[2][3] - m[0][0] * m[3][2] * m[2][3] - m[2][0] * m[0][2] * m[3][3] + m[0][0] * m[2][2] * m[3][3];
  adj[1][2] = m[3][0] * m[1][2] * m[0][3] - m[1][0] * m[3][2] * m[0][3] - m[3][0] * m[0][2] * m[1][3] + m[0][0] * m[3][2] * m[1][3] + m[1][0] * m[0][2] * m[3][3] - m[0][0] * m[1][2] * m[3][3];
  adj[1][3] = m[1][0] * m[2][2] * m[0][3] - m[2][0] * m[1][2] * m[0][3] + m[2][0] * m[0][2] * m[1][3] - m[0][0] * m[2][2] * m[1][3] - m[1][0] * m[0][2] * m[2][3] + m[0][0] * m[1][2] * m[2][3];

  adj[2][0] = m[2][0] * m[3][1] * m[1][3] - m[3][0] * m[2][1] * m[1][3] + m[3][0] * m[1][1] * m[2][3] - m[1][0] * m[3][1] * m[2][3] - m[2][0] * m[1][1] * m[3][3] + m[1][0] * m[2][1] * m[3][3];
  adj[2][1] = m[3][0] * m[2][1] * m[0][3] - m[2][0] * m[3][1] * m[0][3] - m[3][0] * m[0][1] * m[2][3] + m[0][0] * m[3][1] * m[2][3] + m[2][0] * m[0][1] * m[3][3] - m[0][0] * m[2][1] * m[3][3];
  adj[2][2] = m[1][0] * m[3][1] * m[0][3] - m[3][0] * m[1][1] * m[0][3] + m[3][0] * m[0][1] * m[1][3] - m[0][0] * m[3][1] * m[1][3] - m[1][0] * m[0][1] * m[3][3] + m[0][0] * m[1][1] * m[3][3];
  adj[2][3] = m[2][0] * m[1][1] * m[0][3] - m[1][0] * m[2][1] * m[0][3] - m[2][0] * m[0][1] * m[1][3] + m[0][0] * m[2][1] * m[1][3] + m[1][0] * m[0][1] * m[2][3] - m[0][0] * m[1][1] * m[2][3];

  adj[3][0] = m[3][0] * m[2][1] * m[1][2] - m[2][0] * m[3][1] * m[1][2] - m[3][0] * m[1][1] * m[2][2] + m[1][0] * m[3][1] * m[2][2] + m[2][0] * m[1][1] * m[3][2] - m[1][0] * m[2][1] * m[3][2];
  adj[3][1] = m[2][0] * m[3][1] * m[0][2] - m[3][0] * m[2][1] * m[0][2] + m[3][0] * m[0][1] * m[2][2] - m[0][0] * m[3][1] * m[2][2] - m[2][0] * m[0][1] * m[3][2] + m[0][0] * m[2][1] * m[3][2];
  adj[3][2] = m[3][0] * m[1][1] * m[0][2] - m[1][0] * m[3][1] * m[0][2] - m[3][0] * m[0][1] * m[1][2] + m[0][0] * m[3][1] * m[1][2] + m[1][0] * m[0][1] * m[3][2] - m[0][0] * m[1][1] * m[3][2];
  adj[3][3] = m[1][0] * m[2][1] * m[0][2] - m[2][0] * m[1][1] * m[0][2] + m[2][0] * m[0][1] * m[1][2] - m[0][0] * m[2][1] * m[1][2] - m[1][0] * m[0][1] * m[2][2] + m[0][0] * m[1][1] * m[2][2];

  float det = dot(float4(adj[0][0], adj[1][0], adj[2][0], adj[3][0]), float4(m[0][0], m[0][1],  m[0][2],  m[0][3]));
  return adj * rcp(det + (abs(det) < 1e-8));
}

struct Chromaticities
{
  float2 red;
  float2 green;
  float2 blue;
  float2 white;
};

float3x3 RGBtoXYZ( const Chromaticities chroma, float Y)
{
  //
  // X and Z values of RGB value (1, 1, 1), or "white"
  //

  float X = chroma.white.x * Y / chroma.white.y;
  float Z = ( 1. - chroma.white.x - chroma.white.y) * Y / chroma.white.y;

  //
  // Scale factors for matrix rows
  //

  float d = chroma.red.x * ( chroma.blue.y - chroma.green.y) +
      chroma.blue.x  * ( chroma.green.y - chroma.red.y) +
      chroma.green.x * ( chroma.red.y - chroma.blue.y);

  float Sr = ( X * ( chroma.blue.y - chroma.green.y) -
  chroma.green.x * ( Y * ( chroma.blue.y - 1.) +
  chroma.blue.y  * ( X + Z)) +
  chroma.blue.x  * ( Y * ( chroma.green.y - 1.) +
  chroma.green.y * ( X + Z))) / d;

  float Sg = ( X * ( chroma.red.y - chroma.blue.y) +
  chroma.red.x   * ( Y * ( chroma.blue.y - 1.) +
  chroma.blue.y  * ( X + Z)) -
  chroma.blue.x  * ( Y * ( chroma.red.y - 1.) +
  chroma.red.y   * ( X + Z))) / d;

  float Sb = ( X * ( chroma.green.y - chroma.red.y) -
  chroma.red.x   * ( Y * ( chroma.green.y - 1.) +
  chroma.green.y * ( X + Z)) +
  chroma.green.x * ( Y * ( chroma.red.y - 1.) +
  chroma.red.y   * ( X + Z))) / d;

  //
  // Assemble the matrix
  //

  float3x3 M;

  M[0][0] = Sr * chroma.red.x;
  M[0][1] = Sr * chroma.red.y;
  M[0][2] = Sr * ( 1. - chroma.red.x - chroma.red.y);

  M[1][0] = Sg * chroma.green.x;
  M[1][1] = Sg * chroma.green.y;
  M[1][2] = Sg * ( 1. - chroma.green.x - chroma.green.y);

  M[2][0] = Sb * chroma.blue.x;
  M[2][1] = Sb * chroma.blue.y;
  M[2][2] = Sb * ( 1. - chroma.blue.x - chroma.blue.y);

  return M;
}

float3x3 XYZtoRGB( const Chromaticities chroma, float Y)
{
  return invert_f33(RGBtoXYZ(chroma, Y));
}

#endif // _CTL_LIB