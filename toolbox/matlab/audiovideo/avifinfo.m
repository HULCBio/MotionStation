function [m,d] = avifinfo(filename)
%AVIFINFO Text description of AVI-file contents.

% Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:42 $

d = evalc('disp(aviinfo(filename))','-1');
if d == -1
    d = '';
    m = '';
else
    m = 'AVI-File';
end
