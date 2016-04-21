function inSync = check_if_file_is_in_sync(fileName,lastBuildDate,dontCheckDates)
% INSYNC = CHECK_IF_FILE_IS_IN_SYNC( FILENAME, SYNCDATE,DONTCHECKDATES)
% Returns 1 if the file represented by FILENAME exists and is older than the
% sf_date_num represented by SYNCDATE. Else returns a zero. 
% If optional DONTCHECKDATES is passed in and is non-zero, we only check for the existence
% and skip he date comparison
% This function is used by the incremental code generation and compiler manager
% for checking if mexopts.bat has changed.
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.9.2.2 $  $Date: 2004/04/15 00:56:14 $
   
   inSync = 0;
   
   if(nargin<3)
      dontCheckDates = 0;
   end
	if(isempty(fileName) || ~exist(fileName,'file'))
		return;
   end
   
   if(dontCheckDates==0)
      fileDirInfo = dir(fileName);
      
      if(sf_date_num(fileDirInfo.date)>lastBuildDate)
         return;
      end
   end
   inSync = 1;
   return;
