function deehlp()
%DEEHLP Display help for DEE.
%   DEEHLP displays help for DEE.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.12 $

% inputs:  none
% outputs: none

% this function:
%      (i)   displays help for the Differential Equation Editor (DEE)

%                                    (i)                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% call helpwin on dee.hlp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For now:
if exist('helpwin') & exist('dee.hlp')
  fid = fopen('dee.hlp');
  F = fread(fid);
  s = setstr(F');
  helpwin(s,'Differential Equation Editor');
  fclose(fid);
else
  helpdlg('Unable to locate help files.','DEE');
end
