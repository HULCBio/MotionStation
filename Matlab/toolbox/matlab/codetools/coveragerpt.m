function htmlOut = coveragerpt(dirname)
%COVERAGERPT  Scan a directory for profiler line coverage.

%   Copyright 1984-2004 The MathWorks, Inc.

if nargout == 0
    web('text://<html><body>Generating coverage report...</body></html>','-noaddressbox');
end

if nargin < 1
    dirname = cd;
end

fs = filesep;
if ~isempty(regexp(dirname,'private$','once'))
    matches = regexp(dirname,'.*\\(\w+\\private)','tokens','once');
    % This next line strips the front off the directory name, so we're left
    % with something like signal/private/
    privateDirname = [strrep(matches{1},'\','/') '/'];
else 
    privateDirname = '';
end

% Gather the data
profInfo = profile('info');

profiledFileList = {profInfo.FunctionTable.FileName};
profiledFcnList = {profInfo.FunctionTable.FunctionName};

d = dir([dirname fs '*.m']);
d(1).profInfoIndex = [];

fm = filemarker;

% Determine the overlap between the list of profiled files and the list of
% files in this directory. How many files in the current directory have
% been profiled?

for n = 1:length(profiledFileList)
    [pth name ext] = fileparts(profiledFileList{n});
    if strcmp(pth, dirname) && strcmp(ext,'.m');
        % The file in question lives in the current directory
        ndx = strmatch([name ext],{d.name});
        % profInfoIndex is the index into the profiler's FunctionTable
        d(ndx).profInfoIndex = [d(ndx).profInfoIndex n];
        % Remove the directory from the front of the profile function list.
        % This is necessary for proper operation inside private/
        % directories.
        if ~isempty(privateDirname)
            profiledFcnList{n} = strrep(profiledFcnList{n},privateDirname,'');
        end
    end
end

% Take a second pass through to find the coverage stats by subfunction
for n = 1:length(d)
    % Use a negative coverage so that sorting will work out automatically 
    % If a file has coverage, it will be set later in this loop
    d(n).coverage = -1*n;
    d(n).funlist = [];
    
    if ~isempty(d(n).profInfoIndex)
        % We're in a function that was called
        
        % Get the names of all the subfunctions from this file
        callStrc = getcallinfo([dirname fs d(n).name],'funlist');

        f = textread([dirname fs d(n).name],'%s','delimiter','\n','whitespace','');
        ftok = xmtok(f);
        linelist = (1:length(f))';
               
        startLineList = [callStrc.firstline];
        endLineList = [startLineList-1 length(f)];
        endLineList(1) = [];
                
        for m = 1:length(callStrc)
            % Loop through the callStrc and see if any of the
            % functions/subfunctions match the profiled functions.
            if strcmp(callStrc(m).type,'subfunction')
                profiledFcnName = [callStrc(1).name fm callStrc(m).name];
            else
                profiledFcnName = callStrc(m).name;
            end

            d(n).funlist(m).firstline = callStrc(m).firstline;
            d(n).funlist(m).name = profiledFcnName;
            % When the file is a private function, profiledFcnList
            % returns the complete path, not just the file name, and the
            % next line's strmatch fails.
            ndx = strmatch(profiledFcnName,profiledFcnList(d(n).profInfoIndex),'exact');

            startLine = startLineList(m);
            endLine = endLineList(m);

            canRunList = find(linelist(startLine:endLine)==ftok(startLine:endLine));
            d(n).funlist(m).runnablelines = length(canRunList);

            if isempty(ndx)
                % We're in an uncalled subfunction of a called function
                d(n).funlist(m).coverage = 0;
                d(n).funlist(m).totaltime = 0;
                d(n).funlist(m).profindex = [];
            else
                % We're in a called subfunction of a called function
                % Now work out the coverage statistics for the
                % function/subfunction

                didRunList = profInfo.FunctionTable(d(n).profInfoIndex(ndx)).ExecutedLines(:,1);

                d(n).funlist(m).coverage = 100*length(didRunList)/length(canRunList);
                d(n).funlist(m).totaltime = profInfo.FunctionTable(d(n).profInfoIndex(ndx)).TotalTime;
                d(n).funlist(m).profindex = d(n).profInfoIndex(ndx);
            end
        end
        
        d(n).coverage = sum([d(n).funlist.coverage].*[d(n).funlist.runnablelines])/sum([d(n).funlist.runnablelines]);
    end
end

fixedQuoteDirname = fixquote(dirname);

% Now generate the HTML
s = {};
s{1} = makeheadhtml;

s{end+1} = '<title>Coverage Report</title>';
s{end+1} = '</head>';
s{end+1} = '<body>';

s{end+1} = sprintf('<span class="head">Coverage Report for %s</span><p/>',dirname);

% Make the form
s{end+1} = '<form method="post" action="matlab:visdirrefresh">';
s{end+1} = '<input type="hidden" name="reporttype" value="coveragerpt" />';
s{end+1} = '<input type="submit" value="Refresh" />';
s{end+1} = '</form><p/>';

% pixel gif location

pixelPath = ['file:///' matlabroot fs 'toolbox' fs 'matlab' fs 'codetools' fs 'private' fs];
whitePixelGif = [pixelPath 'one-pixel-white.gif'];
bluePixelGif = [pixelPath 'one-pixel.gif'];

% Make sure there is something to show before you build the table
if isempty(d)
    s{end+1} = 'No M-files in this directory<p/>';
else
    [null,ndx] = sort([d.coverage]);
    d = d(fliplr(ndx));

    s{end+1} = '<table cellspacing="0" cellpadding="2" border="0">';
    % Loop over all the files in the structure
    for n = 1:length(d)
        if isempty(d(n).funlist)
            s{end+1} = sprintf('<tr><td valign="top" colspan="2" class="td-linetop"><a href="matlab: edit(''%s'')"><span class="mono">%s</span></a></td></tr>', ...
                [fixedQuoteDirname fs d(n).name],d(n).name);
        else
            % First put a header on for the whole file
            s{end+1} = '<tr><td valign="top" class="td-linetop">';

            s{end+1} = sprintf('<a href="matlab: edit(''%s'')"><span class="mono">%s</span></a></td>', ...
                [fixedQuoteDirname fs d(n).name], d(n).name);
            s{end+1} = '<td valign="top" class="td-linetopleft">';
            s{end+1} = sprintf('<span style="border:1px solid #000;"><img src="%s" width="%d" height="10" border="1">', ...
                bluePixelGif, round(d(n).coverage));
            s{end+1} = sprintf('<img src="%s" width="%d" height="10" border="10"></span><br/>', ...
                whitePixelGif, round(100-d(n).coverage));

            if length(d(n).funlist) == 1

                s{end+1} = sprintf('<a href="matlab: profview(%d)">Coverage</a>: %4.1f%%<br/>', ...
                    d(n).funlist(1).profindex, ...
                    d(n).funlist(1).coverage);
                s{end+1} = sprintf('Total time: %4.1f sec<br/>', d(n).funlist(1).totaltime);
                s{end+1} = sprintf('Line count: %d<br/>', d(n).funlist(1).runnablelines);
                s{end+1} = '</td>';
                s{end+1} = '</tr>';

            else

                s{end+1} = sprintf('Total coverage: %4.1f %%</td>', ...
                    d(n).coverage);
                s{end+1} = '</tr>';

                for m = 1:length(d(n).funlist)
                    s{end+1} = sprintf('<tr><td valign="top" class="td-dashtop">&nbsp;&nbsp;<a href="matlab: opentoline(''%s'',%d)"><span class="mono">%s</span></a></td>', ...
                        [dirname fs d(n).name], d(n).funlist(m).firstline, d(n).funlist(m).name);

                    if d(n).funlist(m).coverage == 0
                        s{end+1} = '<td valign="top" class="td-dashtopleft"></td>';
                    else
                        s{end+1} = '<td valign="top" class="td-dashtopleft">';
                        s{end+1} = sprintf('<a href="matlab: profview(%d)">Coverage</a>: %4.1f%%<br/>', ...
                            d(n).funlist(m).profindex, ...
                            d(n).funlist(m).coverage);
                        s{end+1} = sprintf('Total time: %4.1f sec<br/>', d(n).funlist(m).totaltime);
                        s{end+1} = sprintf('Line count: %d<br/>', d(n).funlist(m).runnablelines);
                        s{end+1} = '</td>';
                    end
                    s{end+1} = '</tr>';
                end
            end
            
        end
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
