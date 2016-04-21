function obj = ctranspose(obj)
%' Complex conjugate transpose.   
% 
%   B = CTRANSPOSE(OBJ) is called for the syntax OBJ' (complex conjugate
%   transpose) when OBJ is an instrument object array.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.6.2.3 $  $Date: 2004/01/16 20:00:49 $

% Transpose the jobject vector.
jobject = igetfield(obj, 'jobject');
obj = isetfield(obj, 'jobject', jobject');