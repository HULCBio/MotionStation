function htmlOut = mlintrpt(name,option)
%MLINTRPT  Scan a file or directory for all M-Lint messages.
%   MLINTRPT scans all M-files in the current directory for M-Lint
%   messages.
%   MLINTRPT(FILENAME) scans the M-file FILENAME for messages as does the
%   command MLINTRPT(FILENAME,'file')
%   MLINTRPT(DIRNAME,'dir') scans the specified directory.
%
%   See also MLINT.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.14 $ $Date: 2004/04/10 23:24:15 $

if nargout == 0
    web('text://<html><body>Generating M-Lint report...</body></html>','-noaddressbox');
end

if nargin < 1
    option = 'dir';
    name = cd;
end

if nargin == 1
    option = 'file';
end

currDir = cd;
if currDir(1) == '\'
    % mlint.exe cannot be called on a UNC pathname
    web(['text://<body><span style="color:#F00">M-Lint Report cannot run when the current ' ...
        'directory is a UNC pathname.</span></body>'],'-noaddressbox');
    return
end

if strcmp(option,'dir')
    dirname = name;
    if isdir(dirname)
        dirFileList = dir([dirname filesep '*.m']);
        fileList = {dirFileList.name};
    else
        error('MATLAB:mlintrpt:InputNotDir','%s is not a directory.',dirname)
    end
    if ~isempty(fileList)
        localFilenames = strcat(dirname,filesep,fileList);
    else
        localFilenames = {};
    end
    mlintMsgs = mlint(localFilenames,'-fullpath','-struct');
else
    % Get the M-Lint data
    [mlintMsgs,localFilenames] = mlint({name},'-struct');
    fullname = localFilenames{1};
    if isempty(fullname)
        error('MATLAB:mlintrpt:FileNotFound','File %s not found.',name)
    end
    dirname = fileparts(fullname);
    fileList = {name};
end

% Gather all the data into HTML'able structure
strc = [];
for i = 1:length(mlintMsgs)

    strc(i).filename = fileList{i};
    strc(i).fullfilename = localFilenames{i};
        
    strc(i).linenumber = [];
    strc(i).linemessage = {};

    mlmsg = mlintMsgs{i};
    for j = 1:length(mlmsg)
        ln = mlmsg(j).message;
        ln = code2html(ln);
        for k = 1:length(mlmsg(j).line)
            strc(i).linenumber(end+1) = mlmsg(j).line(k);
            strc(i).linemessage{end+1} = ln;
        end
    end

    % Now sort the list by line number
    if ~isempty(strc(i).linenumber)
        lnum = [strc(i).linenumber];
        lmsg = strc(i).linemessage;
        [null,ndx] = sort(lnum);
        lnum = lnum(ndx);
        lmsg = lmsg(ndx);
        strc(i).linenumber = lnum;
        strc(i).linemessage = lmsg;
    end

end


% Now generate the HTML
s = {};
s{1} = makeheadhtml;
s{end+1} = '<title>M-Lint Code Check Report</title>';
s{end+1} = '</head>';    
s{end+1} = '<body>';    

s{end+1} = '<form method="post" action="matlab:visdirrefresh">';
s{end+1} = '<input type="submit" value="Refresh" />';
s{end+1} = '<input type="hidden" name="reporttype" value="mlintrpt" />';
if strcmp(option,'file')
    s{end+1} = sprintf('<input type="hidden" name="option" value="%s" />',option);
    s{end+1} = sprintf('<input type="hidden" name="name" value="%s" />',name);
end
s{end+1} = '</form><p/>';

s{end+1} = '<strong>M-Lint Code Checker Report</strong><p/>';
if strcmp(option,'file')
    s{end+1} = sprintf('<span class="mono">Report for file <a href="matlab: edit(''%s'')">%s</a></span><br/>', ...
        strc.fullfilename, regexprep(strc(1).filename,'\.m$',''));

    if ~isempty(strc(1).fullfilename)
        s{end+1} = sprintf('<span class="mono">%s</span><p/>',strc(1).fullfilename);
    else
        s{end+1} = sprintf('<span class="warning">File %s not found</span><p/>',strc(1).filename);
    end
end

s{end+1} = '<table cellspacing="0" cellpadding="2" border="0">';
for n = 1:length(strc)
    s{end+1} = '<tr><td valign="top" class="td-linetop">';
    if strcmp(option,'dir')
        s{end+1} = sprintf('<a href="matlab: edit(''%s'')"><span class="mono">%s</span></a><br/>', ...
            strc(n).filename, regexprep(strc(n).filename,'\.m$',''));
    end

    if isempty(strc(n).linenumber)
        msg = '<span class="soft">No messages</span>';
    elseif length(strc(n).linenumber)==1
        msg = '<span class="warning">1 message</span>';
    else
        msg = sprintf('<span class="warning">%d messages</span>', length(strc(n).linenumber));
    end
    s{end+1} = sprintf('%s</td><td valign="top" class="td-linetopleft">',msg);
        
    if ~isempty(strc(n).linenumber)
        for m = 1:length(strc(n).linenumber)
            s{end+1} = sprintf('<span class="mono"><a href="matlab: opentoline(''%s'',%d)">%d:</a> %s</span><br/>', ...
                strc(n).fullfilename, strc(n).linenumber(m), strc(n).linenumber(m), strc(n).linemessage{m});
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
