function res = mcodeIgnoreHandle(this,h)
%MCODEIGNOREHANDLE Code generation customization

%   Copyright 1984-2003 The MathWorks, Inc. 

% no code for scribegrid or its children
if isequal(double(this),double(h))
    res = true;
else
    res = true;
end
