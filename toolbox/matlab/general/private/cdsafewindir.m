% CDSAFEWINDIR. Change to safe directory in Windows when UNC path cause failures
% This is to check and see if the dos command is working.  In Win95
% if the current directory is a deeply nested directory or sometimes
% for TAS served file systems, the output pipe does not work.  The 
% solution is to make the current directory safe, %windir% and restore
% it afterwards.  The test is the cd command. 
% [cwd] = cdsafewindir
% Return:
%        cwd: string defining path of current working directory

%  JP Barnard
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.3 $ $Date: 2002/04/08 20:51:29 $
%-------------------------------------------------------------------------------
function [cwd] = cdsafewindir
%-------------------------------------------------------------------------------
cwd = '';

try % test for MS DOS related unsafe directories.
   [tmp,tmp]=dos('cd'); % CD should return no message if in a safe directory.
catch % catch MS DOS file handling errors, related to unsafe directory
   cwd = pwd; % store current directory
   cd(getenv('windir')); % change to safe directory (OS root directory)
end
%-------------------------------------------------------------------------------
return
% end of CDSAFEWINDIR
%===============================================================================
