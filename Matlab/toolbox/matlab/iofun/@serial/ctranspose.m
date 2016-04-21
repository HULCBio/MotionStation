function obj = ctranspose(obj)
%' Complex conjugate transpose.   
% 
%   B = CTRANSPOSE(OBJ) is called for the syntax OBJ' (complex conjugate
%   transpose) when OBJ is a serial port object array.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.3 $  $Date: 2004/01/16 20:04:04 $

% Transpose the jobject vector.
jobject = igetfield(obj, 'jobject');
obj = isetfield(obj, 'jobject', jobject');