function htmlOut = deprpt(name,option)
%DEPRPT  Scan a file or directory for dependencies.

% Copyright 1984-2003 The MathWorks, Inc.

if nargout == 0
    web('text://<html><body>Generating dependency report...</body></html>','-noaddressbox');
end

if nargin < 1
    option = 'dir';
    name = cd;
end

if nargin == 1
    option = 'file';
end

fs = filesep;

if strcmp(option,'dir')
    dirname = name;
    if isdir(dirname)
        dirFileList = dir([dirname fs '*.m']);
        fileList = {dirFileList.name};
    else
        web( ...
            sprintf('text://<html><body>Directory %s not found</body></html>',dirname), ...
            '-noaddressbox');
        return
    end
else
    fullname = which(name);
    if isempty(fullname)
        web( ...
            sprintf('text://<html><body>File %s not found</body></html>',name), ...
            '-noaddressbox');
        return
    end
    [dirname, name] = fileparts(fullname);
    dirFileList = dir(fullname);
    fileList = {dirFileList.name};
end

if dirname(1) == '\'
    % mlint.exe cannot be called on a UNC pathname
    web(['text://<body><span style="color:#F00">Dependency Report cannot run when the current ' ...
        'directory is a UNC pathname.</span></body>'],'-noaddressbox');
    return
end


% Manage the preferences
localParentDisplayMode = getpref('dirtools','localParentDisplayMode',1);
allChildDisplayMode = getpref('dirtools','allChildDisplayMode',1);
depSubfunDisplayMode = getpref('dirtools','depSubfunDisplayMode',1);
tbMatlabDisplayMode = 0;


% Collect all the data

if depSubfunDisplayMode
    % Need to treat subfunctions just like functions
    totalFileList = [];
    totalCallList = [];
    totalCallLinesList = [];
    typeList = [];
    fcnNameList = [];
    firstLineList = [];
    for n = 1:length(fileList)
        strc = getcallinfo(fullfile(dirname,fileList{n}),'subfuns');
        for m = 1:length(strc)
            if strcmp(strc(m).type,'subfunction')
                totalFileList{end+1} = fileList{n};
                fcnNameList{end+1} = strc(m).name;
                totalCallList{end+1} = strc(m).calls;
                totalCallLinesList{end+1} = strc(m).calllines;
                typeList{end+1} = 'subfunction';
                firstLineList(end+1) = strc(m).firstline;
            else
                totalFileList{end+1} = fileList{n};
                fcnNameList{end+1} = strc(m).name;
                totalCallList{end+1} = strc(m).calls;
                totalCallLinesList{end+1} = strc(m).calllines;
                typeList{end+1} = 'file';
                firstLineList(end+1) = 1;
            end
        end
    end
    fileList = totalFileList;
    callList = totalCallList;
    callLinesList = totalCallLinesList;
else
    typeList = [];
    for n = 1:length(fileList)
        strc = getcallinfo(fullfile(dirname,fileList{n}),'file');
        fcnNameList{n} = strc.name;
        callList{n} = strc.calls;
        callLinesList{n} = strc.calllines;
        typeList{end+1} = 'file';
    end
end

toolboxMatlab = [matlabroot fs 'toolbox' fs 'matlab' fs];
toolbox = [matlabroot fs 'toolbox' fs];
childStrc = [];

if ~isempty(fileList)

    % Create a hash for keeping track of function names
    % The hash will let me find the index for a file given its name
    fcnHash = java.util.Hashtable;
    callGrid = zeros(length(fcnNameList));
    fm = filemarker;
    for n = 1:length(fileList)
        fcnHash.put([dirname fs fileList{n} fm fcnNameList{n}],n);
    end


    % Go through all the children for each file and determine who is being
    % called. Also build up calling adjacency matrix callGrid for working out
    % parent functions later on
    for n = 1:length(fileList)
        allChildren = callList{n};
        allChildrenCallLines = callLinesList{n};

        allChildStrc = [];
        fullParentFilename = [dirname fs fileList{n}];

        for i = 1:length(allChildren)
            % NOTE: WHICH, when called with the IN functionality, must compile
            % the file in question. If there is a compile-time error, it will
            % fail in the try-block below, so we have to catch it and pass the
            % message back to the report.
            try
                fullChildFilename = which(allChildren{i},'in',fullParentFilename);
            catch
                fullChildFilename = 'ERROR';
                allChildStrc(1).type = 'ERROR';
                allChildStrc(1).name = lasterr;
                allChildStrc(1).callline = [];
                break

            end
            [childDir,childName] = fileparts(fullChildFilename);

            if ~isempty(fullChildFilename)
                % What if file is a variable?
                if strcmp(fullChildFilename,'variable')
                    fullChildFilename = '';
                end
            end

            if isempty(fullChildFilename)
                allChildStrc(end+1).type = 'unknown';
                allChildStrc(end).name = allChildren{i};
                allChildStrc(end).callline = allChildrenCallLines(i);

            elseif strcmp(fullChildFilename,'built-in')
                % Uncomment the following lines if you want to see built-ins
                % if builtinDisplayMode
                %     allChildStrc(end+1).type = 'built-in';
                %     allChildStrc(end).name = allChildren{n};
                % end

            else
                if strfind(fullChildFilename,toolboxMatlab)
                    % Uncomment the following lines if you want to see toolbox/matlab
                    if tbMatlabDisplayMode
                        allChildStrc(end+1).type = 'toolbox/matlab';
                        allChildStrc(end).name = strrep(fullChildFilename,toolboxMatlab,'');
                        allChildStrc(end).callline = allChildrenCallLines(i);
                    end

                elseif strcmp(fullChildFilename,fullParentFilename)
                    if strcmp(allChildren{i}, childName)
                        allChildStrc(end+1).type = 'recursion';
                        allChildStrc(end).name = allChildren{i};
                        allChildStrc(end).callline = allChildrenCallLines(i);
                    else
                        allChildStrc(end+1).type = 'subfunction';
                        allChildStrc(end).name = allChildren{i};
                        allChildStrc(end).callline = allChildrenCallLines(i);
                    end
                    % Update the adjacency matrix
                    callGrid(n,fcnHash.get([fullChildFilename '>' allChildren{i}])) = 1;

                elseif strcmp(childDir,[dirname fs 'private'])
                    allChildStrc(end+1).type = 'private';
                    allChildStrc(end).name = allChildren{i};
                    allChildStrc(end).callline = allChildrenCallLines(i);

                elseif strcmp(childDir,dirname)
                    allChildStrc(end+1).type = 'current dir';
                    allChildStrc(end).name = allChildren{i};
                    allChildStrc(end).callline = allChildrenCallLines(i);
                    % Update the adjacency matrix
                    callGrid(n,fcnHash.get([fullChildFilename '>' allChildren{i}])) = 1;

                elseif strfind(fullChildFilename,toolbox)
                    allChildStrc(end+1).type = 'toolbox';
                    allChildStrc(end).name = strrep(fullChildFilename,toolbox,'');
                    allChildStrc(end).callline = allChildrenCallLines(i);

                elseif strfind(childName,' is a Java method')
                    allChildStrc(end+1).type = 'java method';
                    allChildStrc(end).name = allChildren{i};
                    allChildStrc(end).callline = allChildrenCallLines(i);

                else
                    allChildStrc(end+1).type = 'other';
                    allChildStrc(end).name = fullChildFilename;
                    allChildStrc(end).callline = allChildrenCallLines(i);
                end
            end
        end

        if ~isempty(allChildStrc)
            [null,ndx] = sort({allChildStrc.type});
            allChildStrc = allChildStrc(ndx);
        end

        childStrc{n} = allChildStrc;

    end
end

% Generate the HTML
s = {};
s{1} = makeheadhtml;

s{end+1} = '<title>Dependency Report</title>';
s{end+1} = '</head>';
s{end+1} = '<body>';

if strcmp(option,'dir')
    s{end+1} = sprintf('<span class="head">Dependency Report for Directory %s</span><p/>',dirname);
else
    s{end+1} = sprintf('<span class="head">Dependency Report for File %s</span><p/>',name);
    if localParentDisplayMode
        s{end+1} = '<span style="color: #F00">Calling functions cannot be displayed in dependency reports for a single file.</span><p/>';
        localParentDisplayMode = 0;
        setpref('dirtools','localParentDisplayMode',localParentDisplayMode);
    end
end



% Make the form
s{end+1} = '<form method="post" action="matlab:visdirrefresh">';
s{end+1} = '<input type="hidden" name="reporttype" value="deprpt" />';
if strcmp(option,'file')
    s{end+1} = sprintf('<input type="hidden" name="option" value="%s" />',option);
    s{end+1} = sprintf('<input type="hidden" name="name" value="%s" />',name);
end
s{end+1} = '<input type="submit" value="Refresh" /><br/>';
s{end+1} = '</form>';


s{end+1} = '<form method="post" action="matlab:visdirformhandler">';
s{end+1} = '<input type="hidden" name="reporttype" value="deprpt" />';
checkOptions = {'','checked'};
s{end+1} = sprintf('<input type="checkbox" name="allChildDisplayMode" %s onChange="this.form.submit()" />Show child functions', ...
    checkOptions{allChildDisplayMode+1});
s{end+1} = sprintf('<input type="checkbox" name="localParentDisplayMode" %s onChange="this.form.submit()" />Show parent functions (current dir. only)<br/>', ...
    checkOptions{localParentDisplayMode+1});
s{end+1} = sprintf('<input type="checkbox" name="depSubfunDisplayMode" %s onChange="this.form.submit()" />Show subfunctions', ...
    checkOptions{depSubfunDisplayMode+1});

s{end+1} = '</form>';

s{end+1} = '<p/>Built-in functions and files in toolbox/matlab are not shown<p/>';


s{end+1} = '<table cellspacing="0" cellpadding="2" border="0" width="100%">';

s{end+1} = '<tr><td valign="bottom"><strong>M-files</strong></td>';
if allChildDisplayMode
    s{end+1} = '<td valign="bottom"><strong>Children</strong><br/>(called functions)</td>';
end
if localParentDisplayMode
    s{end+1} = '<td valign="bottom"><strong>Parents</strong><br/>(calling functions, current dir. only)</td>';
end
s{end+1} = '</tr>';

for n = 1:length(fileList)

    filename = fileList{n};
    mfilename = strrep(fileList{n},'.m','');

    s{end+1} = '<tr>';

    % Display all the results
    if strcmp(typeList{n},'subfunction')
        % This is a subfunction
        s{end+1} = '<td valign="top" class="td-dashtop">';
        s{end+1} = sprintf('<a href="matlab: opentoline(''%s'',%d)"><span class="mono">%s%s%s</span></a></td>', ...
            filename, firstLineList(n), mfilename, fm, fcnNameList{n});
    else
        s{end+1} = '<td valign="top" class="td-linetop">';
        s{end+1} = sprintf('<a href="matlab: edit %s"><span class="mono">%s</span></a></td>', ...
            filename, mfilename);
    end

    if allChildDisplayMode
        if strcmp(typeList{n},'subfunction')
            s{end+1} = '<td valign="top" class="td-dashtopleft">';
        else
            s{end+1} = '<td valign="top" class="td-linetopleft">';
        end

        currChildStrc = childStrc{n};

        if isempty(allChildren)
            s{end+1} = ' ';
        else
            for i = 1:length(currChildStrc)
                if strcmp(currChildStrc(i).type,'unknown')
                    str = sprintf('%-12s', currChildStrc(i).type);
                    str = strrep(str,' ','&nbsp;');
                    s{end+1} = sprintf('<span class="mono"><span style="background: #FFC0C0">%s:</span> ', ...
                        str);
                    s{end+1} = sprintf('<a href="matlab: opentoline(''%s'',%d)">%s</a></span><br/>', ...
                        filename, ...
                        currChildStrc(i).callline, ...
                        currChildStrc(i).name);
                elseif strcmp(currChildStrc(i).type,'ERROR')
                    str = sprintf('%-12s', currChildStrc(i).type);
                    str = strrep(str,' ','&nbsp;');
                    s{end+1} = sprintf('<span class="mono"><span style="background: #FFC0C0">%s:</span> ', ...
                        str);
                    s{end+1} = sprintf('%s<br/><span style="color: #F00">%s</span></span>', ...
                        filename, ...
                        currChildStrc(i).name);
                else
                    str = sprintf('%-12s', currChildStrc(i).type);
                    str = strrep(str,' ','&nbsp;');
                    s{end+1} = sprintf('<span class="mono">%s: ', ...
                        str);
                    s{end+1} = sprintf('<a href="matlab: opentoline(''%s'',%d)">%s</a></span><br/>', ...
                        filename, ...
                        currChildStrc(i).callline, ...
                        currChildStrc(i).name);
                end
            end
        end
        s{end+1} = '</td>';
    end


    if localParentDisplayMode
        if strcmp(typeList{n},'subfunction')
            s{end+1} = '<td valign="top" class="td-dashtopleft">';
        else
            s{end+1} = '<td valign="top" class="td-linetopleft">';
        end

        parentIndexList = find(callGrid(:,fcnHash.get([dirname fs fileList{n} '>' fcnNameList{n}])));
        if isempty(parentIndexList)
            s{end+1} = ' ';
        end
        for i = 1:length(parentIndexList)
            s{end+1} = sprintf('<span class="mono">%s</span><br/>', ...
                fcnNameList{parentIndexList(i)});
        end
        s{end+1} = '</td>';
    end

    s{end+1} = '</tr>';

end

s{end+1} = '</table>';

s{end+1} = '</body></html>';

sOut = [s{:}];

if nargout==0
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = sOut;
end


