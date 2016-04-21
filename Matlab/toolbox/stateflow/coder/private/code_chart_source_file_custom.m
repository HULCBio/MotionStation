function code_chart_source_file_custom(fileNameInfo,chart)


%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2.4.1 $  $Date: 2004/04/13 03:12:38 $


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%  GLOBAL VARIABLES
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%%%%%%%%%%%%%%%%%%%%%%% Coding options
   global gTargetInfo  gChartInfo gMachineInfo

   chartNumber = sf('get',chart,'chart.number');
   fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartSourceFiles{chartNumber+1});
   sf_echo_generating('Coder',fileName);

   file = fopen(fileName,'wt');
   if file<3
      construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
      return;
   end
fprintf(file,'%s\n',get_boiler_plate_comment('chart',chart));

fprintf(file,'/* Include files */\n');

fprintf(file,'#include "%s"\n',[fileNameInfo.machineHeaderFile(1:end-length(fileNameInfo.headerExtension)),'.h']);
fprintf(file,'#include "%s"\n',[fileNameInfo.chartHeaderFiles{chartNumber+1}(1:end-length(fileNameInfo.sourceExtension)),'.h']);
fprintf(file,'\n');

   file = dump_module(fileName,file,chart,'source');
   if file < 3
     return;
   end

fprintf(file,'\n');
   fclose(file);
   try_indenting_file(fileName);
   sf('Cg','destroy_module',chart);








