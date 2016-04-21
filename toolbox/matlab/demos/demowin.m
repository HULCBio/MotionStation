function demowin(callback,product,label,body,base)
%DEMOWIN Display demo information in the Help window
% 
%   This file is a helper function used by the Help Browser's Demo tab.  It is
%   unsupported and may change at any time without notice.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.9 $ $Date: 2004/04/10 23:24:32 $

if (nargin < 5)
    base = '';
end

% Some initializations

CR = sprintf('\n');
BR = sprintf('<br/>\n');

% Determine the function name.

% Start by assuming the callback is a function name and trim it down.
fcnName = char(com.mathworks.mde.help.Demos.getDemoFuncNameFromCallback(callback));

% Find where this function lives.
itemLoc = which(fcnName);
if ~isempty(itemLoc)
   [a fcnName c d] = fileparts(itemLoc);
else
   fcnName = '';
end

%%%% Build the main body of the page.

if ~isempty(body)
   % We've already got one.  Just use it.
   % Assume it has its own H1.
   label = '';
else
   helpStr = help(fcnName);
   if isempty(fcnName) || isempty(helpStr)
      body = '<p></p>';
   else
      % Build the HTML from the help.
      body = [markupHelpStr(helpStr,fcnName,callback) CR];
   end
end

%%%% Determine the header navigation.

if isempty(callback)
   leftText = '';
   leftAction = '';
   rightText = '';
   rightAction = '';
elseif strncmp(callback,'playbackdemo',12)
   % Special case for Playback demos (temporary).
   leftText = 'Video Tutorial';
   leftAction = '';
   rightText = 'Run this demo';
   rightAction = callback;
   body = '<p>This is a video which will play in your system web browser.</p>';
elseif (exist(fcnName) == 4)
   leftText = [fcnName '.mdl'];
   leftAction = '';
   rightText = 'Open this model';
   rightAction = callback;
else
   leftText = ['View code for ' fcnName];
   leftAction = ['edit ' fcnName];
   rightText = 'Run this demo';
   rightAction = callback;
end
% Include link to HTML ref page, if there is one.
if isempty(itemLoc)
    centerHtml = '';
else
    productDocDir = getProductDocDir(itemLoc);
    refPage = [docroot filesep productDocDir filesep fcnName '.html'];
    if exist(refPage,'file')
        docText = 'Go to online doc';
        centerHtml = ['<a href="file:///' refPage '">' docText '</a>'];
    else
        centerHtml = '';
    end
end

%%%% Determine the header "h1" label.

if isempty(label)
   H1 = '';
else
   H1 = ['<p style="color:#990000; font-weight:bold; font-size:x-large">' ...
         label '</p>'];
end

%%%% Assemble the page.

title = sprintf('%s Demo: %s', product, fcnName);
htmlBegin = sprintf( ...
      '<html>\n<head><title>%s</title><base href="%s"></head>\n<body>\n', ...
      title,base);
header = makeHeader(leftText,leftAction,centerHtml,rightText,rightAction);
footer = ['<table border=0 cellspacing=0><tr><td>&nbsp;<a href="matlab:' ...
      rightAction '"><b>' rightText '</b></a></td></tr></table>'];
htmlEnd = sprintf('\n</body>\n</html>\n');

outStr = [htmlBegin header CR H1 CR body CR footer htmlEnd];

com.mathworks.mlservices.MLHelpServices.setHtmlText(outStr);

%disp(outStr);

%===============================================================================
function h = makeHeader(leftText,leftAction,centerHtml,rightText,rightAction)

% Left chunk.
leftData = ['<b>' leftText '</b>'];
if ~isempty(leftAction)
   leftData = ['<a href="matlab:' leftAction '">' leftData '</a>'];
end
leftData = ['<td>&nbsp;' leftData '</td>'];

% Center chunk.
centerData = ['<td valign="left">' centerHtml '</td>'];

% Right chunk.
rightData = ['<b>' rightText '</b>'];
if ~isempty(rightAction)
   rightData = ['<a href="matlab:' rightAction '">' rightData '</a>'];
end
rightData = ['<td align=right>' rightData '&nbsp;</td>'];

beginTable = '<table width="100%" border=0 cellspacing=0 bgcolor=ffe4b0><tr>';
endTable = '</tr></table>';

h = [beginTable leftData centerData rightData endTable];

%===============================================================================
function productDocDir = getProductDocDir(itemLoc)
% Determine location within help tree
productDocDir = ['techdoc' filesep 'ref'];
if findstr(itemLoc,'toolbox')
   if findstr(itemLoc,'matlab')
      productDocDir = ['techdoc' filesep 'ref'];
   elseif findstr(itemLoc,'control')
      productDocDir = ['toolbox' filesep 'control' filesep 'ref'];
   else
      productDocDir = itemLoc(findstr(itemLoc,'toolbox')+8:length(itemLoc));
      productDocDir = ['toolbox' filesep productDocDir(1:findstr(productDocDir,filesep)-1)];
   end
end

%===============================================================================
function helpStr = markupHelpStr(helpStr,fcnName,callback)

CR = sprintf('\n');
nameChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_/';
delimChars = [ '., ' CR ];

% Handle characters that are special to HTML 
helpStr = strrep(helpStr, '&', '&amp;');
helpStr = strrep(helpStr, '<', '&lt;');
helpStr = strrep(helpStr, '>', '&gt;');

% Make "see also" references act as hot links.
seeAlso = 'See also';
lengthSeeAlso = length(seeAlso);
xrefStart = findstr(helpStr, 'See also');
if length(xrefStart) > 0
   % Determine start and end of "see also" potion of the help output
   pieceStr = helpStr(xrefStart(1)+lengthSeeAlso : length(helpStr));
   periodPos = findstr(pieceStr, '.');
   overloadPos = findstr(pieceStr, 'Overloaded functions or methods');
   if length(periodPos) > 0
      xrefEnd = xrefStart(1)+lengthSeeAlso + periodPos(1);
      trailerStr = pieceStr(periodPos(1)+1:length(pieceStr));
   elseif length(overloadPos) > 0
      xrefEnd = xrefStart(1)+lengthSeeAlso + overloadPos(1);
      trailerStr = pieceStr(overloadPos(1):length(pieceStr));
   else
      xrefEnd = length(helpStr);
      trailerStr = '';
   end
   
   % Parse the "See Also" portion of help output to isolate function names.
   seealsoStr = '';
   word = '';
   for chx = xrefStart(1)+lengthSeeAlso : xrefEnd
      if length(findstr(nameChars, helpStr(chx))) == 1
         word = [ word helpStr(chx)];
      elseif (length(findstr(delimChars, helpStr(chx))) == 1) 
         if length(word) > 0
            % This word appears to be a function name.
            % Make link in corresponding "see also" string.
            fname = lower(word);
            seealsoStr = [seealsoStr '<a href="matlab:doc ' fname '">' fname '</a>'];
         end
         seealsoStr = [seealsoStr helpStr(chx)];
         word = '';
      else
         seealsoStr = [seealsoStr word helpStr(chx)];
         word = '';
      end
   end
   % Replace "See Also" section with modified string (with links)
   helpStr = [helpStr(1:xrefStart(1)+lengthSeeAlso -1) seealsoStr trailerStr];
end

% If there is a list of overloaded methods, make these act as links.
overloadPos =  findstr(helpStr, 'Overloaded functions or methods');
if length(overloadPos) > 0
   pieceStr = helpStr(overloadPos(1) : length(helpStr));
   % Parse the "Overload methods" section to isolate strings of the form "help DIRNAME/METHOD"
   overloadStr = '';
   linebrkPos = find(pieceStr == CR);
   lineStrt = 1;
   for lx = 1 : length(linebrkPos)
      lineEnd = linebrkPos(lx);
      curLine = pieceStr(lineStrt : lineEnd);
      methodStartPos = findstr(curLine, ' help ');
      methodEndPos = findstr(curLine, '.m');
      if (length(methodStartPos) > 0 ) & (length(methodEndPos) > 0 )
         linkTag = ['<a href="matlab:doc ' curLine(methodStartPos(1)+6:methodEndPos(1)+1) '">'];
         overloadStr = [overloadStr curLine(1:methodStartPos(1)) linkTag curLine(methodStartPos(1)+1:methodEndPos(1)+1) '</a>' curLine(methodEndPos(1)+2:length(curLine))];
      else
         overloadStr = [overloadStr curLine];
      end
      lineStrt = lineEnd + 1;
   end
   % Replace "Overloaded methods" section with modified string (with links)
   helpStr = [helpStr(1:overloadPos(1)-1) overloadStr];
end

% Highlight occurrences of the function name
helpStr = strrep(helpStr,[' ' upper(fcnName) '('],[' <b>' lower(fcnName) '</b>(']);
helpStr = strrep(helpStr,[' ' upper(fcnName) ' '],[' <b>' lower(fcnName) '</b> ']);

helpStr = ['<pre><code>' helpStr '</code></pre>'];

%===============================================================================

% Display the file itself? Maybe later...

% fullname = which(fcnName);
% code = char(com.mathworks.ide.util.IDEFileUtils.getCodeBlock(fullname));
% 
% % Handle characters that are special to HTML 
% code = strrep(code, '&', '&amp;');
% code = strrep(code, '<', '&lt;');
% code = strrep(code, '>', '&gt;');
% code = strrep(code, ' ', '&nbsp;');
% code = strrep(code, CR, ['<br>' CR]);
% 
% editlink = sprintf('<a href="matlab:edit %s"><b>%s</b></a>&nbsp;', qualified_topic, qualified_topic);
% 
% hdrStart = sprintf('<table width="100%%" border=0 cellspacing=0 bgcolor=ffe4b0><tr><td>');
% hdrStart = sprintf('%s<b>&nbsp;%s</b>', hdrStart, 'Demo Code');
% hdrEnd = sprintf(strcat('</td><td align=right>%s</td></table>'), editlink);
% 
% helpStr = [helpStr '<br><br><br>' hdrStart hdrEnd '<br><code>' code '</code>'];



