function htmlOut = helprpt(name, option)
%HELPRPT  Scan a file or directory for help.

% Copyright 1984-2004 The MathWorks, Inc.

if nargout == 0
    web('text://<html><body>Generating help report...</body></html>','-noaddressbox');
end

if nargin < 1
    option = 'dir';
    name = cd;
end

if nargin == 1
    option = 'file';
end

noContentsFileFlag = 1;
if strcmp(option,'dir')
    dirname = name;
    if isdir(dirname)
        dirFileList = dir([dirname filesep '*.m']);
        fileList = {dirFileList.name};
        % Exclude the Contents file from the list
        for n = 1:length(fileList)
            if strcmp(fileList{n},'Contents.m')
                noContentsFileFlag = 0;
                fileList(n) = [];
                break
            end
        end
    else
        error('%s is not a directory',dirname)
    end
else
    fullname = which(name);
    if isempty(fullname)
        error('file %s not found',name)
    end
    dirname = fileparts(fullname);
    dirFileList = dir([dirname filesep name '.m']);
    fileList = {dirFileList.name};
end

if dirname(1) == '\'
    % mlint.exe cannot be called on a UNC pathname
    web(['text://<body><span style="color:#F00">Help Report cannot run when the current ' ...
        'directory is a UNC pathname.</span></body>'],'-noaddressbox');
    return
end


% Manage the preferences
h1DisplayMode = getpref('dirtools','h1DisplayMode',1);
helpDisplayMode = getpref('dirtools','helpDisplayMode',1);
copyrightDisplayMode = getpref('dirtools','copyrightDisplayMode',1);
helpSubfunsDisplayMode = getpref('dirtools','helpSubfunsDisplayMode',1);
exampleDisplayMode = getpref('dirtools','exampleDisplayMode',1);
seeAlsoDisplayMode = getpref('dirtools','seeAlsoDisplayMode',1);

% First gather all the data
strc = [];
for n = 1:length(fileList)
    filename = fileList{n};

    if helpSubfunsDisplayMode
        callStrc = getcallinfo(filename,'subfuns');
    else
        callStrc = getcallinfo(filename,'file');
    end

    for m = 1:length(callStrc)
        strc(end+1).filename = filename;

        strc(end).name = callStrc(m).name;
        strc(end).type = callStrc(m).type;

        strc(end).firstLine = callStrc(m).firstline;

        if strcmp(strc(end).type,'subfunction')
            helpStr = helpfunc([strc(end).filename filemarker strc(end).name]);
        else
            helpStr = helpfunc(strc(end).filename);
        end
        strc(end).help = code2html(helpStr);

        % Remove any leading spaces and percent signs
        % Grab all the text up to the first carriage return
        helpTkn = regexp(helpStr,'^\s*%*\s*([^\n]*)\n','tokens','once');
        if isempty(helpTkn)
            strc(end).description = '';
        else
            strc(end).description = helpTkn{1};
        end


        % Now we grep through the function line by line looking for
        % copyright, example, and see-also information. Don't bother
        % looking for these things in a subfunction.
        % NOTE: This will not work for Japanese files
        if ~strcmp(strc(end).type,'subfunction')
            
            % Short-circuit the searches if the user doesn't want to see
            % the result
            if copyrightDisplayMode
                copyrightSuccessFlag = 0;
            else
                copyrightSuccessFlag = 1;
            end

            if exampleDisplayMode
                exampleSuccessFlag = 0;
            else
                exampleSuccessFlag = 1;
            end

            if seeAlsoDisplayMode
                seeAlsoSuccessFlag = 0;
            else
                seeAlsoSuccessFlag = 1;
            end

            f = textread(filename,'%s','delimiter','\n','whitespace','');

            strc(end).copyright = '';
            strc(end).example = '';
            strc(end).seeAlso = '';

            for i = 1:length(f)
                % The help report searches only comments that appear before the
                % first executable line of code (i.e. all except the function
                % declaration line). Short-circuit if we've gotten to the first
                % executable line of code.
                
                % If there's no comment character, and it's not the
                % function declaration line, and word characters appear,
                % the code has started: break out of the loop.
                if isempty(strfind(f{i},'%'))
                    if isempty(strfind(f{i},'function'))
                        if ~isempty(regexp(f{i},'\w','once'))
                            break
                        end
                    end
                end
            
                
                if ~copyrightSuccessFlag
                    crTkn = regexp(f{i},'^\s*%\s*Copyright\s+(\d+)-?(\d+)?(.*)$','tokens','once');
                    if ~isempty(crTkn)
                        strc(end).copyright = f{i};
                        strc(end).copyrightLine = i;

                        if isempty(crTkn{1})
                            strc(end).copyrightBeginYear = [];
                        else
                            strc(end).copyrightBeginYear = eval(crTkn{1});
                        end

                        if isempty(crTkn{2})
                            strc(end).copyrightEndYear = strc(n).copyrightBeginYear;
                        else
                            strc(end).copyrightEndYear = eval(crTkn{2});
                        end

                        strc(end).copyrightOrganization = crTkn{3};
                        copyrightSuccessFlag = 1;
                    end
                end

                if ~exampleSuccessFlag
                    exTkn = regexpi(f{i},'^\s*%(\s*examples?:?\s*\d*\s*)$','tokens','once');
                    if ~isempty(exTkn)
                        exampleStr = {' ',exTkn{1}};
                        strc(end).exampleLine = i;

                        % Loop through and grep the entire example
                        % We assume the example ends when there is a blank
                        % line or when the comments end.
                        exampleCompleteFlag = 0;
                        for j = (i+1):length(f)
                            codeTkn = regexp(f{j},'^\s*%(\s*[^\s].*$)','tokens','once');
                            if isempty(codeTkn)
                                exampleCompleteFlag = 1;
                            else
                                exampleStr{end+1} = codeTkn{1};
                            end
                            if exampleCompleteFlag
                                break
                            end
                        end

                        strc(end).example = sprintf('%s\n',exampleStr{:});
                        exampleSuccessFlag = 1;
                    end
                end

                if ~seeAlsoSuccessFlag
                    if strfind(f{i},'See also')
                        seeTkn = regexpi(f{i},'^\s*%\s*(See also:? .*)$','tokens','once');
                        if ~isempty(seeTkn)
                            strc(end).seeAlso = seeTkn{1};
                            strc(end).seeAlsoLine = i;
                            % Remove the pattern "See also"
                            seeFcns = strrep(seeTkn{1},'See also','');
                            strc(end).seeAlsoFcnList = regexpi(seeFcns,'(\w+)','tokens');
                        end
                    end
                end

                if copyrightSuccessFlag && exampleSuccessFlag && seeAlsoSuccessFlag
                    % No need to keep grep'ing once you've found everything
                    break
                end
                
            end
        end


    end

end


% Generate the HTML
s = {};
s{1} = makeheadhtml;
s{end+1} = '<title>Help Report</title>';
s{end+1} = '</head>';
s{end+1} = '<body>';

% Make the form
s{end+1} = '<form method="post" action="matlab:visdirrefresh">';
s{end+1} = '<input type="hidden" name="reporttype" value="helprpt" />';
s{end+1} = '<input type="submit" value="Refresh" />';
s{end+1} = '</form>';

s{end+1} = '<form method="post" action="matlab:visdirformhandler">';
s{end+1} = '<input type="hidden" name="reporttype" value="helprpt" />';
s{end+1} = '<table cellspacing="8">';
s{end+1} = '<tr>';

checkOptions = {'','checked'};

s{end+1} = sprintf('<td><input type="checkbox" name="helpSubfunsDisplayMode" %s onChange="this.form.submit()" />Show subfunctions</td>', ...
    checkOptions{helpSubfunsDisplayMode+1});
s{end+1} = sprintf('<td><input type="checkbox" name="h1DisplayMode" %s onChange="this.form.submit()" />Description</td>', ...
    checkOptions{h1DisplayMode+1});
s{end+1} = sprintf('<td><input type="checkbox" name="exampleDisplayMode" %s onChange="this.form.submit()" />Examples</td>', ...
    checkOptions{exampleDisplayMode+1});
s{end+1} = '</tr><tr>';
s{end+1} = sprintf('<td><input type="checkbox" name="helpDisplayMode" %s onChange="this.form.submit()" />Show all help</td>', ...
    checkOptions{helpDisplayMode+1});
s{end+1} = sprintf('<td><input type="checkbox" name="seeAlsoDisplayMode" %s onChange="this.form.submit()" />See also</td>', ...
    checkOptions{seeAlsoDisplayMode+1});
s{end+1} = sprintf('<td><input type="checkbox" name="copyrightDisplayMode" %s onChange="this.form.submit()" />Copyright</td>', ...
    checkOptions{copyrightDisplayMode+1});

s{end+1} = '</tr>';
s{end+1} = '</table>';

s{end+1} = '</form>';

if strcmp(option,'dir') && noContentsFileFlag
    s{end+1} = '<br/>';
    s{end+1} = '<span style="background: #FFC0C0">This directory has no Contents.m file</span><p/>';
else
    s{end+1} = '<br/>';
    s{end+1} = sprintf('Help for directory <a href="matlab: helpwin(''%s'')">%s</a><p/>', ...
        dirname,dirname);
end

s{end+1} = '<strong>M-File List</strong><br/>';
s{end+1} = '<table cellspacing="0" cellpadding="2" border="0">';

for n = 1:length(strc)

    s{end+1} = '<tr>';

    % Display all the results
    if strcmp(strc(n).type,'subfunction')
        s{end+1} = sprintf('<td valign="top" class="td-dashtop"><a href="matlab: opentoline(''%s'',%d)"><span class="mono">%s</span></a></td>', ...
            strc(n).filename, ...
            strc(n).firstLine, ...
            [strrep(strc(n).filename,'.m','') filemarker strc(n).name]);
        s{end+1} = '<td class="td-dashtopleft">';
    else
        s{end+1} = sprintf('<td valign="top" class="td-linetop"><a href="matlab: edit %s"><span class="mono">%s</span></a></td>', ...
            strc(n).filename, ...
            strrep(strc(n).filename,'.m',''));
        s{end+1} = '<td class="td-linetopleft">';
    end

    if h1DisplayMode
        if isempty(strc(n).description)
            s{end+1} = '<span style="background: #FFC0C0">No description line</span><br/>';
        else
            s{end+1} = sprintf('<pre><span style="font-size: 11">%s</span></pre>',strc(n).description);
        end
    end

    if helpDisplayMode
        if isempty(strc(n).help)
            s{end+1} = '<span style="background: #FFC0C0">No help</span><br/>';
        else
            s{end+1} = '<pre><span style="font-size=11">';
            s{end+1} = sprintf('%s<br/>',regexprep(strc(n).help,'^ %',' '));
            s{end+1} = '</span></pre>';
        end
    end

    if ~strcmp(strc(n).type,'subfunction')
        % We don't check for copyright, examples, and see also in
        % subfunctions

        if exampleDisplayMode
            if isempty(strc(n).example)
                s{end+1} = '<span style="background: #FFC0C0">No example</span><br/>';
            else
                lineLabel = sprintf('%2d:',strc(n).exampleLine);
                lineLabel = strrep(lineLabel,' ','&nbsp;');
                s{end+1} = sprintf('<pre><span style="font-size: 11"><a href="matlab: opentoline(''%s'',%d)">%s</a> %s</span></pre>', ...
                    [dirname filesep strc(n).filename], ...
                    strc(n).exampleLine, ...
                    lineLabel, ...
                    strc(n).example);
            end
        end

        if seeAlsoDisplayMode
            if isempty(strc(n).seeAlso)
                s{end+1} = '<span style="background: #FFC0C0">No see-also line</span><br/>';
            else
                lineLabel = sprintf('%2d:',strc(n).seeAlsoLine);
                lineLabel = strrep(lineLabel,' ','&nbsp;');
                s{end+1} = sprintf('<pre><span style="font-size: 11"><a href="matlab: opentoline(''%s'',%d)">%s</a> %s</span></pre>', ...
                    [dirname filesep strc(n).filename], ...
                    strc(n).seeAlsoLine, ...
                    lineLabel, ...
                    strc(n).seeAlso);

                checkSeeAlsoFcn = 1;
                if checkSeeAlsoFcn
                    for m = 1:length(strc(n).seeAlsoFcnList)
                        if isempty(which(strc(n).seeAlsoFcnList{m}{1}))
                            s{end+1} = sprintf('<span style="background: #FFC0C0">Function %s does not appear on the path</span><br/>', ...
                                strc(n).seeAlsoFcnList{m}{1});
                        end
                    end
                end

            end
        end

        if copyrightDisplayMode
            if isempty(strc(n).copyright)
                s{end+1} = '<span style="background: #FFC0C0">No copyright line</span>';
            else
                lineLabel = sprintf('%2d:',strc(n).copyrightLine);
                lineLabel = strrep(lineLabel,' ','&nbsp;');
                s{end+1} = sprintf('<pre><span style="font-size: 11"><a href="matlab: opentoline(''%s'',%d)">%s</a> %s</span></pre>', ...
                    [dirname filesep strc(n).filename], ...
                    strc(n).copyrightLine, ...
                    lineLabel, ...
                    strc(n).copyright);
                dv = datevec(now);
                if strc(n).copyrightEndYear ~= dv(1)
                    s{end+1} = '<span style="background: #FFC0C0">Copyright year is not current</span><br/>';
                end
            end
        end

    end

    s{end+1} = '</td></tr>';

end

s{end+1} = '</table>';

s{end+1} = '</body></html>';

sOut = [s{:}];

if nargout==0
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = sOut;
end
