// @maintainer jwrl
// @released 2019-02-16
// @author jwrl
// @created 2019-02-16
// @see [LINK TO PNG OR JPEG]

/**
 This is a swirl effect similar to schrauber's swirl mix, but optimised for titles.
 To that end it has an adjustable axis of rotation and no matter how the spin axis
 and swirl settings are adjusted the distorted image will always stay within the
 frame boundaries.  If the swirl setting is set to zero the image will simply rotate
 around the spin axis.  The spin axis may be set using faders, or may be dragged
 interactively with the mouse in the sequence viewer.

 There are differences in the settings other than those just described.  The "Fill
 gaps" setting is pointless with a title, so it has been discarded.  In its place
 is a new setting, "Start angle".  There's no real reason for that latter setting,
 it just semed like a good idea.

 THIS EFFECT IS DESIGNED FOR LIGHTWORKS VERSION 14.5 AND UP.
*/

//-----------------------------------------------------------------------------------------//
// Lightworks user effect Vortex.fx
//
//    ***  PLACE REVISION HISTORY HERE  ***
//-----------------------------------------------------------------------------------------//

int _LwksEffectInfo
<
   string EffectGroup = "GenericPixelShader";
   string Description = "Swirl mix (alpha)";
   string Category    = "Mix";
   string SubCategory = "Blur transitions";
   string Notes       = "A swirl mix effect for titles which always stays within frame boundaries";
> = 0;

//-----------------------------------------------------------------------------------------//
// Inputs
//-----------------------------------------------------------------------------------------//

texture Fg;
texture Bg;

//-----------------------------------------------------------------------------------------//
// Samplers
//-----------------------------------------------------------------------------------------//

sampler s_Foreground = sampler_state { Texture = <Fg>; };
sampler s_Background = sampler_state { Texture = <Bg>; };

//-----------------------------------------------------------------------------------------//
// Parameters
//-----------------------------------------------------------------------------------------//

int Boost
<
   string Description = "If using a Lightworks text effect disconnect its input and set this first";
   string Enum = "Crawl/Roll/Titles,Background/External image";
> = 0;

float Amount
<
   string Description = "Amount";
   float MinVal = 0.0;
   float MaxVal = 1.0;
   float KF0    = 0.0;
   float KF1    = 1.0;
> = 0.5;

int Direction
<
   string Description = "Transition";
   string Enum = "Whirl in,Whirl out,";
> = 0;

float Amplitude
<
   string Group = "Swirl settings";
   string Description = "Swirl depth";
   float MinVal = -1.0;
   float MaxVal = 1.0;
> = 0.5;

float Rate
<
   string Group = "Swirl settings";
   string Description = "Revolutions";
   float MinVal = 0.0;
   float MaxVal = 10.0;
> = 0.0;

float Start
<
   string Group = "Swirl settings";
   string Description = "Start angle";
   float MinVal = 0.0;
   float MaxVal = 360.0;
> = 0.0;

float CentreX
<
   string Description = "Spin axis";
   string Flags = "SpecifiesPointX";
   float MinVal = 0.0;
   float MaxVal = 1.0;
> = 0.5;

float CentreY
<
   string Description = "Spin axis";
   string Flags = "SpecifiesPointY";
   float MinVal = 0.0;
   float MaxVal = 1.0;
> = 0.5;

//-----------------------------------------------------------------------------------------//
// Definitions and declarations
//-----------------------------------------------------------------------------------------//

#ifndef _LENGTH   // This effect is only available for version 14.5 and up
Bad_LW_version    // Forces a compiler error if the Lightworks version is less.
#endif

#define TWO_PI  6.2831853072
#define PI     3.1415926536
#define HALF_PI 1.5707963268

float _Length;
float _Progress;

//-----------------------------------------------------------------------------------------//
// Functions
//-----------------------------------------------------------------------------------------//

float4 fn_tex2D (sampler s_Input, float2 uv)
{
   float4 retval = tex2D (s_Input, uv);

   if (Boost == 0) {
      retval.a    = pow (retval.a, 0.5);
      retval.rgb /= retval.a;
   }

   return retval;
}

//-----------------------------------------------------------------------------------------//
// Shaders
//-----------------------------------------------------------------------------------------//

float4 ps_main (float2 uv : TEXCOORD1) : COLOR
{
   float2 centre = float2 (CentreX, 1.0 - CentreY);
   float2 xy, xy1 = uv - centre;

   float amount, prgrss;

   if (Direction == 0) {
      amount = Amount;
      prgrss = 1.0 - _Progress;
   }
   else {
      amount = 1.0 - Amount;
      prgrss = _Progress;
   }

   float angle = (length (xy1) * Amplitude * TWO_PI) + radians (Start);
   float scale0, scale90;

   sincos (angle + (Rate * _Length * prgrss * PI), scale90, scale0);

   prgrss = sin (saturate (prgrss * 3.0) * HALF_PI);
   amount = sin (amount * HALF_PI);
   xy = (xy1 * scale0) - (float2 (xy1.y, -xy1.x) * scale90) + centre;
//   xy = lerp (uv, xy, prgrss);

   float4 Fgnd = fn_tex2D (s_Foreground, xy);

   return lerp (tex2D (s_Background, uv), Fgnd, Fgnd.a /* amount */ );
}

//-----------------------------------------------------------------------------------------//
// Techniques
//-----------------------------------------------------------------------------------------//

technique Vortex
{
   pass P_1
   { PixelShader = compile PROFILE ps_main (); }
}
