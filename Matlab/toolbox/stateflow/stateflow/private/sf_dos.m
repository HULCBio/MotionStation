function sf_dos(command)
%% sf_dos(command) - invoke system command with tee to log file
 
% Vijay Raghavan
% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.13.2.4 $  $Date: 2004/04/15 00:59:29 $

 
	compilerOutput= evalc(['dos(''',command,''');']);
	sf_display('Make',compilerOutput);

