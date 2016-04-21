function htmlOut = contentsrpt(dirname)
%CONTENTSRPT  Audit the Contents.m for the given directory
%   contentsrpt(dirname)

%   Copyright 1984-2003 The MathWorks, Inc.

if nargout == 0
    web('text://<html><body>Generating contents report...</body></html>','-noaddressbox');
end

if nargin < 1
    dirname = cd;
end

% Is there a Contents.m file?
noContentsFlag = 0;
if isempty(dir(fullfile(dirname,'Contents.m')))
    noContentsFlag = 1;
else
    [ct, ex] = auditcontents(dirname);
end


% Generate the HTML

s{1} = makeheadhtml;
s{end+1} = '<title>Contents Report</title>';
s{end+1} = '</head>';
s{end+1} = '<body>';


s{end+1} = '<strong>Contents Manager</strong><br/>';

s{end+1} = '<form method="post" action="matlab:visdirrefresh">';
s{end+1} = '<input type="submit" value="Refresh" />';
s{end+1} = '<input type="hidden" name="reporttype" value="contentsrpt" />';
s{end+1} = '</form>';

if noContentsFlag
    s{end+1} = 'No Contents.m file. Make one? [ <a href="matlab:makecontentsfile; contentsrpt">yes</a> ]';
else
    s{end+1} = '[ <a href="matlab: edit(''Contents.m'')">edit Contents.m</a> |';
    s{end+1} = ' <a href="matlab: fixcontents(''Contents.m'',''prettyprint''); contentsrpt">fix spacing</a> |';
    s{end+1} = ' <a href="matlab: fixcontents(''Contents.m'',''all''); contentsrpt">fix all</a> ]<p/>';

    s{end+1} = '<pre>';

    for n = 1:length(ct)
        fileline = regexprep(ct(n).text,'^%','');
        if ct(n).ismfile
            fileline2 = regexprep(fileline, ...
                ct(n).mfilename, ...
                sprintf('<a href="matlab:edit(''%s'')">%s</a>', ct(n).mfilename, ct(n).mfilename) , ...
                'once');

            s{end+1} = sprintf('%s\n',fileline2);

            if strcmp(ct(n).action,'update')
                s{end+1} = '</pre><div style="background:#FEE">';
                s{end+1} = sprintf('Description lines do not match for file <a href="matlab: edit(''%s'')">%s</a>.<br/>', ...
                    ct(n).mfilename, ct(n).mfilename);

                s{end+1} = 'Use this description from the <b>file</b>? (default) ';
                s{end+1} = sprintf('[ <a href="matlab:fixcontents(''Contents.m'',''update'',''%s''); contentsrpt">yes</a> ]', ...
                    ct(n).mfilename);
                filelineFile = fileline;
                ndx = strfind(filelineFile,' - ');
                filelineFile(ndx:end) = [];
                filelineFile = [filelineFile ' - ' ct(n).filedescription];
                s{end+1} = sprintf('<pre>%s</pre>\n',filelineFile);
                
                s{end+1} = 'Or put this description from the <b>Contents</b> into the file? ';
                s{end+1} = sprintf('[ <a href="matlab:fixcontents(''Contents.m'',''updatefromcontents'',''%s''); contentsrpt">yes</a> ]', ...
                    ct(n).mfilename);
                s{end+1} = sprintf('<pre>%s</pre>\n',fileline);
                s{end+1} = '</div><pre>';

            elseif strcmp(ct(n).action,'remove')
                s{end+1} = '</pre><div style="background:#FEE">';
                s{end+1} = sprintf('File %s does not appear in this directory.<br/>',  ...
                    ct(n).mfilename);
                s{end+1} = 'Remove it from Contents.m? ';
                s{end+1} = sprintf('[ <a href="matlab: fixcontents(''Contents.m'',''remove'',''%s''); contentsrpt">yes</a> ] ', ...
                    ct(n).mfilename);
                s{end+1} = '</div><pre>';
            end
        else
            s{end+1} = sprintf('%s\n',fileline);
        end
    end

    for n = 1:length(ex)
        s{end+1} = sprintf('</pre><div style="background:#EEE">File <a href="matlab: edit(''%s'')">%s</a> is in the directory but not Contents.m<pre>', ...
            ex(n).mfilename, ex(n).mfilename);
        s{end+1} = ex(n).contentsline;
        fileStr = regexprep(ex(n).contentsline,'-.*$','');
        
        s{end+1} = '</pre>Add the line shown above? ';
        
        s{end+1} = sprintf('[ <a href="matlab: fixcontents(''Contents.m'',''append'',''%s''); contentsrpt">yes</a> ]</div><pre>',fileStr);
    end

    s{end+1} = '</pre>';

end

s{end+1} = '</body></html>';

sOut = [s{:}];

if nargout==0
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = sOut;
end
