function sf_delete_file(fileName, force)

% Copyright 2003 The MathWorks, Inc.

if nargin >= 2
    if force
        if ispc
            dos(['attrib -r "', fileName,'"']);
        else
            unix(['chmod +w ', fileName]);
        end
    end
end
if ispc
    dos(['del /f /q "',fileName,'"']);
else
    dos(['rm -f ',fileName]);
end

