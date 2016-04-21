function sysout = hdsNewArray(sys,Size)
%HDSNEWARRAY  Creates new array of specified size and type.
%
%   New array entries are initialized with a filler specific
%   to the data type.  The data type is determine by the first 
%   argument.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:49 $
s = size(sys);
a = zeros([s(1:2) Size]);
a(:) = NaN;
sysout = feval(class(sys),a);