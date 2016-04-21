function cedit(s)
%CEDIT  Set command line editor keys.
%   CEDIT('off') turns off command line recall/edit.
%   CEDIT('on') turns command line recall/edit back on.
%   CEDIT('emacs') returns to the default Emacs key definitions.
%   Here is a table that shows which keystrokes are available
%   using the command line editor:
%
%   Previous line: ^p
%   Next line: ^n
%   One character left: ^b
%   One character right: ^f
%   Cursor word left: esc b, ^l
%   Cursor word right: esc f, ^r
%   Cursor to beginning of line: ^a
%   Cursor to end of line: ^e
%   Cancel line: ^u
%   In place delete: ^d
%   Insert toggle: ^t
%   Delete to end of line: ^k
%
%   Type CEDIT.M for more information.
%   The 'emacs' option is always in effect for MS-Windows, in
%   addition to the normal fixed key bindings.

%   S.N. Bangert 12-1-89 
%   Revised 1-12-90 JNL
%   Copyright 1984-2000 The MathWorks, Inc. 
%   $Revision: 5.8 $  $Date: 2000/07/28 18:10:54 $

% Note: This M-file uses undocumented features of MATLAB that
% are subject to change.

c = computer;
if strcmp(c(1:2),'PC') | strcmp(c(1:3),'MAC')
   return
end

% VMS line editting is always on and you can't change the editor style
if length(c) > 6
   if strcmp(c(1:7),'VAX_VMS')
      return;
   end
end

if strcmp(s,'off')
    system_dependent(2,0);
elseif strcmp(s,'on')
    system_dependent(2,1);
end

if strcmp(s,'emacs')
% Set up command line recall facility to respond to Emacs keystrokes
system_dependent(4,  1,  20)     % Insert toggle: ^t
system_dependent(4,  2,  1)      % Cursor to beginning of line: ^a
system_dependent(4,  3,  5)      % Cursor to end of line: ^e
system_dependent(4,  4, [27 98] ,12)% Cursor word left: esc b, ^l
system_dependent(4,  5, [27 102], 18)% Cursor word right: esc f, ^r
system_dependent(4,  6, 21)      % Cancel line: ^u
system_dependent(4,  7,  4)      % In place delete: ^d
system_dependent(4,  8,  0)      % Delete left: no additional
system_dependent(4,  9, 16)      % Previous line: ^p
system_dependent(4, 10, 14)      % Next line: ^n
system_dependent(4, 11,  2)      % One character left: ^b
system_dependent(4, 12,  6)      % One character right: ^f
end

if strcmp(s,'vms')
% Set up command line recall facility to respond to VMS keystrokes
system_dependent(4,  1,  1) % Insert toggle: ^a 
system_dependent(4,  2,  2) % Cursor to beginning of line: ^b
system_dependent(4,  3,  5) % Cursor to end of line: ^e
system_dependent(4,  4, 12) % Cursor word left: ^l
system_dependent(4,  5, 18) % Cursor word right: ^r
system_dependent(4,  6, 21) % Cancel line: ^u
system_dependent(4,  7,  0) % In place delete: no additional
system_dependent(4,  8,  0) % Delete left: no additional
system_dependent(4,  9,  0) % Previous line: no additional
system_dependent(4, 10,  0) % Next line: no additional
system_dependent(4, 11,  0) % One character left: no additional
system_dependent(4, 12,  0) % One character right: no additional
system_dependent(4, 13,  4) % EOF key: ^d

end

% Note: In addition to the above definitions, the following functions 
% are ALWAYS attached to standard keys via termcap:
%  One character left - Left Arrow
%  One character right - Right Arrow
%  Previous line - Up Arrow
%  Next line - Down Arrow
%
% The following functions are always attached to their 'stty' definitions:
%   Delete Left (i.e. backspace operation) - STTY 'ERASE' Key
%   If ERASE key is <BS> (stty ^H) then <DEL> does in-place delete.
%   If ERASE key is <DEL> (stty ^?) then <BS> does in-place delete.
