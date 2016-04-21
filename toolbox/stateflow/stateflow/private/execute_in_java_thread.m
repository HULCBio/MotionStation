function execute_in_java_thread( command )
%  Sneaky utility that takes advantage of Java Threads to run a 
%  MATLAB command in the background

%
%	J. Breslau
%   Copyright 1995-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:57:36 $

if ischar(command) 
    command = {command};
end

if ~iscell(command) 
    error(['Command to execute must be a string: ' command]);
end

for i = 1:length(command)
    if ~ischar(command{i})
        error(['Command to execute must be a string: ' command{i}]);
    end
end

com.mathworks.toolbox.stateflow.util.ExecuteThread.execThread(command);
