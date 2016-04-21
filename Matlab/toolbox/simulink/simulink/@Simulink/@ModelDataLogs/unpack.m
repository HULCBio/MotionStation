% Simulink.ModelDataLogs.unpack
%
% Extracts elements from a ModelDataLogs object and writes them into
% the MATLAB workspace.
%
% For an object named `logsout':
%
% logsout.unpack
%
%    Extracts the top level of a ModelDataLogs object.
%
% logsout.unpack('systems')
%
%    Extracts timeseries and TsArray objects from logsout.  TsArray objects 
%    are not expanded into individual timeseries.  No intermediate objects 
%    {ModelDataLogs, SubsysDataLogs} are written to the MATLAB workspace.
%
% logsout.unpack('all')
%
%    Extracts all timeseries objects.  TsArray objects will be expanded into
%    individual timeseries.  No intermediate objects {ModelDataLogs, 
%    SubsysDataLogs, TsArray} are written to the MATLAB workspace.
%
% Other methods for Simulink.ModelDataLogs: who, whos

% Copyright 2004 The MathWorks, Inc.
