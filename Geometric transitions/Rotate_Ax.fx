// @Maintainer jwrl
// @Released 2020-07-31
// @Author jwrl
// @Created 2018-06-12
// @see https://www.lwks.com/media/kunena/attachments/6375/Ax_Rotate_640.png
// @see https://www.lwks.com/media/kunena/attachments/6375/Ax_Rotate.mp4

/**
 This rotates the title out or in.  Alpha levels can be boosted to support Lightworks
 titles, which is the default setting.
*/

//-----------------------------------------------------------------------------------------//
// Lightworks user effect Rotate_Ax.fx
//
// This is a revision of an earlier effect, Adx_Rotate.fx, which also had the ability to
// transition between two titles.  That added needless complexity since the same result
// can be obtained by overlaying two effects.
//
// Version history:
//
// Modified 2020-07-31 jwrl.
// Reworded Boost text to match requirements for 2020.1 and up.
// Reworded Transition text to match requirements for 2020.1 and up.
// Move Boost code into separate shader so that the foreground is always correct.
//
// Modified 23 December 2018 jwrl.
// Reformatted the effect description for markup purposes.
//
// Modified 13 December 2018 jwrl.
// Changed effect name.
// Changed subcategory.
//-----------------------------------------------------------------------------------------//

int _LwksEffectInfo
<
   string EffectGroup = "GenericPixelShader";
   string Description = "Rotate (alpha)";
   string Category    = "Mix";
   string SubCategory = "Geometric transitions";
   string Notes       = "Rotates a title in or out";
> = 0;

//-----------------------------------------------------------------------------------------//
// Inputs
//-----------------------------------------------------------------------------------------//

texture Sup;
texture Vid;

texture Super : RenderColorTarget;

//-----------------------------------------------------------------------------------------//
// Samplers
//-----------------------------------------------------------------------------------------//

sampler s_Foreground = sampler_state { Texture = <Sup>; };
sampler s_Background = sampler_state { Texture = <Vid>; };

sampler s_Super = sampler_state
{
   Texture   = <Super>;
   AddressU  = Mirror;
   AddressV  = Mirror;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;
};

//-----------------------------------------------------------------------------------------//
// Parameters
//-----------------------------------------------------------------------------------------//

int Boost
<
   string Description = "Lightworks effects: Disconnect the input and select";
   string Enum = "Crawl/Roll/Title/Image key,Video/External image";
> = 0;

float Amount
<
   string Description = "Amount";
   float MinVal = 0.0;
   float MaxVal = 1.0;
   float KF0    = 0.0;
   float KF1    = 1.0;
> = 0.5;

int Ttype
<
   string Description = "Transition position";
   string Enum = "At start of clip,At end of clip";
> = 0;

int SetTechnique
<
   string Description = "Transition type";
   string Enum = "Rotate Right,Rotate Down,Rotate Left,Rotate Up";
> = 0;

//-----------------------------------------------------------------------------------------//
// Definitions and declarations
//-----------------------------------------------------------------------------------------//

#define FX_OUT  1

#define HALF_PI 1.5707963268

#define EMPTY   (0.0).xxxx

//-----------------------------------------------------------------------------------------//
// Functions
//-----------------------------------------------------------------------------------------//

float4 fn_tex2D (sampler Vsample, float2 uv)
{
   if ((uv.x < 0.0) || (uv.y < 0.0) || (uv.x > 1.0) || (uv.y > 1.0)) return EMPTY;

   return tex2D (Vsample, uv);
}

//-----------------------------------------------------------------------------------------//
// Shaders
//-----------------------------------------------------------------------------------------//

float4 ps_keygen (float2 uv : TEXCOORD1) : COLOR
{
   float4 retval = tex2D (s_Foreground, uv);

   if (Boost == 0) {
      retval.a = pow (retval.a, 0.5);
      retval.rgb /= retval.a;
   }

   return retval;
}

float4 ps_rotate_right (float2 uv : TEXCOORD1) : COLOR
{
   float2 xy;

   if (Ttype == FX_OUT) { xy = (Amount == 1.0) ? float2 (2.0, uv.y)
                             : float2 ((uv.x - 1.0) / (1.0 - Amount) - (Amount * 0.2) + 1.0,
                                       ((uv.y - 0.5) * (1.0 + Amount)) + 0.5 + (0.5 - uv.y) * uv.x * sin (Amount * HALF_PI)); }
   else { xy = (Amount == 0.0) ? float2 (2.0, uv.y)
             : float2 ((uv.x / Amount) - ((1.0 - Amount) * 0.2),
                       ((uv.y - 0.5) / (2.0 - Amount)) + 0.5 + (0.5 - uv.y) * uv.x * cos (Amount * HALF_PI)); }

   float4 Fgnd = fn_tex2D (s_Super, xy);

   return lerp (tex2D (s_Background, uv), Fgnd, Fgnd.a);
}

float4 ps_rotate_left (float2 uv : TEXCOORD1) : COLOR
{
   float2 xy;

   if (Ttype == FX_OUT) { xy = (Amount == 1.0) ? float2 (2.0, uv.y)
                             : float2 (uv.x / (1.0 - Amount) + (Amount * 0.2),
                                       ((uv.y - 0.5) * (1.0 + Amount)) + 0.5 + (0.5 - uv.y) * (1.0 - uv.x) * sin (Amount * HALF_PI)); }
   else { xy = (Amount == 0.0) ? float2 (2.0, uv.y)
             : float2 ((uv.x - 1.0) / Amount + 1.0 + ((1.0 - Amount) * 0.2),
                       ((uv.y - 0.5) / (2.0 - Amount)) + 0.5 + (0.5 - uv.y) * (1.0 - uv.x) * cos (Amount * HALF_PI)); }

   float4 Fgnd = fn_tex2D (s_Super, xy);

   return lerp (tex2D (s_Background, uv), Fgnd, Fgnd.a);
}

float4 ps_rotate_down (float2 uv : TEXCOORD1) : COLOR
{
   float2 xy;

   if (Ttype == FX_OUT) { xy = (Amount == 1.0) ? float2 (2.0, uv.y)
                             : float2 (((uv.x - 0.5) * (1.0 + Amount)) + 0.5 + (0.5 - uv.x) * uv.y * sin (Amount * HALF_PI),
                                       (uv.y - 1.0) / (1.0 - Amount) - (Amount * 0.2) + 1.0); }
   else { xy = (Amount == 0.0) ? float2 (2.0, uv.y)
             : float2 (((uv.x - 0.5) / (2.0 - Amount)) + 0.5 + (0.5 - uv.x) * uv.y * cos (Amount * HALF_PI),
                       (uv.y / Amount) - ((1.0 - Amount) * 0.2)); }

   float4 Fgnd = fn_tex2D (s_Super, xy);

   return lerp (tex2D (s_Background, uv), Fgnd, Fgnd.a);
}

float4 ps_rotate_up (float2 uv : TEXCOORD1) : COLOR
{
   float2 xy;

   if (Ttype == FX_OUT) { xy = (Amount == 1.0) ? float2 (2.0, uv.y)
                             : float2 (((uv.x - 0.5) * (1.0 + Amount)) + 0.5 + (0.5 - uv.x) * (1.0 - uv.y) * sin (Amount * HALF_PI),
                                       uv.y / (1.0 - Amount) + (Amount * 0.2)); }
   else { xy = (Amount == 0.0) ? float2 (2.0, uv.y)
             : float2 (((uv.x - 0.5) / (2.0 - Amount)) + 0.5 + (0.5 - uv.x) * (1.0 - uv.y) * cos (Amount * HALF_PI),
                                         (uv.y - 1.0) / Amount + 1.0 + ((1.0 - Amount) * 0.2)); }

   float4 Fgnd = fn_tex2D (s_Super, xy);

   return lerp (tex2D (s_Background, uv), Fgnd, Fgnd.a);
}

//-----------------------------------------------------------------------------------------//
// Techniques
//-----------------------------------------------------------------------------------------//

technique Ax_Rotate_right
{
   pass P_1
   < string Script = "RenderColorTarget0 = Super;"; >
   { PixelShader = compile PROFILE ps_keygen (); }

   pass P_2
   { PixelShader = compile PROFILE ps_rotate_right (); }
}

technique Ax_Rotate_down
{
   pass P_1
   < string Script = "RenderColorTarget0 = Super;"; >
   { PixelShader = compile PROFILE ps_keygen (); }

   pass P_2
   { PixelShader = compile PROFILE ps_rotate_down (); }
}

technique Ax_Rotate_left
{
   pass P_1
   < string Script = "RenderColorTarget0 = Super;"; >
   { PixelShader = compile PROFILE ps_keygen (); }

   pass P_2
   { PixelShader = compile PROFILE ps_rotate_left (); }
}

technique Ax_Rotate_up
{
   pass P_1
   < string Script = "RenderColorTarget0 = Super;"; >
   { PixelShader = compile PROFILE ps_keygen (); }

   pass P_2
   { PixelShader = compile PROFILE ps_rotate_up (); }
}
