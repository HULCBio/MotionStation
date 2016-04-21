function [ctOut, ex, dr] = auditcontents(dirname)
%AUDITCONTENTS  Audit the Contents.m for the given directory
%   [CT, EX, DR] = auditcontents(dirname)
%   CT is a structure containing the Contents.m file line by line
%   EX is a structure containing the files that are in the directory but
%   not in the Contents.m file
%   DR is the list of all M-files in the directory

%   Copyright 1984-2004 The MathWorks, Inc.

if nargin < 1
    dirname = cd;
end

dr = dir([dirname filesep '*.m']);
ct = parsecontentsfile(fullfile(dirname,'Contents.m'));

% Skip to the creation of ex if there is no Contents.m file
if ~isempty(ct)
    maxNameLen = 0;
    killIndex = [];

    for n = 1:length(dr)
        dr(n).mfilename = regexprep(dr(n).name,'\.m$','');
        if strcmp(dr(n).mfilename,'Contents')
            % Special case: remove the Contents.m file from the list
            % Contents.m should not list itself.
            killIndex = n;
        else
            % Add a help element - h1 line only
            dr(n).description = getdescription(dr(n).name);
            maxNameLen = max(length(dr(n).mfilename), maxNameLen);
        end
    end
    dr(killIndex) = [];

    if ~isempty(dr)
        allDirFiles = {dr.mfilename};
    else
        allDirFiles = {};
    end

    % ct is a structure to keep track of the elements of Contents.m
    ctList = {ct.mfilename};
    allContentsFiles = ctList(logical([ct.ismfile]));

    % Put together audit list
    maxNameLenStr = num2str(maxNameLen);
    for n = 1:length(ct)
        fileline = regexprep(ct(n).text,'^%','');
        ct(n).action = '';
        if strcmp(ct(n).type,'file')
            [ismemberFlag,ndx] = ismember(ct(n).mfilename,allDirFiles);
            if ismemberFlag
                if ~strcmp(ct(n).description,dr(ndx).description)
                    % Descriptions don't match
                    ct(n).action = 'update';
                    ct(n).filedescription = dr(ndx).description;
                end
            else
                % File doesn't appear in this directory
                ct(n).action = 'remove';
            end
        end
    end
end
ctOut = ct;

ex = [];
[null, unseenNdx] = setdiff(allDirFiles,allContentsFiles);
dr = dr(unseenNdx);
for n = 1:length(dr)
    % File is in the directory but not in Contents.m
    fileStr = sprintf(['   %-' maxNameLenStr 's - %s'], ...
        dr(n).mfilename, dr(n).description);
    fileStr = fixquote(fileStr);
    ex(n).mfilename = dr(n).mfilename;
    ex(n).description = dr(n).description;
    ex(n).contentsline = fileStr;
end
