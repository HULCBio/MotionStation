function htmlOut = profview(functionName, profInfo)
%PROFVIEW   Display HTML profiler interface.
%   PROFVIEW(FUNCTIONNAME, HILITEOPTION, PROFILEINFO)
%   FUNCTIONNAME can be either a name or an index number into the profile.
%   PROFILEINFO is the profile stats structure as returned by
%   PROFILEINFO = PROFILE('INFO').
%   If the FUNCTIONNAME argument passed in is zero, then profview displays
%   the profile summary page.
%   HILITEOPTION refers to the color behind the code in the file listing.
%   HILITEOPTION = {'time','numcalls','coverage','noncoverage','none'}
%
%   The output for PROFVIEW is an HTML file in the Profiler window. The
%   file listing at the bottom of the function profile page shows four
%   columns to the left of each line of code.
%   * Column 1 (red) is total time spent on the line in seconds.
%   * Column 2 (blue) is number of calls to that line.
%   * Column 3 is the line number
%
%   See also PROFILE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $  $Date: 2004/04/10 23:25:07 $
%   Ned Gulley, Nov 2001


persistent profileInfo
% Three possibilities:
% 1) profile info wasn't passed and hasn't been created yet
% 2) profile info wasn't passed in but is persistent
% 3) profile info was passed in

import com.mathworks.mde.profiler.Profiler;

if (nargin < 2) || isempty(profInfo),
    if isempty(profileInfo),
        % 1) profile info wasn't passed and hasn't been created yet
        profile('viewer');
        return
    else
        % 2) profile info wasn't passed in but is persistent
        % No action. profileInfo was created in a previous call to this function
    end
else
    % 3) profile info was passed in
    profileInfo = profInfo;
    Profiler.stop;
end

if nargin < 1,
    % If there's no input argument, just provide the summary
    functionName = 0;
end

% Find the function in the supplied data structure
% functionName can be either a name or an index number
if ischar(functionName),
    functionNameList = {profileInfo.FunctionTable.FunctionName};
    idx = find(strcmp(functionNameList,functionName)==1);
else
    idx = functionName;
end

% Create all the HTML for the page
if idx==0
    s = makesummarypage(profileInfo);
else
    s = makefilepage(profileInfo,idx);
end

sOut = [s{:}];

if nargout==0
    Profiler.setHtmlText(sOut);
else
    htmlOut = sOut;
end


function s = makesummarypage(profileInfo)
% --------------------------------------------------
% Show the main summary page
% --------------------------------------------------

% pixel gif location
fs = filesep;
pixelPath = ['file:///' matlabroot fs 'toolbox' fs 'matlab' fs 'codetools' fs 'private' fs];
cyanPixelGif = [pixelPath 'one-pixel-cyan.gif'];
bluePixelGif = [pixelPath 'one-pixel.gif'];

% Read in preferences
sortMode = getpref('profiler','sortMode','totaltime');

allTimes = [profileInfo.FunctionTable.TotalTime];
maxTime = max(allTimes);

% Calculate self time list
allSelfTimes = zeros(size(allTimes));
for i = 1:length(profileInfo.FunctionTable)
    allSelfTimes(i) = profileInfo.FunctionTable(i).TotalTime - ...
        sum([profileInfo.FunctionTable(i).Children.TotalTime]);
end

totalTimeFontWeight = 'normal';
selfTimeFontWeight = 'normal';
alphaFontWeight = 'normal';
numCallsFontWeight = 'normal';

if strcmp(sortMode,'totaltime')
    totalTimeFontWeight = 'bold';
    [null,sortIndex] = sort(allTimes,'descend');
elseif strcmp(sortMode,'selftime')
    selfTimeFontWeight = 'bold';
    [null,sortIndex] = sort(allSelfTimes,'descend');
elseif strcmp(sortMode,'alpha')
    alphaFontWeight = 'bold';
    allFunctionNames = {profileInfo.FunctionTable.FunctionName};
    [null,sortIndex] = sort(allFunctionNames);
elseif strcmp(sortMode,'numcalls')
    numCallsFontWeight = 'bold';
    [null,sortIndex] = sort([profileInfo.FunctionTable.NumCalls],'descend');
end

s = {};
s{1} = makeheadhtml;
s{end+1} = '<title>Profile Summary</title>';
cssfile = which('styles.css');
s{end+1} = sprintf('<link rel="stylesheet" href="file:///%s" type="text/css" />',cssfile);
s{end+1} = '</head>';
s{end+1} = '<body>';

% Summary info

s{end+1} = '<span style="font-size: 14pt; padding: 6; background: #FFE4B0">Profile Summary</span><br/>';
s{end+1} = sprintf('<i>Generated %s</i><br/>',datestr(now));

if length(profileInfo.FunctionTable)==1
    s{end+1} = '<p/><span style="color:#F00">No profile information to display.</span><br/>';
    s{end+1} = 'Note that built-in functions do not appear in this report.<p/>';
end

s{end+1} = '<table border=0 cellspacing=0 cellpadding=6>';
s{end+1} = '<tr>';
s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
s{end+1} = '<a href="matlab: setpref(''profiler'',''sortMode'',''alpha'');profview(0)">';
s{end+1} = sprintf('<span style="font-weight:%s">Function name</span></a></td>',alphaFontWeight);
s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
s{end+1} = '<a href="matlab: setpref(''profiler'',''sortMode'',''numcalls'');profview(0)">';
s{end+1} = sprintf('<span style="font-weight:%s">Calls</span></a></td>',numCallsFontWeight);
s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
s{end+1} = '<a href="matlab: setpref(''profiler'',''sortMode'',''totaltime'');profview(0)">';
s{end+1} = sprintf('<span style="font-weight:%s">Total Time</span></a></td>',totalTimeFontWeight);
s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">';
s{end+1} = '<a href="matlab: setpref(''profiler'',''sortMode'',''selftime'');profview(0)">';
s{end+1} = sprintf('<span style="font-weight:%s">Self Time</span></a>*</td>',selfTimeFontWeight);
s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0" valign="top">Total Time Plot<br/>';
s{end+1} = '(dark band = self time)</td>';
s{end+1} = '</tr>';

for i = 1:length(profileInfo.FunctionTable),
    n = sortIndex(i);

    if strcmp(profileInfo.FunctionTable(n).FunctionName,'profile')
        % Drop out of the loop to avoid displaying the PROFILE function.
        continue
    end

    s{end+1} = '<tr>';

    % Truncate the name if it gets too long
    displayFunctionName = truncateDisplayName(profileInfo.FunctionTable(n).FunctionName,40);

    s{end+1} = sprintf('<td class="td-linebottomrt"><a href="matlab: profview(%d);">%s</a>', ...
        n, displayFunctionName);

    if isempty(regexp(profileInfo.FunctionTable(n).Type,'^M-','once'))
        s{end+1} = sprintf(' (%s)</td>', ...
            profileInfo.FunctionTable(n).Type);
    else
        s{end+1} = '</td>';        
    end

    s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', ...
        profileInfo.FunctionTable(n).NumCalls);


    % Don't display the time if it's zero
    if profileInfo.FunctionTable(n).TotalTime > 0,
        s{end+1} = sprintf('<td class="td-linebottomrt">%4.3f s</td>', ...
            profileInfo.FunctionTable(n).TotalTime);
    else
        s{end+1} = '<td class="td-linebottomrt">0 s</td>';
    end

    if profileInfo.FunctionTable(n).IsRecursive
        s{end+1} = '<td class="td-linebottomrt" colspan="2">function is recursive</td>';
    else

        if maxTime > 0,
            timeRatio = profileInfo.FunctionTable(n).TotalTime/maxTime;
            selfTime = profileInfo.FunctionTable(n).TotalTime - sum([profileInfo.FunctionTable(n).Children.TotalTime]);
            selfTimeRatio = selfTime/maxTime;
        else
            timeRatio = 0;
            selfTime = 0;
            selfTimeRatio = 0;
        end
        
        s{end+1} = sprintf('<td class="td-linebottomrt">%4.3f s</td>',selfTime);
        
        s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10><img src="%s" width=%d height=10></td>', ...
            bluePixelGif, round(100*selfTimeRatio), ...
            cyanPixelGif, round(100*(timeRatio-selfTimeRatio)));

    end

    s{end+1} = '</tr>';
end
s{end+1} = '</table>';
s{end+1} = '<p/><a name="selftimedef"></a><strong>Self time</strong> is the time spent in a function excluding the ';
s{end+1} = 'time spent in its child functions. Self time also includes ';
s{end+1} = 'overhead resulting from the process of profiling.';
s{end+1} = '</body>';

s{end+1} = '</html>';



% --------------------------------------------------
% Show the function details page
% --------------------------------------------------
function s = makefilepage(profileInfo,idx)

% pixel gif location
bluePixelGif = ['file:///' which('one-pixel.gif')];

ftItem = profileInfo.FunctionTable(idx);

% NOTE: Since the ftItem.TotalTime occasionally reports a time less than
% the sum of the time spent on the executed lines, we will pick the greater
% of these two for our total time. In fact, ftItem.TotalTime should always
% be the greater value.
totalTime = max(ftItem.TotalTime,sum(ftItem.ExecutedLines(:,3)));


% Build up function name target list from the children table
targetHash = [];
for n = 1:length(ftItem.Children)
    targetName = profileInfo.FunctionTable(ftItem.Children(n).Index).FunctionName;
    % Don't link to Opaque-functions with dots in the name
    if ~any(targetName=='.') && ~any(targetName=='@')
        % Build a hashtable for the target strings
        % Ensure that targetName is a legal MATLAB identifier.
        targetName = regexprep(targetName,'^([a-z_A-Z0-9]*[^a-z_A-Z0-9])+','');
        if length(targetName) > 0 && targetName(1) ~= '_'
            targetHash.(targetName) = ftItem.Children(n).Index;
        end
    end
end

% M-functions, M-scripts, and M-subfunctions are the only file types we can
% list
mFileFlag = 1;
pFileFlag = 0;
if isempty(regexp(ftItem.Type,'^M-','once')) || isempty(ftItem.FileName)
    mFileFlag = 0;
else
    % Make sure it's not a P-file
    if ~isempty(regexp(ftItem.FileName,'\.p$','once'))
        pFileFlag = 1;
        % Replace ".p" string with ".m" string.
        fullName = regexprep(ftItem.FileName,'\.p$','.m');
        % Make sure the M-file corresponding to the P-file exists
        if ~exist(fullName,'file')
            mFileFlag = 0;
        end
    else
        fullName = ftItem.FileName;
    end
end
    
uncPathFlag = 0;
if mFileFlag
    f = textread(fullName,'%s','delimiter','\n','whitespace','');
    currDir = cd;
    if currDir(1) == '\'
        uncPathFlag = 1;
    end
    quoteFixedFullName = fixquote(fullName);
end
        
s = {};
s{1} = makeheadhtml;
s{end+1} = sprintf('<title>Function details for %s</title>', ftItem.FunctionName);
cssfile = which('styles.css');
s{end+1} = sprintf('<link rel="stylesheet" href="file:///%s" type="text/css" />',cssfile);
s{end+1} = '</head>';
s{end+1} = '<body>';

% Summary info
% displayName = truncateDisplayName(ftItem.FunctionName,40);
displayName = ftItem.FunctionName;
s{end+1} = sprintf('<span style="font-size: 14pt; padding: 6; background: #FFE4B0">%s', ...
    displayName);

if ftItem.NumCalls==1,
    callStr = 'call';
else
    callStr = 'calls';
end
s{end+1} = sprintf(' (%d %s, %4.3f sec)</span><br/>', ...
    ftItem.NumCalls, callStr, ftItem.TotalTime);
s{end+1} = sprintf('<i>Generated %s</i><br/>',datestr(now));

if mFileFlag
    s{end+1} = sprintf('%s in file <a href="matlab: edit(''%s'')">%s</a><br/>', ...
        ftItem.Type, quoteFixedFullName, fullName);
elseif isequal(ftItem.Type,'M-subfunction')
    s{end+1} = 'anonymous function from prompt or eval''ed string<br/>';
else
    s{end+1} = sprintf('%s in file %s<br/>', ...
        ftItem.Type, ftItem.FileName);
end

s{end+1} = '[<a href="matlab: stripanchors">Copy to new window for comparing multiple runs</a>]';

if ftItem.IsRecursive
    s{end+1} = '<p><span class="warning">File is recursive. Timing may be inaccurate</span></p>';
end

if pFileFlag && ~mFileFlag
    s{end+1} = '<p><span class="warning">This is a P-file for which there is no corresponding M-file</span></p>';
end

if uncPathFlag
    s{end+1} = ['<p><span class="warning">The current directory is a UNC pathname. This limits ' ...
        'profiler functionality. Change directories to a non UNC pathname to restore full functionality.</span></p>'];
end

s{end+1} = '<div class="grayline"/>';


% --------------------------------------------------
% Manage all the checkboxes
% Read in preferences
parentDisplayMode = getpref('profiler','parentDisplayMode',1);
busylineDisplayMode = getpref('profiler','busylineDisplayMode',1);
childrenDisplayMode = getpref('profiler','childrenDisplayMode',1);
mlintDisplayMode = getpref('profiler','mlintDisplayMode',1);
coverageDisplayMode = getpref('profiler','coverageDisplayMode',1);
listingDisplayMode = getpref('profiler','listingDisplayMode',1);

s{end+1} = '<form method="post" action="matlab:profviewgateway">';
s{end+1} = '<input type="submit" value="Refresh" />';
s{end+1} = sprintf('<input type="hidden" name="profileIndex" value="%d" />',idx);

s{end+1} = '<table>';
s{end+1} = '<tr><td>';


checkOptions = {'','checked'};

s{end+1} = sprintf('<input type="checkbox" name="parentDisplayMode" %s />', ...
    checkOptions{parentDisplayMode+1});
s{end+1} = 'Show parent files</td><td>';

s{end+1} = sprintf('<input type="checkbox" name="busylineDisplayMode" %s />', ...
    checkOptions{busylineDisplayMode+1});
s{end+1} = 'Show busy lines</td><td>';

s{end+1} = sprintf('<input type="checkbox" name="childrenDisplayMode" %s />', ...
    checkOptions{childrenDisplayMode+1});
s{end+1} = 'Show child files</td></tr><tr><td>';

s{end+1} = sprintf('<input type="checkbox" name="mlintDisplayMode" %s />', ...
    checkOptions{mlintDisplayMode+1});
s{end+1} = 'Show M-Lint results</td><td>';

s{end+1} = sprintf('<input type="checkbox" name="coverageDisplayMode" %s />', ...
    checkOptions{coverageDisplayMode+1});
s{end+1} = 'Show file coverage</td><td>';

s{end+1} = sprintf('<input type="checkbox" name="listingDisplayMode" %s />', ...
    checkOptions{listingDisplayMode+1});
s{end+1} = 'Show file listing</td>';

s{end+1} = '</tr></table>';

s{end+1} = '</form>';

s{end+1} = '<div class="grayline"/>';
% --------------------------------------------------


% --------------------------------------------------
% Parent list
% --------------------------------------------------
if parentDisplayMode
    parents = ftItem.Parents;

    s{end+1} = '<strong>Parents</strong> (calling functions)<br/>';
    if isempty(parents)
        s{end+1} = ' No parent ';
    else
        s{end+1} = '<p/><table border=0 cellspacing=0 cellpadding=6>';
        s{end+1} = '<tr>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Filename</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">File Type</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Calls</td>';
        s{end+1} = '</tr>';

        for n = 1:length(parents),
            s{end+1} = '<tr>';

            displayName = truncateDisplayName(profileInfo.FunctionTable(parents(n).Index).FunctionName,40);
            s{end+1} = sprintf('<td class="td-linebottomrt"><a href="matlab: profview(%d);">%s</a></td>', ...
                parents(n).Index, displayName);

            s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', ...
                profileInfo.FunctionTable(parents(n).Index).Type);

            s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', ...
                parents(n).NumCalls);

            s{end+1} = '</tr>';
        end

        s{end+1} = '</table>';
    end
    s{end+1} = '<div class="grayline"/>';
end
% --------------------------------------------------
% End parent list section
% --------------------------------------------------


% --------------------------------------------------
% Busy line list section
% --------------------------------------------------
[sortedTimeList, sortedTimeIndex] = sort(ftItem.ExecutedLines(:,3));
sortedTimeList = flipud(sortedTimeList);
maxTimeLineList = flipud(ftItem.ExecutedLines(sortedTimeIndex,1));
maxTimeLineList = maxTimeLineList(1:min(5,length(maxTimeLineList)));
maxNumCalls = max(ftItem.ExecutedLines(:,2));
timeSortedNumCallsList = flipud(ftItem.ExecutedLines(sortedTimeIndex,2));

% Link directly to the busiest lines
% ----------------------------------------------
if busylineDisplayMode
    s{end+1} = '<strong>Lines where the most time was spent</strong><br/> ';

    if ~mFileFlag
        s{end+1} = 'No M-code to display';
    else
        if (ftItem.IsRecursive) && (totalTime~=0)
            s{end+1} = '<span class="warning">Function is recursive. Line timing may be inaccurate.</span><br/>';
        end

        if totalTime==0
            s{end+1} = 'No measurable time spent in this function';
        end

        s{end+1} = '<p/><table border=0 cellspacing=0 cellpadding=6>';

        s{end+1} = '<tr>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Line Number</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Code</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Calls</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Total Time</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">% Time</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Time Plot</td>';
        s{end+1} = '</tr>';

        for n = 1:length(maxTimeLineList),
            s{end+1} = '<tr>';
            if listingDisplayMode && ~uncPathFlag
                s{end+1} = sprintf('<td class="td-linebottomrt"><a href="#Line%d">%d</a></td>', ...
                    maxTimeLineList(n),maxTimeLineList(n));
            else
                s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', ...
                    maxTimeLineList(n));
            end

            codeLine = f{maxTimeLineList(n)};
            % Squeeze out the leading spaces
            codeLine(cumsum(1-isspace(codeLine))==0)=[];
            % Replace angle brackets
            codeLine = code2html(codeLine);

            maxLineLen = 30;
            if length(codeLine) > maxLineLen
                s{end+1} = sprintf('<td class="td-linebottomrt"><pre>%s...</pre></td>',codeLine(1:maxLineLen));
            else
                s{end+1} = sprintf('<td class="td-linebottomrt"><pre>%s</pre></td>',codeLine);
            end

            s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>',timeSortedNumCallsList(n));

            if sortedTimeList(n) > 0
                s{end+1} = sprintf('<td class="td-linebottomrt">%4.3f s</td>',sortedTimeList(n));
                s{end+1} = sprintf('<td class="td-linebottomrt" class="td-linebottomrt">%3.1f%%</td>',100*sortedTimeList(n)/totalTime);
            else
                s{end+1} = '<td class="td-linebottomrt">0 s</td>';
                s{end+1} = '<td class="td-linebottomrt">0%</td>';
            end

            if totalTime > 0
                timeRatio = sortedTimeList(n)/totalTime;
            else
                timeRatio= 0;
            end
            s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10></td>', ...
                bluePixelGif, round(100*timeRatio));

            s{end+1} = '</tr>';

        end

        allOtherLineTime = ftItem.TotalTime - sum(sortedTimeList(1:length(maxTimeLineList)));
        % Now add a row for everything else
        s{end+1} = '<tr>';
        s{end+1} = '<td class="td-linebottomrt">Other lines &amp; overhead</td>';
        s{end+1} = '<td class="td-linebottomrt">&nbsp;</td>';
        s{end+1} = '<td class="td-linebottomrt">&nbsp;</td>';
        if allOtherLineTime > 0,
            s{end+1} = sprintf('<td class="td-linebottomrt">%4.3f s</td>',allOtherLineTime);
            s{end+1} = sprintf('<td class="td-linebottomrt">%3.1f%%</td>',100*allOtherLineTime/totalTime);
        else
            s{end+1} = '<td class="td-linebottomrt">0 s</td>';
            s{end+1} = '<td class="td-linebottomrt">0%</td>';
        end

        if totalTime > 0,
            timeRatio = allOtherLineTime/totalTime;
        else
            timeRatio= 0;
        end
        s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10></td>', ...
            bluePixelGif, round(100*timeRatio));
        s{end+1} = '</tr>';

        % Totals line
        s{end+1} = '<tr>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Totals</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';
        s{end+1} = sprintf('<td class="td-linebottomrt" bgcolor="#F0F0F0">%4.3f s</td>',totalTime);
        if totalTime > 0,
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">100%</td>';
        else
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">0%</td>';
        end
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';

        s{end+1} = '</tr>';

        s{end+1} = '</table>';
    end
    s{end+1} = '<div class="grayline"/>';

end
% --------------------------------------------------
% End line list section
% --------------------------------------------------


% --------------------------------------------------
% Children list
% --------------------------------------------------
if childrenDisplayMode
    % Sort children by execution time

    children = ftItem.Children;
    s{end+1} = '<b>Children</b> (called functions)<br/>';
    
    if isempty(children)
        s{end+1} = 'No children';
    else
        % Recursive functions are not timed accurately
        if ftItem.IsRecursive
            s{end+1} = '<span class="warning">Function is recursive. Child timing may be inaccurate.</span><br/>';
        end

        % Children are sorted by total time
        childrenTimes = [ftItem.Children.TotalTime];
        [null, timeSortIndex] = sort(childrenTimes);


        totalChildrenTime = sum([children.TotalTime]);
        selfTime = ftItem.TotalTime - totalChildrenTime;
        
        s{end+1} = '<p/><table border=0 cellspacing=0 cellpadding=6>';
        s{end+1} = '<tr>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Filename</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">File Type</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Calls</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Total Time</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">% Time</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Time Plot</td>';
        s{end+1} = '</tr>';

        for i = length(children):-1:1,
            n = timeSortIndex(i);
            s{end+1} = '<tr>';

            % Truncate the name if it gets too long
            displayFunctionName = truncateDisplayName(profileInfo.FunctionTable(children(n).Index).FunctionName,40);

            s{end+1} = sprintf('<td class="td-linebottomrt"><a href="matlab: profview(%d);">%s</a></td>', ...
                children(n).Index, displayFunctionName);

            s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', ...
                profileInfo.FunctionTable(children(n).Index).Type);

            s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', ...
                children(n).NumCalls);

            if children(n).TotalTime > 0,
                s{end+1} = sprintf('<td class="td-linebottomrt">%4.3f s</td>', children(n).TotalTime);
                s{end+1} = sprintf('<td class="td-linebottomrt">%3.1f%%</td>', 100*children(n).TotalTime/totalTime);
            else
                s{end+1} = '<td class="td-linebottomrt">0 s</td>';
                s{end+1} = '<td class="td-linebottomrt">0%</td>';
            end
            if totalTime > 0,
                timeRatio = children(n).TotalTime/totalTime;
            else
                timeRatio= 0;
            end

            s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10></td>', ...
                bluePixelGif, round(100*timeRatio));
            s{end+1} = '</tr>';
        end

        % Now add a row with self-timing information
        s{end+1} = '<tr>';
        s{end+1} = '<td class="td-linebottomrt">Self time (built-ins, overhead, etc.)</td>';
        s{end+1} = '<td class="td-linebottomrt">&nbsp;</td>';
        s{end+1} = '<td class="td-linebottomrt">&nbsp;</td>';
        if selfTime > 0,
            s{end+1} = sprintf('<td class="td-linebottomrt">%4.3f s</td>',selfTime);
            s{end+1} = sprintf('<td class="td-linebottomrt">%3.1f%%</td>',100*selfTime/totalTime);
        else
            s{end+1} = '<td class="td-linebottomrt">0 s</td>';
            s{end+1} = '<td class="td-linebottomrt">0%</td>';
        end

        if totalTime > 0,
            timeRatio = selfTime/totalTime;
        else
            timeRatio= 0;
        end
        s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10></td>', ...
            bluePixelGif, round(100*timeRatio));
        s{end+1} = '</tr>';

        % Totals row
        s{end+1} = '<tr>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Totals</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';
        s{end+1} = sprintf('<td class="td-linebottomrt" bgcolor="#F0F0F0">%4.3f s</td>',ftItem.TotalTime);
        if totalTime > 0,
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">100%</td>';
        else
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">0%</td>';
        end
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';
        s{end+1} = '</tr>';

        s{end+1} = '</table>';
    end

    s{end+1} = '<div class="grayline"/>';
end
% --------------------------------------------------
% End children list section
% --------------------------------------------------

   
if mFileFlag && ~uncPathFlag
    % Calculate beginning and ending lines for the current function
    ftok = xmtok(f);
    
    % FunctionName takes one of several forms: 
    % 1. foo
    % 2. foo>bar
    % 3. foo1\private\foo2
    % 4. foo1/private/foo2>bar
    %
    % We need to strip off everything except for the very last \w+ string
    
    fname = regexp(ftItem.FunctionName,'(\w+)$','tokens','once');

    strc = getcallinfo(fullName,'funlist');
    fcnList = {strc.name};
    fcnIdx = find(strcmp(fcnList,fname)==1);

    if isempty(fcnIdx)
        % NESTED and ANONYMOUS FUNCTIONS
        % If we can't find the function name on the list of functions
        % and subfunctions, assume this is either a nested or an anonymous
        % function. Just display the entire file in this case. 
        startLine = 1;
        endLine = length(f);
    else
        startLineList = [strc.firstline];
        endLineList = [startLineList-1 length(f)];
        endLineList(1) = [];

        startLine = startLineList(fcnIdx);
        endLine = endLineList(fcnIdx);
    end
    
    moreSubfunctionsInFileFlag = 0;
    if endLine < length(f)
        moreSubfunctionsInFileFlag = 1;
    end

    % hiliteOption = [ time | numcalls | coverage | noncoverage | none ]
    hiliteOption = getpref('profiler','hiliteOption','time');

    if strcmp(hiliteOption,'mlint') || mlintDisplayMode
        mlintstrc = mlint(fullName,'-struct');
    end
end

% --------------------------------------------------
% M-Lint list section
% --------------------------------------------------
if mlintDisplayMode
    s{end+1} = '<strong>M-Lint results</strong><br/>';

    if ~mFileFlag
        s{end+1} = 'No M-code to display';
    elseif uncPathFlag
        s{end+1} = 'M-Lint option is not available when the current directory is a UNC pathname';
    else
        if isempty(mlintstrc)
            s{end+1} = 'No M-Lint messages.';
        else
            % Remove mlint messages outside the function region
            mlintLines = [mlintstrc.line];
            mlintstrc([find(mlintLines < startLine) find(mlintLines > endLine)]) = [];
            s{end+1} = '<table border=0 cellspacing=0 cellpadding=6>';
            s{end+1} = '<tr>';
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Line number</td>';
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Message</td>';
            s{end+1} = '</tr>';

            for n = 1:length(mlintstrc)
                if (mlintstrc(n).line <= endLine) && (mlintstrc(n).line >= startLine)
                    s{end+1} = '<tr>';
                    if listingDisplayMode
                        s{end+1} = sprintf('<td class="td-linebottomrt"><a href="#Line%d">%d</a></td>', mlintstrc(n).line, mlintstrc(n).line);
                    else
                        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', mlintstrc(n).line);
                    end
                    s{end+1} = sprintf('<td class="td-linebottomrt"><span class="mono">%s</span></td>', mlintstrc(n).message);
                    s{end+1} = '</tr>';
                end
            end
            s{end+1} = '</table>';
        end
    end
    s{end+1} = '<div class="grayline"/>';
end
% --------------------------------------------------
% End M-Lint list section
% --------------------------------------------------


% --------------------------------------------------
% Coverage section
% --------------------------------------------------
if coverageDisplayMode
    s{end+1} = '<strong>Coverage results</strong><br/>';

    if ~mFileFlag
        s{end+1} = 'No M-code to display';
    elseif uncPathFlag
        s{end+1} = 'Coverage option is not available when the current directory is a UNC pathname';
    else
        s{end+1} = sprintf('[ <a href="matlab: coveragerpt(fileparts(''%s''))">Show coverage for parent directory</a> ]<br/>', ...
            quoteFixedFullName);

        linelist = (1:length(f))';
        % Lines that can run are ones for which the xmtok value returned
        % matches the number of that line
        canRunList = find(linelist(startLine:endLine)==ftok(startLine:endLine)) + startLine - 1;
        didRunList = ftItem.ExecutedLines(:,1);
        notRunList = setdiff(canRunList,didRunList);
        neverRunList = find(ftok(startLine:endLine)==0);

        s{end+1} = '<table border=0 cellspacing=0 cellpadding=6>';
        s{end+1} = '<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">Total lines in file</td>';
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', endLine-startLine+1);
        s{end+1} = '<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">Non-code lines (comments, blank lines)</td>';
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(neverRunList));
        s{end+1} = '<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">Code lines (lines that can run)</td>';
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(canRunList));
        s{end+1} = '<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">Code lines that did run</td>';
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(didRunList));
        s{end+1} = '<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">Code lines that did not run</td>';
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(notRunList));
        s{end+1} = '<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">Coverage (did run/can run)</td>';
        s{end+1} = sprintf('<td class="td-linebottomrt">%4.2f %%</td></tr>', 100*length(didRunList)/length(canRunList));
        s{end+1} = '</table>';

    end
    s{end+1} = '<div class="grayline"/>';
end
% --------------------------------------------------
% End Coverage section
% --------------------------------------------------


% --------------------------------------------------
% File listing
% --------------------------------------------------
% Make a lookup table to speed index identification
% The executedLines table is as long as the file and stores the index
% value for every executed line.
if listingDisplayMode
    s{end+1} = '<b>File listing</b><br/>';

    if ~mFileFlag
        s{end+1} = 'No M-code to display';
    elseif uncPathFlag
        s{end+1} = 'File listing option is not available when the current directory is a UNC pathname';
    else

        executedLines = zeros(length(f),1);
        executedLines(ftItem.ExecutedLines(:,1)) = 1:size(ftItem.ExecutedLines,1);

        % Enumerate all alphanumeric values for later use in linking code
        alphanumericList = ['a':'z' 'A':'Z' '0':'9' '_'];
        alphanumericArray = zeros(1,128);
        alphanumericArray(alphanumericList) = 1;


        % Take a first pass through the lines to figure out the line color
        bgColorCode = ones(length(f),1);
        textColorCode = ones(length(f),1);
        textColorTable = {'#228B22','#000000','#A0A0A0'};
        
        switch hiliteOption
            case 'time'
                % Ten shades of red
                bgColorTable = {'#FFFFFF','#FFF0F0','#FFE2E2','#FFD4D4', ...
                    '#FFC6C6','#FFB8B8','#FFAAAA','#FF9C9C','#FF8E8E','#FF8080'};
                maxTime = max(ftItem.ExecutedLines(:,3));
                for n = startLine:endLine

                    if ftok(n) == 0
                        % Non-code line, comment or empty. Color is green
                        textColorCode(n) = 1;
                    elseif ftok(n) < n
                        % This is a continuation line. Make it the same color
                        % as the originating line
                        bgColorCode(n) = bgColorCode(ftok(n));
                        textColorCode(n) = textColorCode(ftok(n));
                    else
                        % This is a new executable line
                        lineIdx = executedLines(n);
                        if lineIdx > 0
                            textColorCode(n) = 2;
                            if ftItem.ExecutedLines(lineIdx,3) > 0
                                timePerLine = ftItem.ExecutedLines(lineIdx,3);
                                ratioTime = timePerLine/maxTime;
                                bgColorCode(n) = ceil(10*ratioTime);
                            else
                                % The amount of time spent on the line was negligible
                                bgColorCode(n) = 1;
                            end
                        else
                            % The line was not executed
                            textColorCode(n) = 3;
                            bgColorCode(n) = 1;
                        end
                    end
                end

            case 'numcalls'
                % Ten shades of blue
                bgColorTable = {'#FFFFFF','#F5F5FF','#ECECFF','#E2E2FF', ...
                    '#D9D9FF','#D0D0FF','#C6C6FF','#BDBDFF','#B4B4FF','#AAAAFF'};

                for n = startLine:endLine
                    if ftok(n) == 0
                        % Non-code line, comment or empty. Color is green
                        textColorCode(n) = 1;
                    elseif ftok(n) < n
                        % This is a continuation line. Make it the same color
                        % as the originating line
                        bgColorCode(n) = bgColorCode(ftok(n));
                        textColorCode(n) = textColorCode(ftok(n));
                    else
                        % This is a new executable line
                        lineIdx = executedLines(n);
                        if lineIdx > 0
                            textColorCode(n) = 2;
                            if ftItem.ExecutedLines(lineIdx,2)>0;
                                callsPerLine = ftItem.ExecutedLines(lineIdx,2);
                                ratioNumCalls = callsPerLine/maxNumCalls;
                                bgColorCode(n) = ceil(10*ratioNumCalls);
                            else
                                % This line was not called
                                bgColorCode(n) = 1;
                            end

                        else
                            % The line was not executed
                            textColorCode(n) = 3;
                            bgColorCode(n) = 1;
                        end
                    end
                end

            case 'coverage'
                bgColorTable = {'#FFFFFF','#E0E0FF'};
                for n = startLine:endLine
                    if ftok(n) == 0
                        % Non-code line, comment or empty. Color is green
                        textColorCode(n) = 1;
                    elseif ftok(n) < n
                        % This is a continuation line. Make it the same color
                        % as the originating line
                        bgColorCode(n) = bgColorCode(ftok(n));
                        textColorCode(n) = textColorCode(ftok(n));
                    else
                        % This is a new executable line
                        lineIdx = executedLines(n);
                        if lineIdx > 0
                            textColorCode(n) = 2;
                            bgColorCode(n) = 2;
                        else
                            % The line was not executed
                            textColorCode(n) = 3;
                            bgColorCode(n) = 1;
                        end
                    end
                end

            case 'noncoverage'
                bgColorTable = {'#FFFFFF','#E0E0E0'};
                for n = startLine:endLine
                    if ftok(n) == 0
                        % Non-code line, comment or empty. Color is green
                        textColorCode(n) = 1;
                    elseif ftok(n) < n
                        % This is a continuation line. Make it the same color
                        % as the originating line
                        bgColorCode(n) = bgColorCode(ftok(n));
                        textColorCode(n) = textColorCode(ftok(n));
                    else
                        % This is a new executable line
                        lineIdx = executedLines(n);
                        if lineIdx > 0
                            textColorCode(n) = 2;
                            bgColorCode(n) = 1;
                        else
                            % The line was not executed
                            textColorCode(n) = 2;
                            bgColorCode(n) = 2;
                        end
                    end
                end

            case 'mlint'
                bgColorTable = {'#FFFFFF','#FFE0A0'};
                for n = startLine:endLine
                    if ftok(n) == 0
                        % Non-code line, comment or empty. Color is green
                        textColorCode(n) = 1;
                    elseif ftok(n) < n
                        % This is a continuation line. Make it the same color
                        % as the originating line
                        bgColorCode(n) = bgColorCode(ftok(n));
                        textColorCode(n) = textColorCode(ftok(n));
                    else
                        % This is a new executable line
                        lineIdx = executedLines(n);
                        if any([mlintstrc.line]==n)
                            bgColorCode(n) = 2;
                            textColorCode(n) = 2;
                        else
                            bgColorCode(n) = 1;
                            if lineIdx > 0
                                textColorCode(n) = 2;
                            else
                                % The line was not executed
                                textColorCode(n) = 3;
                            end
                        end

                    end
                end

            case 'none'
                bgColorTable = {'#FFFFFF'};
                for n = startLine:endLine
                    if ftok(n) == 0
                        % Non-code line, comment or empty. Color is green
                        textColorCode(n) = 1;
                    elseif ftok(n) < n
                        % This is a continuation line. Make it the same color
                        % as the originating line
                        bgColorCode(n) = bgColorCode(ftok(n));
                        textColorCode(n) = textColorCode(ftok(n));
                    else
                        % This is a new executable line
                        lineIdx = executedLines(n);
                        if lineIdx > 0
                            textColorCode(n) = 2;
                        else
                            % The line was not executed
                            textColorCode(n) = 3;
                        end
                    end
                end

            otherwise
                error(['hiliteOption ' hiliteOption ' unknown'])
        end

        % ----------------------------------------------

        s{end+1} = '<form method="post" action="matlab:profviewgateway">';
        s{end+1} = 'Color highlight code according to ';
        s{end+1} = sprintf('<input type="hidden" name="profileIndex" value="%d" />',idx);
        s{end+1} = '<select name="hiliteOption" onChange="this.form.submit()">';
        optionsList = {};
        optionsList{end+1} = 'time';
        optionsList{end+1} = 'numcalls';
        optionsList{end+1} = 'coverage';
        optionsList{end+1} = 'noncoverage';
        optionsList{end+1} = 'mlint';
        optionsList{end+1} = 'none';
        for n = 1:length(optionsList)
            if strcmp(hiliteOption, optionsList{n})
                selectStr='selected';
            else
                selectStr = '';
            end
            s{end+1} = sprintf('<option %s>%s</option>', selectStr, optionsList{n});
        end
        s{end+1} = '</select>';
        s{end+1} = '</form>';


        % --------------------------------------------------
        s{end+1} = '<pre>';

        % Display column headers across the top
        s{end+1} = ' <span style="color: #FF0000; font-weight: bold; text-decoration: none">  time</span> ';
        s{end+1} = '<span style="color: #0000FF; font-weight: bold; text-decoration: none">  calls</span> ';
        s{end+1} = ' <span style="font-weight: bold; text-decoration: none">line</span><br/>';
       
        % Cycle through all the lines
        for n = startLine:endLine

            lineIdx = executedLines(n);
            if lineIdx>0,
                timePerLine = ftItem.ExecutedLines(lineIdx,3);
                callsPerLine = ftItem.ExecutedLines(lineIdx,2);
            else
                timePerLine = 0;
                callsPerLine = 0;
            end

            % Display the mlint message if necessary
            color = bgColorTable{bgColorCode(n)};
            textColor = textColorTable{textColorCode(n)};

            if mlintDisplayMode
                if any([mlintstrc.line]==n)
                    s{end+1} = sprintf('<a name="Line%d"></a>',n);
                end
            end

            if strcmp(hiliteOption,'mlint')
                % Use the color as the indicator that an mlint message
                % occurred on this line
                if ~strcmp(color,'#FFFFFF')
                    % Mark this line for in-document linking from the mlint
                    % list
                    mlintIdx = find([mlintstrc.line]==n);
                    for nMsg = 1:length(mlintIdx)
                        s{end+1} = '                    ';
                        s{end+1} = sprintf('<span style="color: #F00">%s</span><br/>', ...
                            mlintstrc(mlintIdx(nMsg)).message);
                    end
                end
            end

            % Modify text so that < and > don't cause problems
            codeLine = code2html(f{n});

            % Display the time
            if timePerLine > 0.01,
                s{end+1} = sprintf('<span style="color: #FF0000"> %5.2f </span>', ...
                    timePerLine);
            elseif timePerLine > 0
                s{end+1} = '<span style="color: #FF0000">&lt; 0.01 </span>';
            else
                s{end+1} = '       ';
            end

            % Display the number of calls
            if callsPerLine > 0,
                s{end+1} = sprintf('<span style="color: #0000FF">%7d </span>', ...
                    callsPerLine);
            else
                s{end+1} = '        ';
            end

            % Display the line number
            if callsPerLine > 0,
                s{end+1} = sprintf('<span style="color: #000000; font-weight: bold"><a href="matlab: opentoline(''%s'',%d)">%4d</a></span> ', ...
                    quoteFixedFullName, n, n);
            else
                s{end+1} = sprintf('<span style="color: #A0A0A0">%4d</span> ', n);
            end

            if ~isempty(find(n==maxTimeLineList)),
                % Mark the busy lines in the file with an anchor
                s{end+1} = sprintf('<a name="Line%d"></a>',n);
            end

            if timePerLine > 0
                % Need to add a space to the end to make sure the last
                % character is an identifier.
                codeLine = [codeLine ' '];
                % Use state machine to substitute in linking code
                codeLineOut = '';

                state = 'between';

                substr = [];
                for m = 1:length(codeLine),
                    ch = codeLine(m);
                    % Deal with the line with identifiers and Japanese comments .
                    % 128 characters are from 0 to 127 in ASCII
                    if abs(ch)>127
                        alphanumeric = 0;
                    else
                        alphanumeric = alphanumericArray(ch);
                    end

                    switch state
                        case 'identifier'
                            if alphanumeric,
                                substr = [substr ch];
                            else
                                state = 'between';
                                if isfield(targetHash,substr)
                                    substr = sprintf('<a href="matlab: profview(%d);">%s</a>', targetHash.(substr), substr);
                                end
                                codeLineOut = [codeLineOut substr ch];
                            end
                        case 'between'
                            if alphanumeric,
                                substr = ch;
                                state = 'identifier';
                            else
                                codeLineOut = [codeLineOut ch];
                            end
                        otherwise

                            error(['Unknown case ' state])

                    end
                end
                codeLine = codeLineOut;
            end

            % Display the line
            s{end+1} = sprintf('<span style="color: %s; background: %s">%s</span><br/>', ...
                textColor, color, codeLine);

        end

        s{end+1} = '</pre>';
        if moreSubfunctionsInFileFlag
            s{end+1} = '<p/><p/>Other subfunctions in this file are not included in this listing.';
        end
    end
end
% --------------------------------------------------
% End file list section
% --------------------------------------------------

s{end+1} = '</body>';
s{end+1} = '</html>';
 


% --------------------------------------------------
function shortFileName = truncateDisplayName(longFileName,maxNameLen)
%TRUNCATEDISPLAYNAME  Truncate the name if it gets too long

shortFileName = longFileName;
if length(longFileName) > maxNameLen,
    shortFileName = char(com.mathworks.util.FileUtils.truncatePathname( ...
        longFileName, maxNameLen));
end
