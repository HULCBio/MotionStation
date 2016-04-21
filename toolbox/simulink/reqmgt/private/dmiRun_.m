function ret = dmiRun_(filename, instring)
%DMIRUN_ Runs input string for DOORS from DOORS.
%  DMIRUN_(FILENAME, INSTRING) runs INSTRING that contains parameter
%  specifications and the simulation or M-file to run.  Try/catch
%  mechanism is used detect whether the simulation passed or failed.
%  For example, "Ka = 6777;sim('f14');disp('success')" as INSTRING will
%  run f14 and return "success" to the caller.
%  This function is part of the DOORS/MATLAB INTERFACE (DMI).
%

%  Author(s): M. Greenstein, 08/13/99
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:15 $

% Initialization and validation
if (nargin ~= 2), return; end

% Get arguments and run the simulation or program.
runModel = filename;
runStr = instring;
ret= '';
try
	%%%%simset('SrcWorkspace', 'base');
	%%%%@@@runStr = strrep(runStr, '''''', ''''); 
	%%%%Ka = 0.6667; open_system('f14');sim('f14'); disp('success');
	ret = evalc(runStr);
catch
	ret = lasterr;
end

% Send the results back to DOORS.
DOORSHANDLE = actxserver('doors.application');
stat = set(DOORSHANDLE, 'Result', ret);
delete(DOORSHANDLE);

