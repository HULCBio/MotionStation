function code_machine_source_file(fileNameInfo,machine,target)
% CODE_MACHINE_SOURCE_FILE(FILENAMEINFO,MACHINE,TARGET)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.40.2.2.4.1 $  $Date: 2004/04/13 03:12:39 $

	global gTargetInfo 

	if(gTargetInfo.codingSFunction)
    	code_machine_source_file_sfun(fileNameInfo);
	elseif(gTargetInfo.codingRTW)
    	code_machine_source_file_rtw(fileNameInfo);
   else
    	code_machine_source_file_custom(fileNameInfo);
	end

