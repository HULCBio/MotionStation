function lut = lutbridge()
%LUTBRIDGE Compute "bridge" look-up table.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.10.4.1 $  $Date: 2003/01/26 06:00:04 $

lut = [ ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     1     1     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     1     0     0 ...
     0     1     0     0     1     1     0     0     1     1     0     0 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     0     0     1     1     1     1     1     1 ...
     0     0     0     0     1     1     0     0     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     0     0 ...
     1     1     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     1     1     1 ...
     1     1     1     1     0     0     0     0     1     1     0     0 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     0     1     0     0     0     1     0     0 ...
     0     0     0     0     0     0     0     0     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     0     1     1     1     1     1     1     1     0     0     0     0 ...
     1     1     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     1     0     0 ...
     0     1     0     0     0     0     0     0     0     0     0     0 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     0     1     1     1     0     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     0     1     0     0     0     1     0     0     1     1     0     0 ...
     1     1     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     0     0     1     1     0     0     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     0     1     1     1     1     1     1     1     0     0     0     0 ...
     1     1     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     1     0     0 ...
     0     1     0     0     0     0     0     0     0     0     0     0 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     0     1     1     1     1     1     1     1 ...
     0     0     0     0     1     1     0     0     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     0     1     0     0     0     1     0     0     0     0     0     0 ...
     0     0     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1];

lut = lut(:);