#! /usr/local/bin/perl
#####################################################################

#
# dsp_rt_defn.pl:
#   Module definitions for dsp_rt.dll
#
# Usage: Automatically included by gen_modules.pl
#        NOTE: This file overrides definitions in the default
#              defn file: module_defn.pl
#
# $Revision: 1.1.6.4 $
#

$^W = 1;

$msvcdep_include_path = $msvcdep_include_path .
    ' -I../../../dspblks/fixpt/include' .
    ' -I../../../dspblks/include' .
    ' -I../../../../simulink/include' ;

$cpp_common_options = $cpp_common_options .
    ' /D "MWDSP_DYNAMIC_RTLIBS"' . 
    ' /D "DSP_RT_EXPORTS"' .
    ' /I "..\..\..\dspblks\fixpt\include"' .
    ' /I "..\..\..\dspblks\include"' .
    ' /I "..\..\..\..\simulink\include"' .
    ' /D "DSPIC_EXPORTS"' .
    ' /D "DSPACF_EXPORTS"' .
    ' /D "DSPALLPOLE_EXPORTS"' .
    ' /D "DSPBIQUAD_EXPORTS"' .
    ' /D "DSPBLMS_EXPORTS"' .
    ' /D "DSPBURG_EXPORTS"' .
    ' /D "DSPCHOL_EXPORTS"' .
    ' /D "DSPCICFILTER_EXPORTS"' .
    ' /D "DSPCONVCORR_EXPORTS"' .
    ' /D "DSPENDIAN_EXPORTS"' .
    ' /D "DSPEPH_EXPORTS"' .
    ' /D "DSPFBSUB_EXPORTS"' .
    ' /D "DSPFFT_EXPORTS"' .
    ' /D "DSPFILTERBANK_EXPORTS"' .
    ' /D "DSPFIR_EXPORTS"' .
    ' /D "DSPFIRDN_EXPORTS"' .
    ' /D "DSPFLIP_EXPORTS"' .
    ' /D "DSPG711_EXPORTS"' .
    ' /D "DSPGIVENSROT_EXPORTS"' .
    ' /D "DSPHIST_EXPORTS"' .
    ' /D "DSPIIR_EXPORTS"' .
    ' /D "DSPINTERP_EXPORTS"' .
    ' /D "DSPISFINITE_EXPORTS"' .
    ' /D "DSPLDL_EXPORTS"' .
    ' /D "DSPLEVDURB_EXPORTS"' .
    ' /D "DSPLMS_EXPORTS"' .
    ' /D "DSPLPC2CC_EXPORTS"' .
    ' /D "DSPLSP2POLY_EXPORTS"' .
    ' /D "DSPLU_EXPORTS"' .
    ' /D "DSPMMULT_EXPORTS"' .
    ' /D "DSPPAD_EXPORTS"' .
    ' /D "DSPPINV_EXPORTS"' .
    ' /D "DSPPOLY2LSF_EXPORTS"' .
    ' /D "DSPPOLYVAL_EXPORTS"' .
    ' /D "DSPQRDC_EXPORTS"' .
    ' /D "DSPRANDSRC_EXPORTS"' .
    ' /D "DSPRANDSRC64BIT_EXPORTS"' .
    ' /D "DSPRANDSRC32BIT_EXPORTS"' .
    ' /D "DSPRC2AC_EXPORTS"' .
    ' /D "DSPRC2LPC_EXPORTS"' .
    ' /D "DSPREBUFF_EXPORTS"' .
    ' /D "DSPQSRT_EXPORTS"' .
    ' /D "DSPSVD_EXPORTS"' .
    ' /D "DSPUNWRAP_EXPORTS"' .
    ' /D "DSPUPFIR_EXPORTS"' .
    ' /D "DSPUPFIRDN_EXPORTS"' .
    ' /D "DSPVFDLY_EXPORTS"' .
    ' /D "DSPWINDOW_EXPORTS"';

$bin_dir = '..\..\..\..\bin\win32';

$lib_dir = '..\..\..\dspblks\lib\win32\dsp_rt';

$obj_dir = '..\..\..\dspblks\obj\rt\win32';

# $link32_common_options .= "$lib_dir\\othermodulename.lib";

return 1;
