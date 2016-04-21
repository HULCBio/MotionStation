function sv = checkerforprocsubfamily(nn,usersSV)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:09:14 $

if strcmp(usersSV,'C6x'),
    nn.bitsperstorageunit = 8;    
elseif strcmp(usersSV,'C54x'),
    nn.bitsperstorageunit = 16;    
elseif any(strcmp(usersSV,{'R1x','R2x'})),
    nn.bitsperstorageunit = 8;    
else
    error('Processor not supported');
end
sv = usersSV;

% [EOF] checkerforprocsubfamily.m