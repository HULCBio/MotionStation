function htmlStr = diffrpt(dirname,filename,filenum)
%DIFFRPT  Visual directory browser
%   DIFFRPT works in conjunction with the Current Directory Browser

% Copyright 1984-2003 The MathWorks, Inc.
% Ned Gulley

if nargout == 0
    web('text://<html><body>Generating file comparison report...</body></html>','-noaddressbox');
end


persistent firstclick lastclick
if ~exist(firstclick)
    firstclick = '';
end
if ~exist(lastclick)
    lastclick = '';
end

if nargin < 1
    dirname = cd;
end

if nargin == 3
    % If this is the second click on the same file, clear the selection
    if filenum == 1
        if strcmp(firstclick,filename)
            firstclick = '';
            lastclick = '';
            filenum = 0;
            filename = '';
        else
            firstclick = filename;
        end
    end

    if filenum == 2
        if strcmp(lastclick,filename)
            firstclick = '';
            lastclick = '';
            filenum = 0;
            filename = '';
        else
            lastclick = filename;
        end
    end

    if ~isempty(firstclick) && ~isempty(lastclick)
        if strcmp(firstclick,lastclick)
            firstclick = '';
            lastclick = '';
            filenum = 0;
            filename = '';
        else
            visdiff(firstclick,lastclick);
            firstclick = '';
            lastclick = '';
            return
        end
    end

else

    if ~isempty(firstclick)
        filenum = 1;
        filename = firstclick;
    elseif ~isempty(lastclick)
        filenum = 2;
        filename = lastclick;
    else
        filenum = 0;
        filename = '';
    end

end

if isdir(dirname)
    d = dir([dirname filesep '*.m']);
    for n = 1:length(d)
        d(n).mfilename = regexprep(d(n).name,'\.m$','');
        d(n).description =  getdescription(d(n).mfilename);
    end
else
    error('%s is not a directory',dirname)
end

% Generate the HTML
s = {};
s{1} = makeheadhtml;
s{end+1} = '<title>File Comparison Report</title>';
s{end+1} = '</head>';
s{end+1} = '<body>';

s{end+1} = '<form method="post" action="matlab:visdirrefresh">';
s{end+1} = '<input type="submit" value="Refresh" />';
s{end+1} = '<input type="hidden" name="reporttype" value="diffrpt" />';
s{end+1} = '</form><br/>';

s{end+1} = '<b>File Comparison Report</b> <br/>';

if filenum == 0
    fileMsg = 'To compare two files, click &lt;file 1&gt; for the first file and &lt;file 2&gt; for the second file.<p/>';
elseif filenum == 1
    fileMsg = sprintf('To compare another file with %s, click &lt;file 2&gt; next to that file<p/>', ...
        firstclick);
elseif filenum == 2
    fileMsg = sprintf('To compare another file with %s, click &lt;file 1&gt; next to that file<p/>', ...
        lastclick);
end

s{end+1} = fileMsg;

s{end+1} = '<table cellpadding="2" cellspacing="0" border="0">';

for n = 1:length(d)


    s{end+1} = '<tr>';

    s{end+1} = '<td valign="top" class="td-linetop">';
    fileMsg = '';
    if (filenum > 0) && strcmp(filename,[dirname filesep d(n).name])

        if filenum == 1
            fileMsg = '<span style="color:#F00">To compare this file with another, click &lt;file 2&gt; next to the other file</span>';
        elseif filenum == 2
            fileMsg = '<span style="color:#F00">To compare this file with another, click &lt;file 1&gt; next to the other file</span>';
        else
            fileMsg = '';
        end
    end


    s{end+1} = sprintf('<a href="matlab: edit %s"><span class="mono">%s</span></a><br/>', ...
        d(n).mfilename,d(n).mfilename);
    s{end+1} = '</td>';


    s{end+1} = '<td valign="top" class="td-linetopleft">';

    if isempty(d(n).description)
        s{end+1} = 'No help<br/>';
    else
        % Remove the function name from the H-1 line if it exists
        sf = strfind(d(n).description,upper(d(n).mfilename));
        if ~isempty(sf)
            if sf(1) == 1
                d(n).description(1:length(d(n).mfilename)) = [];
            end
        end
        s{end+1} = sprintf('<span class="mono">%s</span><br/>', d(n).description);
    end

    if ~isempty(fileMsg)
        s{end+1} = sprintf('%s<br/>',fileMsg);
    end

    s{end+1} = '<span style="font-size: 10">';
    s{end+1} = sprintf('[ <a href="matlab: diffrpt(''%s'',''%s'',1)">file 1</a> | ', ...
        dirname, [dirname filesep d(n).name]);
    s{end+1} = sprintf('<a href="matlab: diffrpt(''%s'',''%s'',2)">file 2</a> ', ...
        dirname, [dirname filesep d(n).name]);
    asvFilename = com.mathworks.mde.editor.EditorOptions.getAutoSaveFilename( ...
        dirname, d(n).name);
    if ~isempty(dir(char(asvFilename)))
        s{end+1} = sprintf('| <a href="matlab: diff2asv(''%s'')">diff to autosave</a> ', ...
            [dirname filesep d(n).mfilename]);
    end
    s{end+1} = ']';
    
    s{end+1} = '</span>';
    s{end+1} = '</td>';

    s{end+1} = '</tr>';
end

s{end+1} = '</table>';

s{end+1} = '</body>';
s{end+1} = '</html>';

sOut = [s{:}];

if nargout==0
    web(['text://' sOut],'-noaddressbox');
else
    htmlStr = sOut;
end
