function y = isbw(x)
%ISBW Return true for binary image.
%   FLAG = ISBW(A) returns 1 if A is a binary image and 0
%   otherwise.
%
%   A is considered to be a binary image if it is a nonsparse 
%   logical array.
%
%   Class Support
%   -------------
%   A can be any MATLAB array.
%
%   See also ISIND, ISGRAY, ISRGB.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.22.4.1 $  $Date: 2003/01/26 05:56:44 $

wid = sprintf('Images:%s:obsoleteFunction',mfilename);
str1= sprintf('%s is obsolete and may be removed in the future.',mfilename);
str2 = 'See product release notes for more information.';
msg= sprintf('%s\n%s',str1,str2);
warning(wid,'%s',msg);

checknargin(1,1,nargin,mfilename);
y = islogical(x) & ~issparse(x);
