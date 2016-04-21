function s = getsize(this)
%GETSIZE  Returns grid size required for plotting data. 
%
%   S = GETSIZE(THIS) returns the plot size needed to render the
%   data (S(1) is the number of rows and S(2) the number of columns).
%   The value [0 0] indicates that the data is invalid, and NaN's 
%   is used for arbitrary sizes.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:41 $
Size = [size(this.Response) 1];
if Size(1)==length(this.Frequency)
   s = Size([2 3]);
else
   s = [0 0];
end