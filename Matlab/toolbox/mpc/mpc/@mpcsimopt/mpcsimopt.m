function SimOptions = mpcsimopt(mpcobj)
%MPCSIMOPT Constructor for @mpcsimopt class -- Specifying MPC simulation options
%
%   SimOptions = mpcsimopt  creates an empty MPC Simulation Options
%   mpcobject 
%  
%   SimOptions has the following fields:
% 
%      PlantInitialState: initial state vector of plant model generating the data.
% ControllerInitialState: initial condition of the MPC controller [extended
%                         state vector estimate;manipulated variables
%                         before starting simulation]
%  UnmeasuredDisturbance: unmeasured disturbance signal entering plant model
%             InputNoise: noise on manipulated vars
%            OutputNoise: noise on measured outputs
%           RefLookAhead: preview on reference signal [on | {off}]
%            MDLookAhead: preview on measured disturbance [on | {off}]
%            Constraints: use MPC constraints [{on} | off]
%                  Model: model used in simulation for generating the data
%              StatusBar: display wait bar [on | {off}]
%               MVSignal: sequence of manipulated variables (with offsets)
%                         for open-loop simulation (no MPC action
%                         calculated). Reference signal r is ignored.
%               OpenLoop: performs open-loop simulation [on | {off}]
%
%   UnmeasuredDisturbance is an array with as many columns as unmeasured
%   disturbances, OutputNoise is an array with as many columns as measured
%   outputs, InputNoise is an array with as many columns as manipulated
%   variables (the last sample of is extended constantly over the
%   horizon to obtain the correct size).
%
%   Model is useful for simulating the MPC controller under model mismatch.
%   Model can either be an LTI object replacing Model.Plant, or a
%   structure with fields Plant, Nominal. By default, simModel contains the
%   Plant and Nominal fields of MPCobj.Model (no model mismatch).
%   If Model is specified, then PlantInitialState refers to the initial
%   state of Model.Plant and is defaulted to Model.Nominal.x.
%
%   See also SIM.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2004/04/10 23:35:24 $   


SimOptions = struct('PlantInitialState',[],'ControllerInitialState',[],'UnmeasuredDisturbance',[],...
    'InputNoise',[],'OutputNoise',[],'RefLookAhead','off','MDLookAhead','off','Constraints','on',...
    'Model',[],'StatusBar','off','MVSignal',[],'OpenLoop','off');

SimOptions = class(SimOptions,'mpcsimopt');

