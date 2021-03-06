// @Maintainer jwrl
// @Released 2020-11-13
// @Author baopao
// @Released 2014-02-01
// @see https://www.lwks.com/media/kunena/attachments/6375/KeyDespill_640.png

/**
 KeyDespill is a background-based effect for removing the key colour spill in a chromakey
 composite.
*/

//-----------------------------------------------------------------------------------------//
// Lightworks user effect KeyDespillFx.fx
//
// Despill Background Based http://www.alessandrodallafontana.com/ (baopao)
//
// Version history:
//
// Update 2020-11-13 jwrl.
// Added Cansize switch for LW 2021 support.
//
// Modified 23 December 2018 jwrl.
// Added creation date.
// Reformatted the effect description for markup purposes.
//
// Modified 26 Nov 2018 by user schrauber:
// Changed subcategory from "User Effects" to "Key Extras", effect name changed minimally.
//
// Modified 7 April 2018 jwrl.
// Added authorship and description information for GitHub, and reformatted the original
// code to be consistent with other Lightworks user effects.
//
// Cross platform compatibility check 1 August 2017 jwrl.
// Explicitly defined samplers to fix cross platform default sampler state differences.
//
// Version 14 update 19 Feb 2017 jwrl.
// Changed category from "Keying" to "Key", added subcategory to effect header.
//-----------------------------------------------------------------------------------------//

int _LwksEffectInfo
<
   string EffectGroup = "GenericPixelShader";
   string Description = "Key despill";
   string Category    = "Key";
   string SubCategory = "Key Extras";
   string Notes       = "This is a background-based effect that removes key colour spill in a chromakey";
   bool CanSize       = true;
> = 0;

//-----------------------------------------------------------------------------------------//
// Inputs
//-----------------------------------------------------------------------------------------//

texture Fg;
texture Bg;

//-----------------------------------------------------------------------------------------//
// Shaders
//-----------------------------------------------------------------------------------------//

sampler FgSampler = sampler_state
{
   Texture   = <Fg>;
   AddressU  = Clamp;
   AddressV  = Clamp;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;
};

sampler BgSampler = sampler_state
{
   Texture   = <Bg>;
   AddressU  = Clamp;
   AddressV  = Clamp;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;
};

//-----------------------------------------------------------------------------------------//
// Parameters
//-----------------------------------------------------------------------------------------//

int SetTechnique
<
   string Description = "Key";
   string Enum = "Green,Blue";
> = 0;

float RedAmount
<
   string Description = "RedAmount";
   float MinVal = 0.0;
   float MaxVal = 1.00;
> = 0.5;

//-----------------------------------------------------------------------------------------//
// Shader
//-----------------------------------------------------------------------------------------//

float4 Green(float2 xy1 : TEXCOORD1, float2 xy2 : TEXCOORD2 ) : COLOR
{
    float4 color = tex2D(FgSampler, xy1);
    float4 Back = tex2D(BgSampler, xy2);

    float mask = clamp(color.g-lerp (color.r, color.b, RedAmount), 0, 1);
    color.g = color.g-mask;
    color += Back * mask; 

    return color;
}

float4 Blue(float2 xy1 : TEXCOORD1, float2 xy2 : TEXCOORD2 ) : COLOR
{
    float4 color = tex2D(FgSampler, xy1);
    float4 Back = tex2D(BgSampler, xy2);

    float mask = clamp(color.b-lerp (color.r, color.g, RedAmount), 0, 1);
    color.b = color.b-mask;
    color += Back * mask;

    return color;
}

//-----------------------------------------------------------------------------------------//
//  Technique
//-----------------------------------------------------------------------------------------//

technique GreenDespill
{
   pass p0
   {
      PixelShader = compile PROFILE Green();
   }
}

technique BlueDespill
{
   pass p0
   {
      PixelShader = compile PROFILE Blue();
   }
}
