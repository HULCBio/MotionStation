function makecontentsfile(dirname,option)
%MAKECONTENTSFILE  Make a new Contents.m file.
%   MAKECONTENTSFILE(dirname, option)
%   If OPTION equals 'force', then any existing Contents.m file is
%   over-written.

%   Copyright 1984-2004 The MathWorks, Inc.

if nargin < 1
    dirname = cd;
end

if nargin < 2
    option = '';
end

d = dir([dirname filesep '*.m']);

maxNameLen = 0;
killIndex = [];
noContentsFlag = 1;
for n = 1:length(d)
    d(n).mfilename = regexprep(d(n).name,'\.m$','');
    if strcmp(d(n).mfilename,'Contents')
        % Special case: remove the Contents.m file from the list
        % Contents.m should not list itself.
        killIndex = n;
        noContentsFlag = 0;
    else
        d(n).description = getdescription(d(n).name);
        maxNameLen = max(length(d(n).mfilename), maxNameLen);
    end
end
d(killIndex) = [];


maxNameLenStr = num2str(maxNameLen);

if noContentsFlag || strcmp(option,'force')
    [fid,errMsg] = fopen('Contents.m','w');
    if fid < 0
        error('File error: %s',errMsg)
    end
    [pth,nm] = fileparts(dirname);
    fprintf(fid,'%% %s\n%%\n',upper(nm));
    fprintf(fid,'%% Files\n');
    for n = 1:length(d)
        fprintf(fid,['%%   %-' maxNameLenStr 's - %s\n'], ...
            d(n).mfilename, d(n).description);
    end
    fclose(fid);
else
    error('Contents.m file already exists')
end
