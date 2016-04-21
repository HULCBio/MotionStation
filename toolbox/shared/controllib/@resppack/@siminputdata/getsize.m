function s = getsize(this)
%GETSIZE  Returns grid size required for plotting data. 
%
%   S = GETSIZE(THIS) returns the plot size needed to render the
%   data (S(1) is the number of rows and S(2) the number of columns).
%   The value [0 0] indicates that the data is invalid, and NaN's 
%   is used for arbitrary sizes.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:34 $
if isequal(size(this.Amplitude),[length(this.Time) 1])
   s = [NaN 1];  % row size undetermined
else
   s = [0 0];  % invalid data
end