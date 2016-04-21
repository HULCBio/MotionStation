function disp(obj)
%DISP   DISP for CDFEPOCH object.

%   binky
%   Copyright 2001-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:57:33 $

% If obj is not scalar, then just display the size
s = size(obj);
if ~isequal(s,[1 1])
    disp(sprintf(['     [%dx%d cdfepoch]'], s(1), s(2)));
else
    disp(['     ' datestr(todatenum(obj),0)]);
end