function tgscopedemo
% TGSCOPEDEMO Demonstration of xPC TargetScope.
%
%    SCSIGNALDEMO takes the model xpcsosc.mdl, builds it, and downloads it to
%    the target PC. It then sets up four target scopes, each with a
%    different acquisition mode, and displays the 'Integrator1' (output) and
%    'Signal Generator' (input) signal on each of them.
%
%      Scope #1 is set to Redraw,    Grid,   FreeRun.
%      Scope #3 is set to Redraw,    NoGrid, Signal.
%      Scope #6 is set to Numerical,   - ,   Software.
%      Scope #7 is set to Redraw,    Grid,   Scope.
%
%    No explicit triggering is done for scope #6 (software triggered).
%
%    This demo contains an example of the set function, which can be used
%    to set multiple property values in just one command.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.6.1 $ $Date: 2004/04/08 21:05:29 $

% is connection with target working?
if ~strcmp(xpctargetping, 'success')
  error('Connection with target cannot be established');
end

% build xPC application xpcosc and download it onto the target
rtwbuild('xpcosc');

tg = xpc;                               % create an xPC Object

tg.SampleTime = 0.000250;               % set sample time to 250us
tg.StopTime   = 10000;                  % set stoptime to a high value

% define target scope objects 1, 3, 6 and 7: vectorization used
scs = addscope(tg, 'target', [1,3,6,7]);

% get indices of signals 'Integrator1', 'Signal Generator'
signals(1) = getsignalid(tg, 'Integrator1');
signals(2) = getsignalid(tg, 'Signal Generator');

% add sig1 and sig2 to all scope-objects
addsignal(scs, signals);

% set Decimation of 1 for all scope-objects
%scs.Decimation = 1; 
set(scs,'Decimation',1) %setting "a" property for vector scoopes for each obj elem 
                        %must be used with set.

% set scope 1 properties
set(scs(1), ...
    {'NumSamples', 'TriggerMode', 'Grid', 'Mode',   'YLimit'}, ...
    {200,          'FreeRun',     'On',   'Redraw', [-10, 10]});

% set scope 3 properties
set(scs(2), ...
    {'NumSamples', 'TriggerMode', 'TriggerSignal', 'TriggerLevel', ...
     'TriggerSlope', 'Grid', 'Mode'}, ...
    {500,          'Signal',      1,               0.0, ...
     'Rising',       'Off',  'Redraw'});

% set scope 6 properties
set(scs(3), 'NumSamples',100, 'TriggerMode', 'Software', 'Mode', 'Numerical');

% set scope 7 properties
set(scs(4), ...
    {'NumSamples', 'TriggerMode', 'TriggerScope', 'Grid', 'Mode'}, ...
    {2000,         'Scope',       3,              'On',   'Redraw'});

% set ylimits of all scopes in one shot
set(scs([1,3,4]), 'YLimit', 'Auto');

start(scs);                             % start acquisition of all scoopes
start(tg);                              % start simulation
close_system('xpcosc');                 % close model

%% EOF tgscopedemo.m
