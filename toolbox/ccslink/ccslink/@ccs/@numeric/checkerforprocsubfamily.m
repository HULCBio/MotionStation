function sv = checkerforprocsubfamily(nn,usersSV)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.6.2 $  $Date: 2003/11/30 23:09:43 $

if strcmp(usersSV,'C6x'),
    nn.bitsperstorageunit = 8;    
elseif strcmp(usersSV,'C54x'),
    nn.bitsperstorageunit = 16;    
elseif strcmp(usersSV,'C55x'),
    nn.bitsperstorageunit = 16;
elseif strcmp(usersSV,'C28x'),
    nn.bitsperstorageunit = 16;
elseif any(strcmp(usersSV,{'R1x','R2x'})),
    nn.bitsperstorageunit = 8;    
else
    error('Processor not supported');
end
sv = usersSV;
nn.wordsize = (nn.storageunitspervalue  * nn.bitsperstorageunit) - nn.postpad - nn.prepad;
if nn.storageunitspervalue~=0
    nn.numberofstorageunits = nn.storageunitspervalue * prod(nn.size);
end

% [EOF] checkerforprocsubfamily.m