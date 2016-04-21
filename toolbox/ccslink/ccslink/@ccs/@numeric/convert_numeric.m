function mm = convert_numeric(mm,datatype,siz)
% Private. Object conversion.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.12.6.2 $ $Date: 2003/11/30 23:09:48 $

if ~ishandle(mm),
    error('First Parameter must be a NUMERIC Handle.');
end
if ~ischar(datatype),
     error('Second Parameter must be a string.');
end
if nargin==3,
    siz = p_checkerforsize(mm,siz,'Third Parameter');
end

% Initialize (pre/post)pad
mm.prepad  = 0;  % Modified later, if necessary
mm.postpad = 0;

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
if nargin==3,
    reshape(mm,siz);
end

% [EOF] convert_numeric.m
