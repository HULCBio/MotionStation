% Simulink.SubsysDataLogs.unpack
%
% Extracts elements from a SubsysDataLogs object and writes them into
% the MATLAB workspace.
%
% For a subsystem data log object named `subsystem':
%
% subsystem.unpack
%
%    Extracts the top level of a SubsysDataLogs object.
%
% subsystem.unpack('systems')
%
%    Extracts all signals including composite signals (i.e., buses and muxes)
%    but not elements of composite signals
%
% subsystem.unpack('all')
%
%    Extracts all objects including the elements of composite signals
%
% Other methods for Simulink.SubsysDataLogs: who, whos

% Copyright 2004 The MathWorks, Inc.

