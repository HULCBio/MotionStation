function [prop]  = initprop
% INITPROP xPC initializer (private)
%
%   INITPROP initializes the properties for the xPC object; it fills
%   the structure with the default values.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.11.6.1 $  $Date: 2004/04/08 21:03:39 $
%

propname = {
    'Version'                           % 01
    'Connected',                        % 02
    'Application',                      % 03
    'Status',                           % 04
    'CPUoverload',                      % 05
    'StopTime',                         % 06
    'SampleTime',                       % 07
    'ExecTime',                         % 08
    'SessionTime',                      % 09
    'Command',                          % 10
    'ViewMode',                         % 11
    'MinTET',                           % 12
    'MaxTET',                           % 13
    'AvgTET',                           % 14
    'NumParameters',                    % 15
    'MaxLogSamples',                    % 16
    'LogMode',                          % 17
    'NumLogWraps',                      % 18
    'TimeLog',                          % 19
    'StateLog',                         % 20
    'OutputLog',                        % 21
    'TETLog',                           % 22
    'ShowParameters',                   % 23
    'TunParamName',                     % 24
    'TunParamIndex',                    % 25
    'ParameterValue',                   % 26
    'Scopes',                           % 27
    'ShowSignals',                      % 28
    'HostScopes',                       % 29
    'TargetScopes',                     % 30
    'NumSignals',                       % 31
    'Mode'                              % 32
           };

propval={
    '2.5',                              % 01
    'unknown',                          % 02
    'unknown',                          % 03
    'unknown',                          % 04
    'unknown',                          % 05
    'NaN',                              % 06
    'NaN',                              % 07
    'NaN',                              % 08
    'NaN',                              % 09
    '',                                 % 10
    'unknown',                          % 11
    NaN,                                % 12
    NaN,                                % 13
    NaN,                                % 14
    'NaN',                              % 15
    'NaN',                              % 16
    'Normal',                           % 17
    'NaN',                              % 18
    'unknown',                          % 19
    'unknown',                          % 20
    'unknown',                          % 21
    'unknown',                          % 22
    'Off',                              % 23
    'unknown',                          % 24
    [],                                 % 25
    {},                                 % 26
    'unknown',                          % 27
    'Off',                              % 28
    'unknown',                          % 29
    'unknown',                          % 30
    'unknown',                          % 31
    'unknown'                           % 32
        };

propWritable = {
    'StopTime',       '';               % 06
    'SampleTime',     '';               % 07
    'Command', '[Start | Stop | Boot | Remove]', % 10
    'ViewMode',       '';               % 11
    'LogMode',        '[0 | 1]';        % 17
    'ShowParameters', '[On | {Off}]';   % 23
    'ShowSignals',    '[On | {Off}]';   % 28
    'TunParamIndex',  '';
    'ParameterValue', '';
 };

propWriteOnly = {'Command', 'TunParamIndex', 'ParameterValue'};

prop.propname      = propname;
prop.propval       = propval;
prop.propWritable  = propWritable;
prop.propWriteOnly = propWriteOnly;

%% EOF initprop.m
