function isscript = isScript(code)
%ISSCRIPT   True for code that defines a script, not a function.
%   ISSCRIPT(CODE) returns true for a script, where CODE must be a char
%   array.
%
%   Examples:
%
%      isscript(file2char('intro.m'))
%
%      f = fopen('intro.m');
%      c = fread(f,'char=>char')';
%      fclose(f);
%      isscript(c)

% Matthew J. Simoneau, January 2004
% $Revision: 1.1.6.1 $  $Date: 2004/03/02 21:46:29 $
% Copyright 1984-2004 The MathWorks, Inc.

% This function skips past any whitespace, comment lines, and block comments
% (even if they're nested).  To be a function, the first non-comment and
% non-whitespace is "function ", i.e. "function(space)" with some other
% non-whitespace on the line.

% Initialize constants.
tab = char(9);
char10 = char(10);
char13 = char(13);
space = ' ';

% The state machine uses newlines to terminate lines.  Make sure we have one
% at the end.
code(end+1) = char10;

% Initialize loop variables.
state = 'scanning';
isscript = true;
depth = 0;

% Loop over each character.
for i = 1:length(code)
   nextChar = code(i);
   switch state
   case 'scanning'
      % Haven't yet hit the first non-space character on the line.
      switch nextChar
      case {char10,char13,space,tab}
         % Drops empty lines and whitespace at the beginning.
         state = 'scanning';
      otherwise
         % Start paying attention.
         lineStart = i;
         lineEnd = i;
         state = 'mid-line';
      end
   case 'mid-line'
      switch nextChar
      case {char10,char13}
         % Pop a non-empty line, stripped of leading and trailing
         % whitespace.
         line = code(lineStart:lineEnd);
         if strcmp(line,'%{')
            % Begin a block comment.
            depth = depth + 1;
         elseif strcmp(line,'%}') && (depth > 0)
            % End a block comment, if there is one to end.
            depth = depth - 1;
         elseif strncmp('%',line,1)
            % A comment line.  Ignore.
         elseif (depth > 0)
            % We're in a block comment.  Ignore.
         elseif strncmp('function ',line,9)
            % It's a function.
            isscript = false;
            break
         elseif strncmp('function[',line,9)
            % Starts with "function[a,b]=foo".  It's a function.
            isscript = false;
            break
         elseif strncmp('function...',line,11)
            % Starts with "function...".  It's a function.
            isscript = false;
            break
         else
            % Starts with something else.  It's a script.
            break
         end
         % Start a new line.
         state = 'scanning';
      case {space,tab}
         % Ignore these at the end of the line.
      otherwise
         % Non-whitespace.  Move the end-of-line marker by one.
         lineEnd = i;
      end
   end
end
