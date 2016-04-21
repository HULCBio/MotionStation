function code_chart_source_file(fileNameInfo,...
                                chart)


%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.103.4.3.4.1 $  $Date: 2004/04/13 03:12:38 $

   global  gTargetInfo

   if(gTargetInfo.codingSFunction)
       code_chart_source_file_sfun(fileNameInfo,chart);
   elseif(gTargetInfo.codingRTW)
       code_chart_source_file_rtw(fileNameInfo,chart);
   else
       code_chart_source_file_custom(fileNameInfo,chart);
   end

