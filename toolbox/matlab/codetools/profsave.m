function profsave(profInfo, dirname)
%PROFSAVE  Save a static version of the HTML profile report
%   PROFSAVE(PROFINFO) saves HTML files that correspond to each of the
%   files in the profiler data structure's FunctionTable.
%   PROFSAVE(PROFINFO, DIRNAME) saves the files in the specified directory
%   PROFSAVE by itself uses the results from the call PROFILE('INFO')
%
%   Example:
%   profile on
%   plot(magic(5))
%   profile off
%   profsave(profile('info'),'profile_results')
%
%   See also PROFILE, PROFVIEW.

%   Copyright 1984-2004 The MathWorks, Inc.

if nargin < 1
    profInfo = profile('info');
end

if nargin < 2
    dirname = 'profile_results';
end

[pth,nm] = fileparts(dirname);

if isempty(pth)
    fullDirname = fullfile(cd,dirname);
else
    fullDirname = dirname;
end


if ~exist(fullDirname,'dir')
    [success, message] = mkdir(fullDirname);
    if ~success
        error(message)
        return
    end
end
    
for n = 0:length(profInfo.FunctionTable)
    str = profview(n,profInfo);
    
    str = regexprep(str,'<a href="matlab: profview\((\d+)\);">','<a href="file$1.html">');
    % The question mark makes the .* wildcard non-greedy
    str = regexprep(str,'<a href="matlab:.*?>(.*?)</a>','$1');
    % Remove all the forms
    str = regexprep(str,'<form.*?</form>','');

    insertStr = ['<body bgcolor="#F8F8F8"><strong>This is a static copy of a profile report</strong><p/>' ...
        '<a href="file0.html">Home</a><p/>'];
    str = strrep(str,'<body>',insertStr);

    filename = fullfile(fullDirname,sprintf('file%d.html',n));
    fid = fopen(filename,'w');
    if fid > 0
        fprintf(fid,'%s',str);
        fclose(fid);
    else
        error('Can''t open file')
    end
    
end

web(['file:///' fullfile(fullDirname,'file0.html')],'-browser');
