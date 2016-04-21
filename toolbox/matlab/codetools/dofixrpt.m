function htmlOut = dofixrpt(dirname)
%DOFIXRPT  Scan a file or directory for all TODO, FIXME, or NOTE messages.

% Copyright 1984-2003 The MathWorks, Inc.

if nargout == 0
    web('text://<html><body>Generating TODO/FIXME report...</body></html>','-noaddressbox');
end

if nargin < 1
    dirname = cd;
end

todoDisplayMode = getpref('dirtools','todoDisplayMode',1);
fixmeDisplayMode = getpref('dirtools','fixmeDisplayMode',1);
regexpDisplayMode = getpref('dirtools','regexpDisplayMode',1);
regexpText = getpref('dirtools','regexpText','NOTE');

if isdir(dirname)
    dirFileList = dir([dirname filesep '*.m']);
    fileList = {dirFileList.name};
else
    error('%s is not a directory',dirname)
end

% First gather all the data
strc = [];
for n = 1:length(fileList)
    filename = fileList{n};
    file = textread(filename,'%s','delimiter','\n','whitespace','');
    strc(n).filename = filename;
    strc(n).linenumber = [];
    strc(n).linecode = {};

    for m = 1:length(file),
        if ~isempty(file{m}),

            showLine = 0;
            if todoDisplayMode
                if ~isempty(strfind(file{m},'TODO'))
                    showLine = 1;
                end
            end

            if fixmeDisplayMode
                if ~isempty(strfind(file{m},'FIXME'))
                    showLine = 1;
                end
            end

            if regexpDisplayMode
                if ~isempty(strfind(file{m},regexpText))
                    showLine = 1;
                end
            end

            if showLine
                ln = file{m};
                ln = regexprep(ln,'^\s*%\s*','');
                strc(n).linenumber(end+1) = m;
                strc(n).linecode{end+1} = ln;
            end
        end
    end
    
end


% Now generate the HTML
s = {};
s{1} = makeheadhtml;
s{end+1} = '<title>TODO/FIXME Report</title>';
s{end+1} = '</head>';
s{end+1} = '<body>';

% Make the form
s{end+1} = '<form method="post" action="matlab:visdirrefresh">';
s{end+1} = '<input type="hidden" name="reporttype" value="dofixrpt" />';
s{end+1} = '<input type="submit" value="Refresh" />';
s{end+1} = '</form>';


s{end+1} = '<form method="post" action="matlab:visdirformhandler">';
s{end+1} = '<input type="hidden" name="reporttype" value="dofixrpt" />';
s{end+1} = '<table cellspacing="8">';
s{end+1} = '<tr>';

checkOptions = {'','checked'};

s{end+1} = sprintf('<td><input type="checkbox" name="todoDisplayMode" %s onChange="this.form.submit()" />TODO</td>', ...
    checkOptions{todoDisplayMode+1});

s{end+1} = sprintf('<td><input type="checkbox" name="fixmeDisplayMode" %s onChange="this.form.submit()" />FIXME</td>', ...
    checkOptions{fixmeDisplayMode+1});

s{end+1} = sprintf('<td><input type="checkbox" name="regexpDisplayMode" %s onChange="this.form.submit()" />', ...
    checkOptions{regexpDisplayMode+1});

s{end+1} = sprintf('<input type="text" name="regexpText" size="20" value="%s" onChange="this.form.submit()" /></td>', ...
    regexpText);

% onChange="this.form.submit()"

s{end+1} = '</tr>';
s{end+1} = '</table>';

s{end+1} = '</form>';

s{end+1} = '<strong>M-File List</strong><br/>';

% Make sure there is something to show before you build the table
if ~isempty(strc)
    s{end+1} = '<table cellspacing="0" cellpadding="2" border="0">';
    % Loop over all the files in the structure
    for n = 1:length(strc)
        s{end+1} = sprintf('<tr><td valign="top" class="td-linetop"><a href="matlab: edit %s"><span class="mono">%s</span></a></td>', ...
            strc(n).filename, strrep(strc(n).filename,'.m',''));
        s{end+1} = '<td class="td-linetopleft">';
        if length(strc(n).linenumber) > 0
            for m = 1:length(strc(n).linenumber)
                s{end+1} = sprintf('<span class="mono"><a href="matlab: opentoline(''%s'',%d)">%d</a> %s</span><br/>', ...
                    which(strc(n).filename), strc(n).linenumber(m), ...
                    strc(n).linenumber(m), code2html(strc(n).linecode{m}));
            end
        end
        s{end+1} = '</td></tr>';
    end
    s{end+1} = '</table>';
end

s{end+1} = '</body></html>';

sOut = [s{:}];

if nargout==0
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = sOut;
end
