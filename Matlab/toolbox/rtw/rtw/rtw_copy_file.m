function [copySuccess, errMsg] = rtw_copy_file(src,dst)
% RTW_COPY_FILE: delete.m and copyfile.m are much slower in R14 due to
% new added functionality. To speed up rtwbuild process, we provide wraps
% up around built-in copyfile and built-in delete. 

% Copyright 2003 The MathWorks, Inc.

% following line is for test speed up of fast Vs. slow copy_file.
%if 0
%    [copySuccess, errMsg] = copyfile(src,dst);
%    return
%end
if ispc
    dos(['copy "', src, '" "', dst, '"']);
else
    unix(['cp ', src, ' ', dst]);
end

copySuccess = exist(dst,'file');
errMsg = '';
if(~copySuccess) 
    errMsg = sprintf('copying %s to %s failed.',src,dst);
end