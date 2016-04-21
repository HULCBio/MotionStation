function htmlOut = visdiff(fname1, fname2, showchars)
%VISDIFF Compare similarity of two entries
%   VISDIFF(fname1,fname2) brings up an HTML version of the difference
%   between the two files.
%   VISDIFF(fname1,fname2,showchars) makes the HTML display width for each
%   file showchars characters wide.

% Copyright 1984-2003 The MathWorks, Inc.

if nargin < 3
    showchars = 40;
end

% Respect a fully qualified path if one is being given
[pt1,nm1,xt1] = fileparts(fname1);
if isempty(pt1)
    fname1 = which(fname1);
    [pt1,nm1,xt1] = fileparts(fname1);
end
d1 = dir(fname1);

[pt2,nm2,xt2] = fileparts(fname2);
if isempty(pt2)
    fname2 = which(fname2);
    [pt2,nm2,xt2] = fileparts(fname2);
end
d2 = dir(fname2);

f1 = textread(fname1,'%s','delimiter','\n','whitespace','');
f2 = textread(fname2,'%s','delimiter','\n','whitespace','');

[a1,a2,score] = diffcode(f1,f2);

% Construct a final version of the file for display
% Skipped lines are indicated by "-----"

blankLine = char(32*ones(1,showchars));
f1n = [{blankLine}; f1];
f2n = [{blankLine}; f2];
a1Final = cell(size(a1));
a1Final = f1n(a1+1);
a2Final = cell(size(a2));
a2Final = f2n(a2+1);

% Generate the HTML
s = {};
s{1} = makeheadhtml;
s{end+1} = '<title>File Difference</title>';
s{end+1} = '</head>';
s{end+1} = '<body>';

s{end+1} = '<table cellpadding="0" cellspacing="0" border="0">';
s{end+1} = '<tr>';
s{end+1} = sprintf('<td></td><td><a href="matlab: edit(''%s'')"><strong>%s</strong></a></td>', ...
    fname1,[nm1 xt1]);
s{end+1} = sprintf('<td><a href="matlab: edit(''%s'')"><strong>%s</strong></a></td><td></td>', ...
    fname2,[nm2 xt2]);
s{end+1} = '</tr>';
s{end+1} = '<tr>';
s{end+1} = sprintf('<td></td><td>%s</td>',pt1);
s{end+1} = sprintf('<td>%s</td><td></td>',pt2);
s{end+1} = '</tr>';
s{end+1} = '<tr>';
s{end+1} = sprintf('<td></td><td>%s</td>',d1.date);
s{end+1} = sprintf('<td>%s</td><td></td>',d2.date);
s{end+1} = '</tr>';
s{end+1} = '<tr>';
s{end+1} = '<td><pre>    </pre></td>';
s{end+1} = sprintf('<td><pre>%s   </pre></td>',blankLine);
s{end+1} = sprintf('<td><pre>%s</pre></td>',blankLine);
s{end+1} = '</tr></table>';

match = zeros(size(a1));

s{end+1} = '<pre>';

for n = 1: length(a1Final)
    line1 = blankLine;
    line1Len = min(length(a1Final{n}),length(blankLine));
    line1(1:line1Len) = a1Final{n}(1:line1Len);
    line2 = blankLine;
    line2Len = min(length(a2Final{n}),length(blankLine));
    line2(1:line2Len) = a2Final{n}(1:line2Len);
    line1 = code2html(line1);
    line2 = code2html(line2);

    % Increment counters here
    if isequal(a1Final{n},a2Final{n})
        match(n) = 1;
        s{end+1} = sprintf('<span class="soft">%3d %s . %s %3d</span><br/>',a1(n),line1,line2,a2(n));
    elseif a1(n)==0
        s{end+1} = sprintf('  <span class="soft">-</span> <span class="diffold">%s</span><span class="diffnew"> <span style="color:#080">&gt;</span> %s</span> <a href="matlab: opentoline(''%s'',%d)">%3d</a><br/>', ...
            line1,line2,fname2,a2(n),a2(n));
    elseif a2(n)==0
        s{end+1} = sprintf('<a href="matlab: opentoline(''%s'',%d)">%3d</a> <span class="diffnew">%s <span style="color:#080">&lt;</span> </span><span class="diffold">%s</span>   <span class="soft">-</span><br/>', ...
            fname1,a1(n),a1(n),line1,line2);
    else
        s{end+1} = sprintf('<a href="matlab: opentoline(''%s'',%d)">%3d</a> <span class="diffnomatch">%s <span style="color:#F00">x</span> %s</span> <a href="matlab: opentoline(''%s'',%d)">%3d</a><br/>', ...
            fname1,a1(n),a1(n),line1,line2,fname2,a2(n),a2(n));
    end

end
s{end+1} = '</pre>';

numMatch = sum(match);

s{end+1} = sprintf('<p/>Number of matched lines: %d<br/>', numMatch);

s{end+1} = '</body>';    

s{end+1} = '</html>';

sOut = [s{:}];
if nargout == 0  
    web(['text://' sOut],'-noaddressbox');
else 
    htmlOut = sOut;
end
