function rtw_delete_file(fileName, force)
% RTW_DELETE_FILE: delete.m and copyfile.m are much slower in R14 due to
% new added functionality. To speed up rtwbuild process, we provide wraps
% up around built-in copyfile and built-in delete. 

% Copyright 2003 The MathWorks, Inc.

% following line is for test speed up of fast Vs. slow copy_file.
%if 0
%    delete(fileName);
%    return
%end
if nargin >= 2
    if force
        if ispc
            dos(['attrib -r ', fileName]);
        else
            unix(['chmod +w ', fileName]);
        end
    end
end

builtin('delete', fileName);
