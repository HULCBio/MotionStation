function code_machine_header_file(fileNameInfo)
% CODE_MACHINE_HEADER_FILE(FILENAMEINFO)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.49.2.2.4.1 $  $Date: 2004/04/13 03:12:38 $

	global gTargetInfo

   if(gTargetInfo.codingSFunction)
      code_machine_header_file_sfun(fileNameInfo);
   elseif(gTargetInfo.codingRTW)
      code_machine_header_file_rtw(fileNameInfo);
   else
      code_machine_header_file_custom(fileNameInfo);
   end

	 		