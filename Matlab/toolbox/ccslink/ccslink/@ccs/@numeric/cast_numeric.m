function mm = cast_numeric(nn,datatype,siz)
% Private. Cast to another object with different datatype.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.10.6.3 $ $Date: 2003/11/30 23:09:40 $

if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a NUMERIC handle.');
end
if ~ischar(datatype),
     error(generateccsmsgid('InvalidInput'),'Second Parameter must be a string.');
end
if nargin==3,
    siz = p_checkerforsize(nn,siz,'Third Parameter');
end

% Copy constructor
mm = copy(nn);

% Convert datatype
if any(strcmp(mm.procsubfamily,{'R1x','R2x'})), % Rxx
    cast_Rxx(mm,datatype); 
elseif strcmp(mm.procsubfamily,'C6x'), % C6x
    cast_C6xx(mm,datatype);
elseif strcmp(mm.procsubfamily,'C54x'), % C5x
    cast_C54x(mm,datatype);
elseif strcmp(mm.procsubfamily,'C55x'), % C55x 
    cast_C55x(mm,datatype);
elseif strcmp(mm.procsubfamily,'C28x'), % C28x 
    cast_C28x(mm,datatype);
else
    error('Processor not supported');
end

% Reshape dimension of MM
if nargin==3,
    reshape(mm,siz);
end

% [EOF] cast.m
