// @Maintainer jwrl
// @Released 2020-07-31
// @Author jwrl
// @Created 2018-06-12
// @see https://www.lwks.com/media/kunena/attachments/6375/Ax_Push_640.png
// @see https://www.lwks.com/media/kunena/attachments/6375/Ax_Push.mp4

/**
 This mimics the Lightworks push effect but supports alpha channel transitions.  Alpha
 levels can be boosted to support Lightworks titles, which is the default setting.
*/

//-----------------------------------------------------------------------------------------//
// Lightworks user effect Push_Ax.fx
//
// This is a revision of an earlier effect, Adx_Bars.fx, which also had the ability to
// transition between two titles.  That adds needless complexity, when the same result
// can be obtained by overlaying two effects.
//
// Version history:
//
// Modified 2020-07-31 jwrl.
// Reworded Boost text to match requirements for 2020.1 and up.
// Reworded Transition text to match requirements for 2020.1 and up.
// Move Boost code into separate shader so that the foreground is always correct.
//
// Modified 28 Dec 2018 by user jwrl:
// Reformatted the effect description for markup purposes.
//
// Modified 13 December 2018 jwrl.
// Changed effect name.
// Changed subcategory.
//-----------------------------------------------------------------------------------------//

int _LwksEffectInfo
<
   string EffectGroup = "GenericPixelShader";
   string Description = "Push transition (alpha)";
   string Category    = "Mix";
   string SubCategory = "Wipe transitions";
   string Notes       = "Pushes a title on or off screen horizontally or vertically";
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
   string Description = "Progress";
   float MinVal = 0.0;
   float MaxVal = 1.0;
   float KF0    = 0.0;
   float KF1    = 1.0;
> = 0.5;

int Ttype
<
   string Description = "Transition position";
   string Enum = "At start,At end";
> = 0;

int SetTechnique
<
   string Description = "Type";
   string Enum = "Push Right,Push Down,Push Left,Push Up";
> = 0;

//-----------------------------------------------------------------------------------------//
// Definitions and declarations
//-----------------------------------------------------------------------------------------//

#define FX_OUT  1

#define HALF_PI 1.5707963268

#define EMPTY   0.0.xxxx

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

float4 ps_push_right (float2 uv : TEXCOORD1) : COLOR
{
   float2 xy = (Ttype == FX_OUT) ? float2 (saturate (uv.x + cos (HALF_PI * Amount) - 1.0), uv.y)
                                 : float2 (saturate (uv.x - sin (HALF_PI * Amount) + 1.0), uv.y);

   float4 Fgnd = fn_tex2D (s_Super, xy);

   return lerp (tex2D (s_Background, uv), Fgnd, Fgnd.a);
}

float4 ps_push_left (float2 uv : TEXCOORD1) : COLOR
{
   float2 xy = (Ttype == FX_OUT) ? float2 (saturate (uv.x - cos (HALF_PI * Amount) + 1.0), uv.y)
                                 : float2 (saturate (uv.x + sin (HALF_PI * Amount) - 1.0), uv.y);

   float4 Fgnd = fn_tex2D (s_Super, xy);

   return lerp (tex2D (s_Background, uv), Fgnd, Fgnd.a);
}

float4 ps_push_down (float2 uv : TEXCOORD1) : COLOR
{
   float2 xy = (Ttype == FX_OUT) ? float2 (uv.x, saturate (uv.y + cos (HALF_PI * Amount) - 1.0))
                                 : float2 (uv.x, saturate (uv.y - sin (HALF_PI * Amount) + 1.0));

   float4 Fgnd = fn_tex2D (s_Super, xy);

   return lerp (tex2D (s_Background, uv), Fgnd, Fgnd.a);
}

float4 ps_push_up (float2 uv : TEXCOORD1) : COLOR
{
   float2 xy = (Ttype == FX_OUT) ? float2 (uv.x, saturate (uv.y - cos (HALF_PI * Amount) + 1.0))
                                 : float2 (uv.x, saturate (uv.y + sin (HALF_PI * Amount) - 1.0));

   float4 Fgnd = fn_tex2D (s_Super, xy);

   return lerp (tex2D (s_Background, uv), Fgnd, Fgnd.a);
}

//-----------------------------------------------------------------------------------------//
// Techniques
//-----------------------------------------------------------------------------------------//

technique Push_right
{
   pass P_1
   < string Script = "RenderColorTarget0 = Super;"; >
   { PixelShader = compile PROFILE ps_keygen (); }

   pass P_2
   { PixelShader = compile PROFILE ps_push_right (); }
}

technique Push_down
{
   pass P_1
   < string Script = "RenderColorTarget0 = Super;"; >
   { PixelShader = compile PROFILE ps_keygen (); }

   pass P_2
   { PixelShader = compile PROFILE ps_push_down (); }
}

technique Push_left
{
   pass P_1
   < string Script = "RenderColorTarget0 = Super;"; >
   { PixelShader = compile PROFILE ps_keygen (); }

   pass P_2
   { PixelShader = compile PROFILE ps_push_left (); }
}

technique Push_up
{
   pass P_1
   < string Script = "RenderColorTarget0 = Super;"; >
   { PixelShader = compile PROFILE ps_keygen (); }

   pass P_2
   { PixelShader = compile PROFILE ps_push_up (); }
}
