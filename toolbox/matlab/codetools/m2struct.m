function [out,copyright,revision] = m2struct(txt)
%M2STRUCT Break M-code into cells.
%   STRUCT = M2STRUCT(MCODE) breaks MCODE into cells and returns a structure
%   array STRUCT.

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2003/11/10 13:37:31 $

% Normalize line endings to Unix-style.
newLine = char(10);
pcNewLine = char([13 10]);
macNewLine = char(13);
txt = strrep(txt,pcNewLine,newLine);
txt = strrep(txt,macNewLine,newLine);

% State is one of the following: {'inTopComment','inCellDelimiter','inCode'}.
state = 'inCode';
cellNum = 1;
out(1).title = '';
out(1).text = {};
out(1).code = '';

copyright = '';
revision = '';

txt = [newLine txt newLine];
returns = find(txt==newLine);

% Special case Copyright and Revision lines.
% The parens on the next line around the "e" and the "a" are to keep our CVS
% from messing with this line of M-code.
revisionPattern = '^\%\s*\$R(e)vision: .*?$(\s+\$D(a)te: .*$)?\s*$';
copyrightPattern = '^\%\s*Copyright.*The MathWorks, Inc.\s*$';

for i = 1:(length(returns)-1)
   % Get the next line
   txtLine = txt((returns(i)+1):(returns(i+1)-1));
   txtLine = deblank(txtLine);

   % Classify the line based on its first token
   [firstToken,restOfLine] = strtok(txtLine);
   if ~isempty(firstToken)
      if isequal(firstToken,'%%')
         state = 'inCellDelimiter';
      elseif isequal(firstToken,'%')
         % No change to state for comment character
         secondToken = strtok(restOfLine);
%          if ~isempty(secondToken) && ((secondToken(1)=='@') && ...
%                isequal(state,'inTopComment'))
%             state = 'inAtTag';
%          end
      else
         state = 'inCode';
      end
   else
      % If it's an empty line, then we're in code
      state = 'inCode';
   end

    % Special case Copyright and Revision lines.
    if ~isempty(regexp(txtLine,copyrightPattern))
        copyright = txtLine;
        copyright(1) = [];
        copyright = copyright(min(find(copyright ~= ' ')):end);
        returnTo = state;
        state = 'skip';
    elseif ~isempty(regexp(txtLine,revisionPattern))
        revision = txtLine;
        revision(1) = [];
        revision = revision(min(find(revision ~= ' ')):end);
        returnTo = state;
        state = 'skip';
    end

   % Sort the line into the proper category
   switch state

   case 'inTopComment'
      % Remove the initial "%"
      txtLine(1) = [];
      % And the space after it, if there is one
      if ~isempty(txtLine) && (txtLine(1) == ' ')
         txtLine(1) = [];
      end
      txtLine = deblank(txtLine);
      out(cellNum).text{end+1}=txtLine;
      state = 'inTopComment';

%    case 'inAtTag'
%       tagName = secondToken(2:end);
%       tagLoc = findstr(txtLine,tagName);
%       tagText = txtLine((tagLoc+length(tagName)):end);
%       % Remove leading and trailing spaces
%       tagText = fliplr(deblank(fliplr(deblank(tagText))));
%       out(cellNum).special = [out(cellNum).special; {tagName,tagText}];
%       state = 'inTopComment';

   case 'inCode'
      if ~isempty(out(cellNum).code)
         out(cellNum).code = [out(cellNum).code newLine txtLine];
      elseif ~isempty(txtLine)
         out(cellNum).code = txtLine;
      end

   case 'inCellDelimiter'
      % Extract the step title (if any)
      cellTitle = txtLine(3:end);
      % Remove leading spaces
      cellTitle = deblank(fliplr(deblank(fliplr(cellTitle))));
      % Increment cell counter and initialize cell contents
      if (~isempty(out(cellNum).text) || ...
            ~isempty(out(cellNum).code) || ...
            ~isempty(out(cellNum).title))
         cellNum = cellNum + 1;
         out(cellNum).title = '';
         out(cellNum).text = {};
         out(cellNum).code = '';
      end
      out(cellNum).title = cellTitle;
      state = 'inTopComment';

   case 'skip'
      % Ignore this line.
      state = returnTo;
   end
end

% Strip trailing newlines from code.
for i = 1:length(out)
    code = out(i).code;
    % Do this isempty check to be sure we don't end up with [1x0 char].
    if ~isempty(code)
        out(i).code = code(1:max(find(code ~= 10)));
    end
end
