function code_chart_header_file_custom(fileNameInfo,...
										  chart)


%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3.4.1 $  $Date: 2004/04/13 03:12:38 $

    global gTargetInfo


	chartNumber = sf('get',chart,'chart.number');
	chartUniqueName = sf('CodegenNameOf',chart);

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartHeaderFiles{chartNumber+1});
    sf_echo_generating('Coder',fileName);

	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
		return;
	end

fprintf(file,'%s\n',get_boiler_plate_comment('chart',chart));
fprintf(file,'#ifndef __%s_h__\n',chartUniqueName);
fprintf(file,'#define __%s_h__\n',chartUniqueName);
fprintf(file,'\n');

   file = dump_module(fileName,file,chart,'header');
   if file < 3
     return;
   end

fprintf(file,'\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
	fclose(file);
	try_indenting_file(fileName);

