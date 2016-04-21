function [lim,strict] = getupperbound(hOutlier)
%GETUPPERBOUND Get the upper bound for an exclusion rule

% $Revision: 1.1.6.2 $  $Date: 2004/01/24 09:34:58 $
% Copyright 2003-2004 The MathWorks, Inc.

% Start with default, indicating no upper bound
lim = Inf;
strict = false;

% Get the real bound if it has a valid definition
if ~isempty(hOutlier.YHigh)
   try
      lim = str2num(hOutlier.YHigh);
      strict = (hOutlier.YHighGreaterEqual == 1);
   catch
   end
end
