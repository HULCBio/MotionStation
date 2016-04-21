function mm = cast_rnumeric(rn,datatype,siz)
% Private. Cast to another object with different datatype.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.9.6.2 $  $Date: 2003/11/30 23:11:18 $

if ~ishandle(rn),
    error('First Parameter must be an RNUMERIC handle.');
end
if ~ischar(datatype),
     error('Second Parameter must be a string.');
end
if nargin==3
    siz = p_checkerforsize(rn,siz,'Third Parameter');
end

% Copy constructor
mm = copy(rn);

% Convert datatype
if strcmp(mm.procsubfamily,'C6x'), % C6x
    cast_C6xx(mm,datatype);
elseif strcmp(mm.procsubfamily,'C54x'), % C54x
    cast_C54x(mm,datatype);
elseif strcmp(mm.procsubfamily,'C55x'), % C55x
    cast_C55x(mm,datatype);
elseif strcmp(mm.procsubfamily,'C28x'), % C28x
    cast_C28x(mm,datatype);
elseif any(strcmp(mm.procsubfamily,{'R1x','R2x'})), % Rxx
    cast_Rxx(mm,datatype);
else
    error('Processor not supported');
end

% Reshape dimension of MM
if nargin==3 
    reshape(mm,siz);
end

% [EOF] cast_rnumeric.m
