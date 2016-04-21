function out = isJavaTimer(obj)
%ISJAVATIMER Returns logical indicating if object is a Java timer
%
%    ISJAVATIMER(OBJ) returns a logical indicating if OBJ is a
%    instance of the java timer object.

%    RDD 1-18-2002
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.3 $  $Date: 2002/03/14 14:35:16 $

out = false;
for lcv=1:length(obj)
    out(lcv) = isa(obj(lcv),'javahandle.com.mathworks.timer.TimerTask');
end

% Reshape the out variable to be the same shape as the input object.
% This is needed is obj is a column vector.
if (size(out) ~= size(obj))
    out = out';
end