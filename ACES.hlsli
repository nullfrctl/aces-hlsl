#ifndef _ACES_
#define _ACES_

/* NOTE: Libraries have to be imported in this specific order for frameworks
 * like ENBSeries. Another note for ENBSeries, instead of including this,
 * copy everything after `// clang-format off` to before `// clang-format on`
 * (including those lines). */

// clang-format off

// Import libraries
#include "lib/ACESlib.CTL.hlsl"
#include "lib/ACESlib.Utilities.hlsl"
#include "lib/ACESlib.Utilities_Color.hlsl"
#include "lib/ACESlib.Transform_Common.hlsl"
#include "lib/ACESlib.ODT_Common.hlsl"
#include "lib/ACESlib.RRT_Common.hlsl"
#include "lib/ACESlib.Tonescales.hlsl"
// #include "lib/ACESlib.SSTS.hlsl"
// #include "lib/ACESlib.OutputTransforms.hlsl"

// Import CSC
#include "csc/ACEScc/ACEScsc.Academy.ACES_to_ACEScc.hlsl"
#include "csc/ACEScc/ACEScsc.Academy.ACEScc_to_ACES.hlsl"
#include "csc/ACEScct/ACEScsc.Academy.ACES_to_ACEScct.hlsl"
#include "csc/ACEScct/ACEScsc.Academy.ACEScct_to_ACES.hlsl"
#include "csc/ACEScg/ACEScsc.Academy.ACES_to_ACEScg.hlsl"
#include "csc/ACEScg/ACEScsc.Academy.ACEScg_to_ACES.hlsl"

// Import RRT
#include "rrt/RRT.hlsl"
#include "rrt/InvRRT.hlsl"

// Import ODT
#include "odt/sRGB/ODT.Academy.sRGB_100nits_dim.hlsl"
#include "odt/sRGB/ODT.Academy.sRGB_D60sim_100nits_dim.hlsl"

// clang-format on

#endif // _ACES_