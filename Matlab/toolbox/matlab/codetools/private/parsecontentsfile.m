function ct = parsecontentsfile(fname);
%PARSECONTENTSFILE  Generate an M-file list from the Contents.m file.

%   Copyright 1984-2003 The MathWorks, Inc.

if nargin < 1
    fname = 'Contents.m';
end

if isempty(dir(fname))
    % No Contents.m file
    ct = [];
    return
end

suppressFnameFlag = getpref('dirtools','suppressFnameFlag',1);

mflist = [];
ct = [];
f = textread(fname,'%s','delimiter','\n','whitespace','');
for n = 1:length(f)
    
    ct(n).text = f{n};
    ct(n).ismfile = 0;
    ct(n).mfilename = '';
    ct(n).description = '';
    
    % First check to see if it is a description, file, or blank
    if ~isempty(regexp(f{n},'^\%\s*\w+.*\s+-\s+.*$'))
        ct(n).type = 'file';       
        
        tokens = regexp(f{n},'^\%\s*(\w*)\s*-\s+(.*)$','tokens','once');
        
        if ~isempty(tokens)
            fname = tokens{1};
            if length(tokens) > 1
                descr = tokens{2};

                if suppressFnameFlag
                    % Remove the name of the function from the description to
                    % decrease redundancy
                    pattern = ['^' upper(fname) '\s*'];
                    descr = regexprep(descr, pattern, '');
                end
            else
                descr = '';
            end
            % Convert 1x0 string to '' empty string
            if isempty(descr) 
                descr = '';
            end
            
            ct(n).ismfile = 1;
            ct(n).mfilename = fname;
            ct(n).description = descr;
        end

    elseif regexp(f{n},'^\%\s*\w+')
        ct(n).type = 'nonfile';
        tokens = regexp(f{n},'\%\s*(.*)$','tokens','once');
        if ~isempty(tokens)
            ct(n).description = tokens{1};
        end
    
    elseif regexp(f{n},'^\%')
        ct(n).type = 'blank';
        
    else
       ct(n).type = 'cut';
            
    end
end
