function code_chart_source_file_sfun(fileNameInfo,chart)


%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.5.4.1 $  $Date: 2004/04/13 03:12:38 $


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%  GLOBAL VARIABLES
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%%%%%%%%%%%%%%%%%%%%%%% Coding options
   global gTargetInfo  gChartInfo gMachineInfo

 	chartNumber = sf('get',chart,'chart.number');
	chartUniqueName = sf('CodegenNameOf',chart);

   fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartSourceFiles{chartNumber+1});
   sf_echo_generating('Coder',fileName);

   file = fopen(fileName,'wt');
   if file<3
      construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
      return;
   end

fprintf(file,'/* Include files */\n');

fprintf(file,'#include "%s"\n',[fileNameInfo.machineHeaderFile(1:end-length(fileNameInfo.headerExtension)),'.h']);
fprintf(file,'#include "%s"\n',[fileNameInfo.chartHeaderFiles{chartNumber+1}(1:end-length(fileNameInfo.sourceExtension)),'.h']);

   if(gChartInfo.codingDebug)
fprintf(file,'#define CHARTINSTANCE_CHARTNUMBER (%schartNumber)\n',gChartInfo.chartInstanceVarName);
fprintf(file,'#define CHARTINSTANCE_INSTANCENUMBER (%sinstanceNumber)\n',gChartInfo.chartInstanceVarName);
fprintf(file,'#include "%s"\n',fileNameInfo.sfDebugMacrosFile);
   end

   file = dump_module(fileName,file,chart,'source');
   if file < 3
     return;
   end


   file = code_sfun_glue_code(fileNameInfo,file,chart,chartUniqueName);
fprintf(file,'\n');
   fclose(file);
   try_indenting_file(fileName);
   sf('Cg','destroy_module',chart);








