# Microsoft Developer Studio Project File - Name="dsp_rt" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=dsp_rt - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "dsp_rt.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "dsp_rt.mak" CFG="dsp_rt - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "dsp_rt - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "dsp_rt - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE

# Begin Project

CPP=cl.exe
MTL=midl.exe
RSC=rc.exe
BSC32=bscmake.exe
LINK32=link.exe

!IF  "$(CFG)" == "dsp_rt - Win32 Release"

# PROP Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP Intermediate_Dir "..\..\..\dspblks\obj\rt\win32"
# PROP Output_Dir "..\..\..\dspblks\lib\win32\dsp_rt"
# PROP Target_Dir ""

# ADD BASE CPP /nologo /W3 /GX /EHc- /D "WIN32" /D "_WIN32_WINNT=0x0500" /D "_WINDOWS" /D "_WINDLL" /D "_AFXDLL" /YX /GR /FD /c /O2 /Oy- /Op /D "NDEBUG"
# ADD CPP /nologo /W3 /GX /EHc- /D "WIN32" /D "_WIN32_WINNT=0x0500" /D "_WINDOWS" /D "_WINDLL" /D "_AFXDLL" /YX /GR /FD /c /O2 /Oy- /Op /D "NDEBUG"
# SUBTRACT CPP  
# ADD CPP /I ".\include" /I "..\..\..\..\src\include" /I "..\..\..\..\freeware\icu\win32\release\include" /I "..\..\..\..\freeware\xerces-c\win32\release\include" /I "$(VSNET7)\atlmfc\src\mfc" /D "MSWIND" /D "SIMULINK_V2" /Fp"..\..\..\dspblks\obj\rt\win32\dsp_rt.pch" /D "MWDSP_DYNAMIC_RTLIBS" /D "DSP_RT_EXPORTS" /I "..\..\..\dspblks\fixpt\include" /I "..\..\..\dspblks\include" /I "..\..\..\..\simulink\include" /D "DSPIC_EXPORTS" /D "DSPACF_EXPORTS" /D "DSPALLPOLE_EXPORTS" /D "DSPBIQUAD_EXPORTS" /D "DSPBLMS_EXPORTS" /D "DSPBURG_EXPORTS" /D "DSPCHOL_EXPORTS" /D "DSPCICFILTER_EXPORTS" /D "DSPCONVCORR_EXPORTS" /D "DSPENDIAN_EXPORTS" /D "DSPEPH_EXPORTS" /D "DSPFBSUB_EXPORTS" /D "DSPFFT_EXPORTS" /D "DSPFILTERBANK_EXPORTS" /D "DSPFIR_EXPORTS" /D "DSPFIRDN_EXPORTS" /D "DSPFLIP_EXPORTS" /D "DSPG711_EXPORTS" /D "DSPGIVENSROT_EXPORTS" /D "DSPHIST_EXPORTS" /D "DSPIIR_EXPORTS" /D "DSPINTERP_EXPORTS" /D "DSPISFINITE_EXPORTS" /D "DSPLDL_EXPORTS" /D "DSPLEVDURB_EXPORTS" /D "DSPLMS_EXPORTS" /D "DSPLPC2CC_EXPORTS" /D "DSPLSP2POLY_EXPORTS" /D "DSPLU_EXPORTS" /D "DSPMMULT_EXPORTS" /D "DSPPAD_EXPORTS" /D "DSPPINV_EXPORTS" /D "DSPPOLY2LSF_EXPORTS" /D "DSPPOLYVAL_EXPORTS" /D "DSPQRDC_EXPORTS" /D "DSPRANDSRC_EXPORTS" /D "DSPRANDSRC64BIT_EXPORTS" /D "DSPRANDSRC32BIT_EXPORTS" /D "DSPRC2AC_EXPORTS" /D "DSPRC2LPC_EXPORTS" /D "DSPREBUFF_EXPORTS" /D "DSPQSRT_EXPORTS" /D "DSPSVD_EXPORTS" /D "DSPUNWRAP_EXPORTS" /D "DSPUPFIR_EXPORTS" /D "DSPUPFIRDN_EXPORTS" /D "DSPVFDLY_EXPORTS" /D "DSPWINDOW_EXPORTS" /MD

# ADD BASE RSC /l 0x409 /d "NDEBUG" /d "INTL_RESOURCE"
# ADD RSC /l 0x409 /d "NDEBUG" /d "INTL_RESOURCE"
# SUBTRACT RSC  
# ADD RSC /fo"..\..\..\dspblks\obj\rt\win32\dsp_rt.res" /i ".\include" /i "..\..\..\..\src\include" 

# ADD BASE BSC32 /nologo 
# ADD BSC32 /nologo 
# SUBTRACT BSC32  
# ADD BSC32 /o"..\..\..\dspblks\obj\rt\win32\dsp_rt.bsc" 

# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386 mfcs71.lib
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386 mfcs71.lib
# SUBTRACT LINK32  
# ADD LINK32 /pdb:"..\..\..\dspblks\obj\rt\win32\dsp_rt.pdb" /map:"..\..\..\..\bin\win32\dsp_rt.map" /def:".\EXPORTS\dsp_rt.def" /out:"..\..\..\..\bin\win32\dsp_rt.dll" /implib:"..\..\..\dspblks\obj\rt\win32\dsp_rt.lib" /version:6.0  /libpath:"..\..\..\..\freeware\icu\win32\release\lib"  /libpath:"..\..\..\..\freeware\xerces-c\win32\release\lib"  

# Begin Special Build Tool

PreLink_Desc=Building import libraries
PreLink_Cmds= \

PostBuild_Desc=Updating import library
PostBuild_Cmds= \
..\..\..\..\tools\win32\smartcmp -s ..\..\..\dspblks\obj\rt\win32\dsp_rt.lib ..\..\..\dspblks\lib\win32\dsp_rt\dsp_rt.lib & if errorlevel 1 copy ..\..\..\dspblks\obj\rt\win32\dsp_rt.lib ..\..\..\dspblks\lib\win32\dsp_rt\dsp_rt.lib	\
copy ..\..\..\dspblks\lib\win32\dsp_rt\dsp_rt.lib ..\..\..\dspblks\obj\rt\win32\dsp_rt.lib	\
..\..\..\..\tools\win32\mapcsf ..\..\..\..\bin\win32\dsp_rt

# End Special Build Tool

!ELSEIF  "$(CFG)" == "dsp_rt - Win32 Debug"

# PROP Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP Intermediate_Dir "..\..\..\dspblks\obj\rt\win32"
# PROP Output_Dir "..\..\..\dspblks\lib\win32\dsp_rt"
# PROP Target_Dir ""

# ADD BASE CPP /nologo /W3 /GX /EHc- /D "WIN32" /D "_WIN32_WINNT=0x0500" /D "_WINDOWS" /D "_WINDLL" /D "_AFXDLL" /YX /GR /FD /c /Od /Oy- /D /Zi
# ADD CPP /nologo /W3 /GX /EHc- /D "WIN32" /D "_WIN32_WINNT=0x0500" /D "_WINDOWS" /D "_WINDLL" /D "_AFXDLL" /YX /GR /FD /c /Od /Oy- /D /Zi
# SUBTRACT CPP  
# ADD CPP /I ".\include" /I "..\..\..\..\src\include" /I "..\..\..\..\freeware\icu\win32\release\include" /I "..\..\..\..\freeware\xerces-c\win32\release\include" /I "$(VSNET7)\atlmfc\src\mfc" /D "MSWIND" /D "SIMULINK_V2" /Fp"..\..\..\dspblks\obj\rt\win32\dsp_rt.pch" /D "MWDSP_DYNAMIC_RTLIBS" /D "DSP_RT_EXPORTS" /I "..\..\..\dspblks\fixpt\include" /I "..\..\..\dspblks\include" /I "..\..\..\..\simulink\include" /D "DSPIC_EXPORTS" /D "DSPACF_EXPORTS" /D "DSPALLPOLE_EXPORTS" /D "DSPBIQUAD_EXPORTS" /D "DSPBLMS_EXPORTS" /D "DSPBURG_EXPORTS" /D "DSPCHOL_EXPORTS" /D "DSPCICFILTER_EXPORTS" /D "DSPCONVCORR_EXPORTS" /D "DSPENDIAN_EXPORTS" /D "DSPEPH_EXPORTS" /D "DSPFBSUB_EXPORTS" /D "DSPFFT_EXPORTS" /D "DSPFILTERBANK_EXPORTS" /D "DSPFIR_EXPORTS" /D "DSPFIRDN_EXPORTS" /D "DSPFLIP_EXPORTS" /D "DSPG711_EXPORTS" /D "DSPGIVENSROT_EXPORTS" /D "DSPHIST_EXPORTS" /D "DSPIIR_EXPORTS" /D "DSPINTERP_EXPORTS" /D "DSPISFINITE_EXPORTS" /D "DSPLDL_EXPORTS" /D "DSPLEVDURB_EXPORTS" /D "DSPLMS_EXPORTS" /D "DSPLPC2CC_EXPORTS" /D "DSPLSP2POLY_EXPORTS" /D "DSPLU_EXPORTS" /D "DSPMMULT_EXPORTS" /D "DSPPAD_EXPORTS" /D "DSPPINV_EXPORTS" /D "DSPPOLY2LSF_EXPORTS" /D "DSPPOLYVAL_EXPORTS" /D "DSPQRDC_EXPORTS" /D "DSPRANDSRC_EXPORTS" /D "DSPRANDSRC64BIT_EXPORTS" /D "DSPRANDSRC32BIT_EXPORTS" /D "DSPRC2AC_EXPORTS" /D "DSPRC2LPC_EXPORTS" /D "DSPREBUFF_EXPORTS" /D "DSPQSRT_EXPORTS" /D "DSPSVD_EXPORTS" /D "DSPUNWRAP_EXPORTS" /D "DSPUPFIR_EXPORTS" /D "DSPUPFIRDN_EXPORTS" /D "DSPVFDLY_EXPORTS" /D "DSPWINDOW_EXPORTS" /MD /FR"..\..\..\dspblks\obj\rt\win32\\"

# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
# SUBTRACT RSC  
# ADD RSC /fo"..\..\..\dspblks\obj\rt\win32\dsp_rt.res" /i ".\include" /i "..\..\..\..\src\include" 

# ADD BASE BSC32 /nologo 
# ADD BSC32 /nologo 
# SUBTRACT BSC32  
# ADD BSC32 /o"..\..\..\dspblks\obj\rt\win32\dsp_rt.bsc" 

# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386 mfcs71.lib /debug
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386 mfcs71.lib /debug
# SUBTRACT LINK32  
# ADD LINK32 /pdb:"..\..\..\dspblks\obj\rt\win32\dsp_rt.pdb" /map:"..\..\..\..\bin\win32\dsp_rt.map" /def:".\EXPORTS\dsp_rt.def" /out:"..\..\..\..\bin\win32\dsp_rt.dll" /implib:"..\..\..\dspblks\obj\rt\win32\dsp_rt.lib" /version:6.0  /libpath:"..\..\..\..\freeware\icu\win32\release\lib"  /libpath:"..\..\..\..\freeware\xerces-c\win32\release\lib"  

# Begin Special Build Tool

PreLink_Desc=Building import libraries
PreLink_Cmds= \

PostBuild_Desc=Updating import library
PostBuild_Cmds= \
..\..\..\..\tools\win32\smartcmp -s ..\..\..\dspblks\obj\rt\win32\dsp_rt.lib ..\..\..\dspblks\lib\win32\dsp_rt\dsp_rt.lib & if errorlevel 1 copy ..\..\..\dspblks\obj\rt\win32\dsp_rt.lib ..\..\..\dspblks\lib\win32\dsp_rt\dsp_rt.lib	\
copy ..\..\..\dspblks\lib\win32\dsp_rt\dsp_rt.lib ..\..\..\dspblks\obj\rt\win32\dsp_rt.lib	\
..\..\..\..\tools\win32\mapcsf ..\..\..\..\bin\win32\dsp_rt

# End Special Build Tool

!ENDIF

# Begin Target

# Name "dsp_rt - Win32 Release"
# Name "dsp_rt - Win32 Debug"

# Begin Group "dspacf"

# Begin Source File
SOURCE=.\dspacf\acf_fd_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspacf\acf_fd_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspacf\acf_fd_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspacf\acf_fd_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspacf\acf_fft_interleave_zpad_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspacf\acf_fft_interleave_zpad_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspacf\acf_td_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspacf\acf_td_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspacf\acf_td_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspacf\acf_td_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspacf\copy_and_zero_pad_cc_nchan_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspacf\copy_and_zero_pad_zz_nchan_rt.c
# End Source File

# End Group

# Begin Group "dspallpole"

# Begin Source File
SOURCE=.\dspallpole\allpole_df_a0scale_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_a0scale_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_a0scale_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_a0scale_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_a0scale_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_a0scale_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_a0scale_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_a0scale_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_df_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_lat_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_lat_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_lat_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_lat_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_lat_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_lat_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_lat_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_lat_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_a0scale_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_a0scale_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_a0scale_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_a0scale_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_a0scale_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_a0scale_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_a0scale_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_a0scale_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspallpole\allpole_tdf_zz_rt.c
# End Source File

# End Group

# Begin Group "dspbiquad"

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_1sos_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_1sos_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_1sos_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_1sos_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_1sos_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_1sos_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_1sos_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_1sos_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_nsos_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_nsos_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_nsos_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_nsos_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_nsos_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_nsos_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_nsos_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq4_df2t_1fpf_nsos_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_1sos_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_1sos_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_1sos_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_1sos_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_1sos_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_1sos_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_1sos_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_1sos_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_nsos_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_nsos_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_nsos_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_nsos_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_nsos_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_nsos_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_nsos_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq5_df2t_1fpf_nsos_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_1sos_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_1sos_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_1sos_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_1sos_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_1sos_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_1sos_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_1sos_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_1sos_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_nsos_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_nsos_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_nsos_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_nsos_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_nsos_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_nsos_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_nsos_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspbiquad\bq6_df2t_1fpf_nsos_zz_rt.c
# End Source File

# End Group

# Begin Group "dspblms"

# Begin Source File
SOURCE=.\dspblms\blms_an_wn_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_an_wn_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_an_wn_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_an_wn_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_an_wy_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_an_wy_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_an_wy_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_an_wy_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_ay_wn_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_ay_wn_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_ay_wn_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_ay_wn_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_ay_wy_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_ay_wy_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_ay_wy_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspblms\blms_ay_wy_zz_rt.c
# End Source File

# End Group

# Begin Group "dspburg"

# Begin Source File
SOURCE=.\dspburg\burg_a_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspburg\burg_a_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspburg\burg_a_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspburg\burg_a_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspburg\burg_ak_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspburg\burg_ak_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspburg\burg_ak_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspburg\burg_ak_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspburg\burg_k_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspburg\burg_k_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspburg\burg_k_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspburg\burg_k_z_rt.c
# End Source File

# End Group

# Begin Group "dspchol"

# Begin Source File
SOURCE=.\dspchol\chol_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspchol\chol_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspchol\chol_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspchol\chol_z_rt.c
# End Source File

# End Group

# Begin Group "dspcicfilter"

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_lat_0808_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_lat_0816_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_lat_0832_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_lat_1608_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_lat_1616_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_lat_1632_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_lat_3208_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_lat_3216_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_lat_3232_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_zer_0808_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_zer_0816_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_zer_0832_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_zer_1608_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_zer_1616_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_zer_1632_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_zer_3208_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_zer_3216_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_dec_zer_3232_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_lat_0808_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_lat_0816_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_lat_0832_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_lat_1608_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_lat_1616_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_lat_1632_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_lat_3208_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_lat_3216_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_lat_3232_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_zer_0808_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_zer_0816_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_zer_0832_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_zer_1608_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_zer_1616_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_zer_1632_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_zer_3208_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_zer_3216_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspcicfilter\cic_int_zer_3232_rt.c
# End Source File

# End Group

# Begin Group "dspconvcorr"

# Begin Source File
SOURCE=.\dspconvcorr\conv_td_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\conv_td_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\conv_td_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\conv_td_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\conv_td_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\conv_td_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\copy_and_zpad_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\copy_and_zpad_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\copy_and_zpad_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\copy_and_zpad_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\corr_td_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\corr_td_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\corr_td_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\corr_td_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\corr_td_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\corr_td_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\corr_td_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspconvcorr\corr_td_zz_rt.c
# End Source File

# End Group

# Begin Group "dspendian"

# Begin Source File
SOURCE=.\dspendian\is_little_endian_rt.c
# End Source File

# End Group

# Begin Group "dspeph"

# Begin Source File
SOURCE=.\dspeph\eph_zc_fcn_rt.c
# End Source File

# End Group

# Begin Group "dspfbsub"

# Begin Source File
SOURCE=.\dspfbsub\bsub_nu_cc_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_nu_cr_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_nu_dd_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_nu_dz_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_nu_rc_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_nu_rr_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_nu_zd_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_nu_zz_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_u_cc_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_u_cr_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_u_dd_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_u_dz_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_u_rc_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_u_rr_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_u_zd_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\bsub_u_zz_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_nu_cc_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_nu_cr_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_nu_dd_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_nu_dz_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_nu_rc_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_nu_rr_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_nu_zd_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_nu_zz_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_u_cc_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_u_cr_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_u_dd_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_u_dz_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_u_rc_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_u_rr_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_u_zd_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfbsub\fsub_u_zz_z_rt.c
# End Source File

# End Group

# Begin Group "dspfft"

# Begin Source File
SOURCE=.\dspfft\copy_adjrow_intcol_br_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_adjrow_intcol_br_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_adjrow_intcol_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_adjrow_intcol_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_col_as_row_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_col_as_row_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_row_as_col_br_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_row_as_col_br_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_row_as_col_br_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_row_as_col_br_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_row_as_col_br_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_row_as_col_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_row_as_col_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_row_as_col_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\copy_row_as_col_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_dbllen_tbl_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_dbllen_tbl_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_dbllen_trig_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_dbllen_trig_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_dblsig_br_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_dblsig_br_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_dblsig_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_dblsig_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_interleave_br_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_interleave_br_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_interleave_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_interleave_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2br_c_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2br_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2br_dz_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2br_rc_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2br_z_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2br_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2dif_tblm_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2dif_tblm_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2dif_tbls_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2dif_tbls_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2dif_trig_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2dif_trig_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2dit_tblm_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2dit_tblm_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2dit_tbls_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2dit_tbls_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2dit_trig_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_r2dit_trig_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_scaledata_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_scaledata_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_scaledata_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\fft_scaledata_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_addcssignals_c_c_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_addcssignals_c_cbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_addcssignals_d_z_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_addcssignals_d_zbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_addcssignals_r_c_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_addcssignals_r_cbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_addcssignals_z_z_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_addcssignals_z_zbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_tbl_c_cbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_tbl_cbr_cbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_tbl_d_zbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_tbl_dbr_zbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_tbl_r_cbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_tbl_rbr_cbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_tbl_z_zbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_tbl_zbr_zbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_trig_c_cbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_trig_cbr_cbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_trig_d_zbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_trig_dbr_zbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_trig_r_cbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_trig_rbr_cbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_trig_z_zbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_dbllen_trig_zbr_zbr_oop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_deinterleave_d_d_inp_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfft\ifft_deinterleave_r_r_inp_rt.c
# End Source File

# End Group

# Begin Group "dspfilterbank"

# Begin Source File
SOURCE=.\dspfilterbank\2chabank_fr_df_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfilterbank\2chabank_fr_df_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfilterbank\2chabank_fr_df_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfilterbank\2chabank_fr_df_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfilterbank\2chabank_fr_df_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfilterbank\2chabank_fr_df_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfilterbank\2chsbank_df_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfilterbank\2chsbank_df_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfilterbank\2chsbank_df_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfilterbank\2chsbank_df_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfilterbank\2chsbank_df_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfilterbank\2chsbank_df_zz_rt.c
# End Source File

# End Group

# Begin Group "dspfir"

# Begin Source File
SOURCE=.\dspfir\fir_df_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_df_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_df_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_df_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_df_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_df_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_df_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_df_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_lat_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_lat_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_lat_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_lat_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_lat_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_lat_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_lat_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_lat_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_tdf_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_tdf_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_tdf_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_tdf_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_tdf_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_tdf_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_tdf_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfir\fir_tdf_zz_rt.c
# End Source File

# End Group

# Begin Group "dspfirdn"

# Begin Source File
SOURCE=.\dspfirdn\firdn_df_dblbuf_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfirdn\firdn_df_dblbuf_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfirdn\firdn_df_dblbuf_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfirdn\firdn_df_dblbuf_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfirdn\firdn_df_dblbuf_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfirdn\firdn_df_dblbuf_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfirdn\firdn_df_dblbuf_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspfirdn\firdn_df_dblbuf_zz_rt.c
# End Source File

# End Group

# Begin Group "dspflip"

# Begin Source File
SOURCE=.\dspflip\flip_matrix_col_ip_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspflip\flip_matrix_col_op_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspflip\flip_matrix_row_ip_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspflip\flip_matrix_row_op_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspflip\flip_vector_ip_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspflip\flip_vector_op_rt.c
# End Source File

# End Group

# Begin Group "dspg711"

# Begin Source File
SOURCE=.\dspg711\g711_enc_a_sat_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspg711\g711_enc_a_wrap_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspg711\g711_enc_mu_sat_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspg711\g711_enc_mu_wrap_rt.c
# End Source File

# End Group

# Begin Group "dspgivensrot"

# Begin Source File
SOURCE=.\dspgivensrot\rotg_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspgivensrot\rotg_r_rt.c
# End Source File

# End Group

# Begin Group "dsphist"

# Begin Source File
SOURCE=.\dsphist\hist_binsearch_s08_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsphist\hist_binsearch_s16_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsphist\hist_binsearch_s32_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsphist\hist_binsearch_u08_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsphist\hist_binsearch_u16_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsphist\hist_binsearch_u32_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsphist\hist_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsphist\hist_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsphist\hist_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsphist\hist_z_rt.c
# End Source File

# End Group

# Begin Group "dspic"

# Begin Source File
SOURCE=.\dspic\ic_copy_channel_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspic\ic_copy_matrix_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspic\ic_copy_scalar_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspic\ic_copy_vector_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspic\ic_old_copy_fcns_rt.c
# End Source File

# End Group

# Begin Group "dspiir"

# Begin Source File
SOURCE=.\dspiir\iir_df1_a0scale_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_a0scale_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_a0scale_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_a0scale_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_a0scale_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_a0scale_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_a0scale_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_a0scale_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_a0scale_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_a0scale_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_a0scale_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_a0scale_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_a0scale_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_a0scale_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_a0scale_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_a0scale_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df1t_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_a0scale_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_a0scale_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_a0scale_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_a0scale_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_a0scale_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_a0scale_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_a0scale_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_a0scale_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_a0scale_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_a0scale_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_a0scale_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_a0scale_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_a0scale_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_a0scale_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_a0scale_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_a0scale_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspiir\iir_df2t_zz_rt.c
# End Source File

# End Group

# Begin Group "dspinterp"

# Begin Source File
SOURCE=.\dspinterp\interp_fir_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspinterp\interp_fir_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspinterp\interp_lin_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspinterp\interp_lin_r_rt.c
# End Source File

# End Group

# Begin Group "dspintsignext"

# Begin Source File
SOURCE=.\dspintsignext\int32signext_rt.c
# End Source File

# End Group

# Begin Group "dspisfinite"

# Begin Source File
SOURCE=.\dspisfinite\isfinite_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspisfinite\isfinite_r_rt.c
# End Source File

# End Group

# Begin Group "dspldl"

# Begin Source File
SOURCE=.\dspldl\ldl_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspldl\ldl_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspldl\ldl_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspldl\ldl_z_rt.c
# End Source File

# End Group

# Begin Group "dsplevdurb"

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_a_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_a_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_a_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_a_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_ak_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_ak_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_ak_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_ak_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_akp_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_akp_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_akp_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_akp_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_ap_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_ap_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_ap_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplevdurb\levdurb_ap_z_rt.c
# End Source File

# End Group

# Begin Group "dsplms"

# Begin Source File
SOURCE=.\dsplms\lms_an_wn_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_an_wn_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_an_wn_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_an_wn_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_an_wy_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_an_wy_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_an_wy_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_an_wy_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_ay_wn_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_ay_wn_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_ay_wn_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_ay_wn_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_ay_wy_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_ay_wy_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_ay_wy_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lms_ay_wy_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_an_wn_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_an_wn_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_an_wn_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_an_wn_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_an_wy_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_an_wy_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_an_wy_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_an_wy_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_ay_wn_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_ay_wn_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_ay_wn_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_ay_wn_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_ay_wy_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_ay_wy_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_ay_wy_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsn_ay_wy_zz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmssd_an_wn_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmssd_an_wn_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmssd_an_wy_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmssd_an_wy_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmssd_ay_wn_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmssd_ay_wn_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmssd_ay_wy_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmssd_ay_wy_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsse_an_wn_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsse_an_wn_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsse_an_wy_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsse_an_wy_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsse_ay_wn_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsse_ay_wn_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsse_ay_wy_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsse_ay_wy_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsss_an_wn_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsss_an_wn_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsss_an_wy_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsss_an_wy_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsss_ay_wn_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsss_ay_wn_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsss_ay_wy_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplms\lmsss_ay_wy_rr_rt.c
# End Source File

# End Group

# Begin Group "dsplpc2cc"

# Begin Source File
SOURCE=.\dsplpc2cc\cc2lpc_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplpc2cc\cc2lpc_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplpc2cc\lpc2cc_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplpc2cc\lpc2cc_r_rt.c
# End Source File

# End Group

# Begin Group "dsplsp2poly"

# Begin Source File
SOURCE=.\dsplsp2poly\lsp2poly_evenord_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplsp2poly\lsp2poly_evenord_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplsp2poly\lsp2poly_oddord_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplsp2poly\lsp2poly_oddord_r_rt.c
# End Source File

# End Group

# Begin Group "dsplu"

# Begin Source File
SOURCE=.\dsplu\lu_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplu\lu_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplu\lu_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsplu\lu_z_rt.c
# End Source File

# End Group

# Begin Group "dspmmult"

# Begin Source File
SOURCE=.\dspmmult\matmult_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspmmult\matmult_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspmmult\matmult_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspmmult\matmult_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspmmult\matmult_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspmmult\matmult_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspmmult\matmult_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspmmult\matmult_zz_rt.c
# End Source File

# End Group

# Begin Group "dsppad"

# Begin Source File
SOURCE=.\dsppad\pad_cols_mixed_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppad\pad_cols_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppad\pad_copy_io_trunc_cols_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppad\pad_pre_cols_mixed_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppad\pad_pre_cols_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppad\pad_pre_rows_cols_mixed_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppad\pad_pre_rows_cols_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppad\pad_pre_rows_mixed_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppad\pad_pre_rows_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppad\pad_rows_cols_mixed_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppad\pad_rows_cols_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppad\pad_rows_mixed_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppad\pad_rows_rt.c
# End Source File

# End Group

# Begin Group "dsppinv"

# Begin Source File
SOURCE=.\dsppinv\pinv_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppinv\pinv_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppinv\pinv_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppinv\pinv_z_rt.c
# End Source File

# End Group

# Begin Group "dsppoly2lsf"

# Begin Source File
SOURCE=.\dsppoly2lsf\poly2lsfn_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppoly2lsf\poly2lsfn_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppoly2lsf\poly2lsfr_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppoly2lsf\poly2lsfr_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppoly2lsf\poly2lsp_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppoly2lsf\poly2lsp_r_rt.c
# End Source File

# End Group

# Begin Group "dsppolyval"

# Begin Source File
SOURCE=.\dsppolyval\polyval_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppolyval\polyval_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppolyval\polyval_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppolyval\polyval_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppolyval\polyval_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppolyval\polyval_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppolyval\polyval_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsppolyval\polyval_zz_rt.c
# End Source File

# End Group

# Begin Group "dspqrdc"

# Begin Source File
SOURCE=.\dspqrdc\qrcompqy_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qrcompqy_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qrcompqy_mixd_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qrcompqy_mixd_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qrcompqy_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qrcompqy_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qrdc_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qrdc_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qrdc_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qrdc_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qre_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qre_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qre_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qre_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qreslv_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qreslv_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qreslv_mixd_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qreslv_mixd_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qreslv_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqrdc\qreslv_z_rt.c
# End Source File

# End Group

# Begin Group "dspqsrt"

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_idx_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_idx_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_idx_s08_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_idx_s16_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_idx_s32_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_idx_u08_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_idx_u16_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_idx_u32_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_val_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_val_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_val_s08_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_val_s16_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_val_s32_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_val_u08_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_val_u16_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_ins_val_u32_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_idx_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_idx_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_idx_s08_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_idx_s16_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_idx_s32_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_idx_u08_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_idx_u16_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_idx_u32_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_val_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_val_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_val_s08_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_val_s16_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_val_s32_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_val_u08_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_val_u16_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\sort_qk_val_u32_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\srt_qid_findpivot_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\srt_qid_findpivot_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\srt_qid_partition_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\srt_qid_partition_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\srt_qkrec_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\srt_qkrec_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\srt_qkrec_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspqsrt\srt_qkrec_z_rt.c
# End Source File

# End Group

# Begin Group "dsprandsrc"

# Begin Source File
SOURCE=.\dsprandsrc\randsrc_gc_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrc_gc_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrc_gc_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrc_gc_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrc_gz_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrc_gz_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrc_gz_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrc_gz_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrc_u_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrc_u_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrc_u_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrc_u_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrccreateseeds_32_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrccreateseeds_64_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrcinitstate_gc_32_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrcinitstate_gc_64_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrcinitstate_gz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrcinitstate_u_32_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprandsrc\randsrcinitstate_u_64_rt.c
# End Source File

# End Group

# Begin Group "dsprc2ac"

# Begin Source File
SOURCE=.\dsprc2ac\lpc2ac_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprc2ac\lpc2ac_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprc2ac\rc2ac_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprc2ac\rc2ac_r_rt.c
# End Source File

# End Group

# Begin Group "dsprc2lpc"

# Begin Source File
SOURCE=.\dsprc2lpc\lpc2rc_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprc2lpc\lpc2rc_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprc2lpc\rc2lpc_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprc2lpc\rc2lpc_r_rt.c
# End Source File

# End Group

# Begin Group "dsprebuff"

# Begin Source File
SOURCE=.\dsprebuff\buf_copy_frame_to_mem_OL_1ch_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprebuff\buf_copy_frame_to_mem_OL_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprebuff\buf_copy_input_to_output_1ch_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprebuff\buf_copy_input_to_output_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprebuff\buf_copy_scalar_to_mem_OL_1ch_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprebuff\buf_copy_scalar_to_mem_OL_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprebuff\buf_copy_scalar_to_mem_UL_1ch_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprebuff\buf_copy_scalar_to_mem_UL_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprebuff\buf_output_frame_1ch_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprebuff\buf_output_frame_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprebuff\buf_output_scalar_1ch_rt.c
# End Source File

# Begin Source File
SOURCE=.\dsprebuff\buf_output_scalar_rt.c
# End Source File

# End Group

# Begin Group "dspsvd"

# Begin Source File
SOURCE=.\dspsvd\svd_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspsvd\svd_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspsvd\svd_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspsvd\svd_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspsvd\svdcopy_rt.c
# End Source File

# End Group

# Begin Group "dspunwrap"

# Begin Source File
SOURCE=.\dspunwrap\unwrap_d_nrip_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspunwrap\unwrap_d_nrop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspunwrap\unwrap_d_ripf_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspunwrap\unwrap_d_rips_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspunwrap\unwrap_d_ropf_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspunwrap\unwrap_d_rops_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspunwrap\unwrap_r_nrip_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspunwrap\unwrap_r_nrop_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspunwrap\unwrap_r_ripf_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspunwrap\unwrap_r_rips_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspunwrap\unwrap_r_ropf_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspunwrap\unwrap_r_rops_rt.c
# End Source File

# End Group

# Begin Group "dspupfir"

# Begin Source File
SOURCE=.\dspupfir\upfir_copydata_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfir\upfir_df_dblbuf_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfir\upfir_df_dblbuf_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfir\upfir_df_dblbuf_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfir\upfir_df_dblbuf_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfir\upfir_df_dblbuf_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfir\upfir_df_dblbuf_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfir\upfir_df_dblbuf_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfir\upfir_df_dblbuf_zz_rt.c
# End Source File

# End Group

# Begin Group "dspupfirdn"

# Begin Source File
SOURCE=.\dspupfirdn\upfirdn_cc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfirdn\upfirdn_cr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfirdn\upfirdn_dd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfirdn\upfirdn_dz_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfirdn\upfirdn_rc_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfirdn\upfirdn_rr_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfirdn\upfirdn_zd_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspupfirdn\upfirdn_zz_rt.c
# End Source File

# End Group

# Begin Group "dspvfdly"

# Begin Source File
SOURCE=.\dspvfdly\vfdly_clip_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspvfdly\vfdly_clip_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspvfdly\vfdly_fir_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspvfdly\vfdly_fir_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspvfdly\vfdly_fir_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspvfdly\vfdly_fir_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspvfdly\vfdly_lin_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspvfdly\vfdly_lin_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspvfdly\vfdly_lin_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspvfdly\vfdly_lin_z_rt.c
# End Source File

# End Group

# Begin Group "modver"

# Begin Source File
SOURCE=.\modver\modver.cpp
# End Source File

# End Group

# Begin Group "dspwindow"

# Begin Source File
SOURCE=.\dspwindow\window_1ch_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspwindow\window_1ch_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspwindow\window_1ch_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspwindow\window_1ch_z_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspwindow\window_nch_c_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspwindow\window_nch_d_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspwindow\window_nch_r_rt.c
# End Source File

# Begin Source File
SOURCE=.\dspwindow\window_nch_z_rt.c
# End Source File

# End Group

# Begin Source File
SOURCE=.\EXPORTS\dsp_rt.def
# End Source File

# Begin Group "Import Libs"
# End Group


# End Target

# End Project
