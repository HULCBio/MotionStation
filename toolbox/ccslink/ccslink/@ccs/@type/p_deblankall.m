function str = p_deblankall(obj,str)

%   $Revision: 1.2.4.1 $  $Date: 2003/11/30 23:14:04 $
%   Copyright 2002-2003 The MathWorks, Inc.
len = length(str);
str = deblank( str(len:-1:1) );
str = deblank( str(length(str):-1:1) );

% [EOF] p_deblankall.m

