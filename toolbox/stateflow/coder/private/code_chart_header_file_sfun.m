function code_chart_header_file_sfun(fileNameInfo,...
										  chart)


%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.8.2.1 $  $Date: 2004/04/13 03:12:38 $

   global gTargetInfo gChartInfo

	chartNumber = sf('get',chart,'chart.number');
	chartUniqueName = sf('CodegenNameOf',chart);

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartHeaderFiles{chartNumber+1});
    sf_echo_generating('Coder',fileName);

	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
		return;
	end

fprintf(file,'#ifndef __%s_h__\n',chartUniqueName);
fprintf(file,'#define __%s_h__\n',chartUniqueName);
fprintf(file,'\n');
fprintf(file,'/* Include files */\n');
fprintf(file,'#include "sfc_sf.h"\n');
fprintf(file,'#include "sfc_mex.h"\n');

   if gChartInfo.hasTestPoint
fprintf(file,'#include "rtw_capi.h"\n');
fprintf(file,'#include "rtw_modelmap.h"\n');
   end

fprintf(file,'\n');

   file = dump_module(fileName,file,chart,'header');
   if file < 3
     return;
   end

fprintf(file,'extern void sf_%s_get_check_sum(mxArray *plhs[]);\n',chartUniqueName);
fprintf(file,'extern void %s_method_dispatcher(SimStruct *S, int_T method, void *data);\n',chartUniqueName);
fprintf(file,'\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
	fclose(file);
	try_indenting_file(fileName);

