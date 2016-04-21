function [lim,strict] = getlowerbound(hOutlier)
%GETLOWERBOUND Get the lower bound for an exclusion rule

% $Revision: 1.1.6.2 $  $Date: 2004/01/24 09:34:57 $
% Copyright 2003-2004 The MathWorks, Inc.

% Start with default, indicating no lower bound
lim = -Inf;
strict = false;

% Get the real bound if it has a valid definition
if ~isempty(hOutlier.YLow)
   try
      lim = str2num(hOutlier.YLow);
      strict = (hOutlier.YLowLessEqual == 1);
   catch
   end
end
