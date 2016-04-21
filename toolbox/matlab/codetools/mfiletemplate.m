function outStr = mfiletemplate(option,filename,description)
%MFILETEMPLATE  Template for new M-files
%   MFILETEMPLATE(OPTION,FILENAME,DESCRIPTION)
%   OPTION = { full | description | copyright }

% Copyright 1984-2003 The MathWorks, Inc.

if nargin < 1
    option = 'full';
end

if nargin < 2
    filename = '';
end

if nargin < 3
    description = '';
end

if strcmp(option,'description')
    s = {[upper(filename) '  ' description]};
    
else
    f = textread(which('template.m'),'%s','delimiter','\n','whitespace','');
    s = f;

    copyrightLine = '';

    for n = 1:length(f)
        str = f{n};
        str = strrep(str,'$filename',filename);
        str = strrep(str,'$FILENAME',upper(filename));
        str = strrep(str,'$description',description);
        if ~isempty(strfind(str,'$date'))
            match = regexp(str,'\$date\((.*?)\)','match','once');
            if ~isempty(match)
                token = regexp(match,'\((.*?)\)','tokens','once');
                str = strrep(str,match,datestr(now,token{1}));
            end
        end
        if ~isempty(strfind(lower(str),'copyright'))
            copyrightLine = str;
        end
        s{n} = str;
    end

    if strcmp(option,'copyright')
        s = {copyrightLine};
    end
end

str = sprintf('%s\n',s{:});
% Pull off the last \n
str(end) = [];
outStr = str;

