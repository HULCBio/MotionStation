function obj = ctranspose(obj)
% ' Complex conjugate transpose.   
% 
%    B = CTRANSPOSE(OBJ) is called for the syntax OBJ' (complex conjugate
%    transpose) when OBJ is a timer object array.
%

%    RDD 1-15-2002
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.2 $  $Date: 2002/03/14 14:34:23 $

% Transpose the jobject vector.
obj.jobject = obj.jobject';