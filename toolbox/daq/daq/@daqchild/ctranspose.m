function newobj = ctranspose(obj)
% ' Complex conjugate transpose.   
% 
%    B = CTRANSPOSE(OBJ) is called for the syntax OBJ' (complex conjugate
%    transpose) when OBJ is a channel or line.

%    MP 4-17-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.9.2.4 $  $Date: 2003/08/29 04:40:08 $

% Error if an invalid handle was passed.
if ~all(isvalid(obj))
   error('daq:transpose:invalidobject', 'One of the objects is invalid and cannot be transposed.');
end

% Transpose the channel or line vector.
x = struct(obj);
newobj = feval(class(obj), x.handle');

