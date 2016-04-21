function sv = checkerforprocsubfamily(nn,usersSV)

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/11/30 23:06:21 $

if any(strcmp(usersSV,{'R1x','R2x','C6x'})),
    nn.bitsperstorageunit = 8;    
elseif any(strcmp(usersSV,{'C54x','C55x','C28x'})),
    nn.bitsperstorageunit = 16;
else
    error(generateccsmsgid('ProcessorNotSupported'),'Processor not supported');
end
sv = usersSV;
nn.wordsize = (nn.storageunitspervalue  * nn.bitsperstorageunit) - nn.postpad - nn.prepad;
if nn.storageunitspervalue~=0
    nn.numberofstorageunits = nn.storageunitspervalue * prod(nn.size);
end
