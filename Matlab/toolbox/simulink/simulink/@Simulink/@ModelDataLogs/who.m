% Simulink.ModelDataLogs.who
%
% List the contents of a ModelDataLogs object.
%
% For an object named logsout:
%
% logsout.who  
%
%   Lists the log names of the signals logged in the top level of 
%   a ModelDataLogs object
%
% logsout.who('systems')
%
%   Lists the log names of all signals including composite signals
%   (i.e., buses and muxes) but not elements of composite signals
%
% logsout.who('all')
%
%   Lists the log names of all signals including the elements of 
%   composite signals
%
% S = logsout.who 
%
%   Returns a cell array containing the log names of the signals
%   logged by logsout
%
%
% Other methods for Simulink.ModelDataLogs: unpack, whos

% Copyright 2004 The MathWorks, Inc.
