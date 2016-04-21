function fixcontents(fname,action,target)
%FIXCONTENTS  Helper function for CONTENTSRPT
%   FIXCONTENTS(fname, action, target)
%   action and target can both be vectors of the same length.

% Copyright 1984-2003 The MathWorks, Inc.

if nargin==0
    fname = 'Contents.m';
    action = 'all';
end

if strcmp(action,'prettyprint')
    action = {action};
    target = {};
    
elseif strcmp(action,'all')
    dirname = fileparts(fname);
    if isempty(dirname)
        dirname = cd;
    end
    if isempty(dir(fname))
        makecontentsfile(dirname)
        return
    end
    action = {};
    target = {};
    [ct, ex, dr] = auditcontents(dirname);

    for n = 1:length(ct)
        if ~isempty(ct(n).action)
            action{end+1} = ct(n).action;
            target{end+1} = ct(n).mfilename;
        end
    end
    for n = 1:length(ex)
        action{end+1} = 'append';
        fileStr = regexprep(ex(n).contentsline,'-.*$','');
        target{end+1} = fileStr;
    end
    
else
    action = {action};
    target = {target};
end

% Read in the Contents.m file
f = textread(fname,'%s','delimiter','\n','whitespace','');

for i = 1:length(action)
    switch action{i}
        case 'update'
            for j = 1:length(f)
                % First check to see if it is a description, file, or blank
                if isempty(f{j})
                    f{j} = '';
                end
                
                if ~isempty(regexp(f{j},['^\%\s*' target{i} '\s+-\s+.*$'],'once'))
                    descr = getdescription(target{i});

                    ndx = strfind(f{j},' - ');
                    if ~isempty(ndx)
                        f{j} = [f{j}(1:(ndx-1)) ' - ' descr];
                    end
                    break
                end
            end

        case 'updatefromcontents'
            % Copy the description line from the Contents.m file to the 
            suppressFnameFlag = getpref('dirtools','suppressFnameFlag',1);

            fname2 = which(target{i});
            f2 = textread(fname2,'%s','delimiter','\n','whitespace','');
            descr = getdescription(target{i},0);

            
            for j = 1:length(f)
                tk = regexp(f{j},['^\%\s*' target{i} '\s+-\s+(.*)$'],'tokens','once');
                if ~isempty(tk)
                    for k = 1:length(f2)
                        % Find the description line and replace it with the
                        % one from the Contents.m file
                        if strfind(f2{k},descr)
                            f2{k} = ['%' upper(target{i}) ' ' tk{1}];
                            break
                        end                        
                    end
                    break
                end
            end

            writefile(fname2,f2)

        case 'remove'
            for j = 1:length(f)
                if isempty(f{j})
                    f{j} = '';
                end
                % First check to see if it is a description, file, or blank
                if ~isempty(regexp(f{j},['^\%\s*' target{i} '\s+-\s+.*$'],'once'))
                    f{j} = [];
                    break
                end
            end

        case 'append'
            filename = target{i};
            filename(filename==32) = [];
            descr = getdescription(filename,0);
            f{end+1} = ['%' target{i} '- ' descr];

        case 'prettyprint'
            ct = parsecontentsfile(fname);
            maxNameLen = 0;
            for j = 1:length(ct)
                if ct(j).ismfile
                    maxNameLen = max(length(ct(j).mfilename), maxNameLen);
                end
            end
            maxNameLenStr = num2str(maxNameLen);

            f = {};
            for j = 1:length(ct)
                if ct(j).ismfile
                    f{end+1} = sprintf(['%%   %-' maxNameLenStr 's - %s'], ...
                        ct(j).mfilename, ct(j).description);
                else
                    f{end+1} = ct(j).text;
                end
            end

        otherwise
            error('Unknown option %s',action{i})
    end

end
writefile(fname,f)



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
