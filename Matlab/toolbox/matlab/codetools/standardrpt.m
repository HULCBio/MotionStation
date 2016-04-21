function htmlStr = standardrpt(dirname)
%STANDARDRPT  Visual directory browser
%   STANDARDRPT works in conjunction with the Current Directory Browser
%
%   This information is provided by default
%   * file description
%   * file thumbnail
%   * file type (i.e. script/function)
%
%   Checkbox options are provided for this information
%   * show file size
%   * show subfunctions
%   * show HTML commands
%   * sort by Contents.m

% Copyright 1984-2004 The MathWorks, Inc.
% Ned Gulley, June 2002

if nargin < 1,
    dirname = cd;
end

fs = filesep;

pixelPath = ['file:///' matlabroot fs 'toolbox' fs 'matlab' fs 'codetools' fs 'private' fs];
bluePixelGif = [pixelPath 'one-pixel.gif'];

% Get the preferences
fileSizeDisplayMode = getpref('dirtools','fileSizeDisplayMode',0);
listByContentsMode = getpref('dirtools','listByContentsMode',0);
showActionsMode = getpref('dirtools','showActionsMode',0);
thumbnailDisplayMode = getpref('dirtools','thumbnailDisplayMode',0);
typeDisplayMode = getpref('dirtools','typeDisplayMode',0);

% Gather the data
dr = dir([dirname fs '*.m']);
for n = 1:length(dr)
    dr(n).mfilename = regexprep(dr(n).name,'\.m$','');
end

% if sort by contents
if listByContentsMode
    ct = parsecontentsfile([dirname fs 'Contents.m']);

    if ~isempty(dr)
        allDirFiles = {dr.mfilename};
    else
        allDirFiles = {};
    end

    for n = 1:length(ct)
        ct(n).dirindex = 0;
        if strcmp(ct(n).type,'file')
            [ismemberFlag,ndx] = ismember(ct(n).mfilename,allDirFiles);
            if ismemberFlag
                % File appears in this directory. Remember its index
                ct(n).dirindex = ndx;
            else
                % File doesn't appear in this directory
                ct(n).ismfile = 0;
            end
        end
    end

    % Now add all the extra "missing" files
    if isempty(ct)
        unlisted = 1:length(dr);
    else
        ctList = {ct.mfilename};
        allContentsFiles = ctList(logical([ct.ismfile]));
        [null, unlisted] = setdiff(allDirFiles,allContentsFiles);
    end

    if ~isempty(unlisted)
        ct(end+1).ismfile = 0;
        ct(end).type = 'nonfile';
        ct(end).description = 'Unlisted files';
    end

    for n = 1:length(unlisted)
        % File is in the directory but not in Contents.m
        ct(end+1).mfilename = dr(unlisted(n)).mfilename;
        ct(end).ismfile = 1;
        ct(end).dirindex = unlisted(n);
    end

else
    ct = dr;
    for n = 1:length(dr)
        ct(n).ismfile = 1;
        ct(n).dirindex = n;
    end
end


% get file script/function designation
if typeDisplayMode
    for n = 1:length(ct)
        if ct(n).ismfile
            fid = fopen([ct(n).mfilename '.m'],'r');
            if fid > 0
                firstLine = fgets(fid);
                fclose(fid);
                if ischar(firstLine) && ~isempty(regexp(firstLine,'\s*function','once'))
                    ct(n).type = 'function';
                else
                    ct(n).type = 'script';
                end
            else
                ct(n).type = 'unknown';
            end
        end
    end
end


% get file descriptions
for n = 1:length(ct)
    if ct(n).ismfile
        ct(n).description = getdescription(ct(n).mfilename);
    end
end


% if showing pictures
if thumbnailDisplayMode
    files = dir([dirname fs 'html' fs '*.png']);
    allPngFiles = {files.name};
end

if fileSizeDisplayMode
    maxFileSize = max([dr.bytes]);
end


% Create the HTML file string
s = {};
s{1} = makeheadhtml;
s{end+1} = '<title>Visual Directory</title>';
s{end+1} = '</head>';
s{end+1} = '<body>';

s{end+1} = makesubdirhtml(dirname);


% Make the form
s{end+1} = '<form method="post" action="matlab:visdirrefresh">';
s{end+1} = '<input type="hidden" name="reporttype" value="standardrpt" />';
s{end+1} = '<input type="submit" value="Refresh" />';
s{end+1} = '</form>';

s{end+1} = '<form method="post" action="matlab:visdirformhandler">';
s{end+1} = '<input type="hidden" name="reporttype" value="standardrpt" />';
s{end+1} = '<table cellspacing="8">';
s{end+1} = '<tr>';

checkOptions = {'','checked'};

s{end+1} = sprintf('<td><input type="checkbox" name="listByContentsMode" %s onChange="this.form.submit()" />Sort by Contents.m</td>', ...
    checkOptions{listByContentsMode+1});

s{end+1} = sprintf('<td><input type="checkbox" name="showActionsMode" %s onChange="this.form.submit()" />Show actions</td>', ...
    checkOptions{showActionsMode+1});

s{end+1} = sprintf('<td><input type="checkbox" name="thumbnailDisplayMode" %s onChange="this.form.submit()" />Show thumbnails</td>', ...
    checkOptions{thumbnailDisplayMode+1});

s{end+1} = '</tr>';
s{end+1} = '<tr>';

s{end+1} = sprintf('<td><input type="checkbox" name="fileSizeDisplayMode" %s onChange="this.form.submit()" />Show file sizes</td>', ...
    checkOptions{fileSizeDisplayMode+1});

s{end+1} = sprintf('<td><input type="checkbox" name="typeDisplayMode" %s onChange="this.form.submit()" />Show function/script</td>', ...
    checkOptions{typeDisplayMode+1});

s{end+1} = '</tr>';
s{end+1} = '</table>';

s{end+1} = '</form>';


% Add some commands
contentsFullFilename = fullfile(dirname,'Contents.m');
s{end+1} = '[ ';
if ~isempty(dir(contentsFullFilename))
    s{end+1} = sprintf('<a href="matlab: edit %s">edit Contents.m</a> |',contentsFullFilename);
end
s{end+1} = ' <a href="matlab: contentsrpt">run contentsrpt</a> |';
s{end+1} = ' <a href="matlab: edit">new file</a>';
s{end+1} = ' ]<p/>';


s{end+1} = '<table cellpadding="2" cellspacing="0" border="0">';


for n = 1:length(ct)

    hasThumbnail = 0;
    
    if ~ct(n).ismfile
        if ~strcmp(ct(n).type,'file')
            s{end+1} = '<tr>';
            s{end+1} = sprintf('<td valign="top" colspan="%d" style="background:#EEE">', ...
                3+fileSizeDisplayMode);
            s{end+1} = sprintf('<span class="mono">%s</span><br/>', ...
                ct(n).description);
            s{end+1} = '</td>';
            s{end+1} = '</tr>';
        end
    else
        s{end+1} = '<tr>';
        s{end+1} = '<td valign="top" class="td-linetop">';
        ndx = ct(n).dirindex;
        
        showHtmlLink = 1;
        htmlLink = '';
        if showHtmlLink
            htmlFilename = [dirname fs 'html' fs dr(ndx).mfilename '.html'];
            htmlFile = dir(htmlFilename);
            if ~isempty(htmlFile)
                htmlLink = sprintf(' (<a href="matlab: web(''file:///%s'')">html</a>)', ...
                    fixquote(htmlFilename));
            end
        end

        s{end+1} = sprintf('<span class="mono"><a href="matlab: edit %s">%s</a> %s</span><br/>', ...
            dr(ndx).mfilename, dr(ndx).mfilename, htmlLink);

        if thumbnailDisplayMode
            if ismember([dr(ndx).mfilename '.png'], allPngFiles)
                hasThumbnail = 1;
                s{end+1} = sprintf('<img src="file:///%s%shtml%s%s"><br/>', ...
                    dirname,fs,fs,[dr(ndx).mfilename '.png']);
            end
        end       
        
        s{end+1} = '</td>';

        if typeDisplayMode
            s{end+1} = sprintf('<td valign="top" class="td-%s">', ct(n).type);
            s{end+1} = sprintf('<span style="font-size:7pt; color:#BBB">%s</span><br/>', ct(n).type);
            s{end+1} = '</td>';
        end

        if fileSizeDisplayMode
            s{end+1} = '<td valign="top" class="td-linetopleft">';
            s{end+1} = sprintf('<span style="font-size:7pt; color:#BBB">%3.1f Kb</span><br/>', ...
                dr(ndx).bytes/100);
            s{end+1} = sprintf('<img src="%s" width="%d" height="5" border="2"></span><br/>', ...
                bluePixelGif, round(50*dr(ndx).bytes/maxFileSize));
            s{end+1} = '</td>';
        end

        s{end+1} = '<td valign="top" class="td-linetopleft">';

        %         if strcmp(d(n).filetype,'function')
        %             s{end+1} = sprintf('<div style="filename">%s</div>', d(n).fcnline);
        %         end

        if isempty(ct(n).description)
            s{end+1} = '<span style="background: #FFC0C0"> No help </span><br/>';
        else
            % Remove the function name from the H-1 line if it exists
            desc = regexprep(ct(n).description,['$' upper(ct(n).mfilename) '\s*'],'');
            s{end+1} = sprintf('<span class="mono">%s</span>', desc);
        end

        if showActionsMode
            s{end+1} = '<br/><span style="font-size: 10">';
            s{end+1} = sprintf('[ <a href="matlab: %s">run</a> | ', ...
                dr(ndx).mfilename);

            if thumbnailDisplayMode
                s{end+1} = sprintf('<a href="matlab: snapshot(''%s'');  com.mathworks.mde.filebrowser.FileBrowser.refresh">make thumbnail</a> | ', ...
                    dr(ndx).mfilename);
            end


            % only show delete thumbnail if it exists
            if thumbnailDisplayMode && hasThumbnail
                imgFilename = [dirname fs 'html' fs dr(ndx).mfilename '.png'];
                s{end+1} = sprintf('<a href="matlab: deleteconfirm(''%s'',1)">delete thumbnail</a> | ', ...
                    imgFilename);
            end
            s{end+1} = sprintf('<a href="matlab: deleteconfirm(''%s.m'')">delete</a> ]', ...
                dr(ndx).mfilename);

            s{end+1} = '</span>';
        end

        s{end+1} = '</td>';

        s{end+1} = '</tr>';
    end
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

function htmlOut = makesubdirhtml(dirname,dirCountFlag)
%MAKESUBDIRHTML  Make the directory list at the top of the directory reports
%   htmlOut = makesubdirhtml(dirname)
%   htmlOut = makesubdirhtml(dirname,dirCountFlag)
%   Use dirCountFlag turns on the directory counter display, showing how
%   many m-files are in each subdirectory.

if nargin<2
    dirCountFlag = 1;
end

d = dir(dirname);
d(~logical([d.isdir])) = [];

% Remove . and .. directories from the list
if length(d) >= 2
    if strcmp(d(1).name,'.') && strcmp(d(2).name,'..')
        d([1 2]) =[];
    end
end

s = {};
s{end+1} = '<strong>Subfolders</strong> <br/>';

fs = filesep;
% upfolderIcon = ['file:///' matlabroot fs 'toolbox' fs 'matlab' fs 'icons' fs 'upfolder.gif'];

divStr = '|';
if length(d)==0
    s{end+1} = 'No subfolders<br/>';
    divStr = '';
end

s{end+1} = sprintf('<a href="matlab: cd(''..'')">&lt;UP&gt;</a> %s ',divStr);

% Use firstItemFlag to get the divider bars to work out right
firstItemFlag = 1;
for i = 1:length(d),
    if ~firstItemFlag
        s{end+1} = ' | ';
    else
        firstItemFlag = 0;
    end

    if dirCountFlag
        % Parenthetically include the number of m-files in each directory
        d2 = dir([d(i).name fs '*.m']);
        if isempty(d2)
            lenStr = '';
        else
            lenStr = sprintf('(%d)',length(d2));
        end
        s{end+1} = sprintf('<a href="matlab: cd(''%s'')">%s %s</a>', fixquote(d(i).name), d(i).name, lenStr);
    else
        s{end+1} = sprintf('<a href="matlab: cd(''%s'')">%s</a>', fixquote(d(i).name), d(i).name);
    end
end
s{end+1} = '<p/>';

htmlOut = [s{:}];
