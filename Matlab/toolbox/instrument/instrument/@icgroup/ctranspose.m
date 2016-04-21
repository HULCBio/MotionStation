function obj = ctranspose(obj)
%' Complex conjugate transpose.   
% 
%   B = CTRANSPOSE(OBJ) is called for the syntax OBJ' (complex conjugate
%   transpose) when OBJ is a device group object array.
%

%    MP 6-25-02
%    Copyright 1999-2004 The MathWorks, Inc. 
%    $Revision: 1.1.6.2 $  $Date: 2004/01/16 19:59:43 $

% Transpose the jobject vector.
jobject = igetfield(obj, 'jobject');
obj = isetfield(obj, 'jobject', jobject');