% Simulink.SubsysDataLogs.who
%
% List the contents of a SubsysDataLogs object.
%
% For a subsystem data log object named subsystem:
%
% subsystem.who
%
%   Lists the log names of the signals logged in the top level of
%   a SubsysDataLogs object
%
% subsystem.who('systems')
%
%   Lists the log names of all signals including composite signals
%   (i.e., buses and muxes) but not elements of composite signals
%
% subsystem.who('all')
%
%   Lists the log names of all signals including the elements of
%   composite signals
%
% S = subsystem.who
%
%   Returns a cell array containing the log names of the signals
%   logged by subsystem
%
%
% Other methods for Simulink.SubsysDataLogs: unpack, whos

% Copyright 2004 The MathWorks, Inc.
