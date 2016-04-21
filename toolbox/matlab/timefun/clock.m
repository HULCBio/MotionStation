function [varargout] = clock(varargin)
%CLOCK  Current date and time as date vector.
%   CLOCK returns a six element date vector vector containing the
%   current time and date in decimal form:
% 
%      CLOCK = [year month day hour minute seconds]
% 
%   The first five elements are integers. The seconds element
%   is accurate to several digits beyond the decimal point.
%   FIX(CLOCK) rounds to integer display format.
%
%   See also DATEVEC, DATENUM, NOW, ETIME, TIC, TOC, CPUTIME.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.11.4.2 $  $Date: 2004/04/10 23:32:12 $
%   Built-in function.

if nargout == 0
  builtin('clock', varargin{:});
else
  [varargout{1:nargout}] = builtin('clock', varargin{:});
end
