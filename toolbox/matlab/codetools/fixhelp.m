function fixhelp(fname,action)
%FIXHELP  Helper function for HELPRPT

% Copyright 1984-2003 The MathWorks, Inc.

% Read in the file
f = textread(fname,'%s','delimiter','\n','whitespace','');

switch action
    case 'fixcopyright'

        copyrightLine = mfiletemplate('copyright');
        for n = 1:length(f)
            % Find the copyright line and replace it
            if ~isempty(regexpi(f{n},'^\%\s*copyright'))
                f{n} = copyrightLine;
                break
            end
        end
        writefile(fname,f)

    case 'addcopyright'

        copyrightLine = mfiletemplate('copyright');
        belowHelpLine = length(f);
        for n = 1:length(f)
            % Find the last help line (the first line that is neither a
            % function declaration nor a comment line)
            if isempty(regexp(f{n},'^\%','once')) && isempty(regexp(f{n},'^function','once'))
                belowHelpLine = n;
                break
            end
        end
        
        % Insert two new lines just below the last help line
        f = f(sort([1:length(f) belowHelpLine belowHelpLine]));
        f{belowHelpLine} = ' ';
        f{belowHelpLine+1} = copyrightLine;
        
        writefile(fname,f)

    case 'prettyprint'

    otherwise
        error('Unknown option %s',action)

end


function writefile(fname,f)
%WRITEFILE  Save file to disk.

[fid, errMsg] = fopen(fname,'w');
if fid < 0
    error(errMsg)
else
    for n = 1:length(f)
        fprintf(fid,'%s\n',f{n});
    end
    fclose(fid);
end