function matweb(instruct)
%MATLAB Web Server matweb main entry point.
%   MATWEB(INSTRUCT) calls the main application M-file stored
%   in the mlmfile field of structure INSTRUCT and passes
%   this structure to the application.  Invoked by matweb,
%   the TCP/IP client of matlabserver.  INSTRUCT is a MATLAB
%   structure containing the following fields:
%   
%      All the data from the HTML input document
%
%      MLMFILE, which stores the name of the M-file to call
%
%      MLDIR, the working directory specified in matweb.conf
%
%      MLID, the unique identifier for creating filenames and
%      for maintaining contexts. 
%
%
%   If a MATLAB error is encountered, the text
%   is captured, using the EVAL and LASTERR functions, 
%   and returned to the user's browser.  Warnings are
%   turned off and then restored.
%
%   See also EVAL, LASTERR, and LASTWARN, and WARNING.
%
  
%   Author(s): M. Greenstein, 08-04-97
%   Copyright 1998-2001 The MathWorks, Inc.
%   $Revision: 1.9 $   $Date: 2001/11/13 15:51:32 $


% Initialize the return string.
outstr = char('');

% Warnings are turned off here and restored below. 
warnState = warning;
warning off;

% Use try/catch mechanism to trap errors.
try
   % Get specific mfile to run out of the input argument.
   mlmfile = getfield(instruct, 'mlmfile');
   % Execute the mlmfile.   
   outstr = feval(mlmfile, instruct);
catch
   outstr = [ sprintf('Content-type: text/html\n\n<html><body>') ...
      'MATLAB Application Error:<p><p>' lasterr '</body></html>' ];
end   

% Send the output string back to stdio.
disp(outstr);

% Restore the warning state.
warning(warnState);

% end of function
