function flag=compare(MPC1,MPC2)
%COMPARE Compare two MPC objects
%   
%   flag=COMPARE(MPC1,MPC2) compares the contents of two MPC objects. If
%   the design specifications (models, weights, horizons, etc.) are
%   identical, then flag = 1.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:35:01 $   

if nargin<2,
    error('mpc:compare:two','You need to compare two MPC objects');
end
if ~isa(MPC1,'mpc') | ~isa(MPC2,'mpc'),
    error('mpc:compare:obj','Invalid MPC object');
end

if isempty(MPC1) & isempty(MPC2),
    flag=1;
    return
end

if isempty(MPC1) | isempty(MPC2),
    flag=0;
    return
end

flag=isequal(MPC1.ManipulatedVariables,MPC2.ManipulatedVariables) & ...
    isequal(MPC1.OutputVariables,MPC2.OutputVariables) & ...
    isequal(MPC1.DisturbanceVariables,MPC2.DisturbanceVariables) & ...
    isequal(MPC1.Weights,MPC2.Weights) & ...
    isequal(MPC1.Model,MPC2.Model) & ...
    isequal(MPC1.Ts,MPC2.Ts) & ...
    isequal(MPC1.Optimizer,MPC2.Optimizer) & ...
    isequal(MPC1.PredictionHorizon,MPC2.PredictionHorizon) & ...
    isequal(MPC1.ControlHorizon,MPC2.ControlHorizon) & ...
    isequal(MPC1.Notes,MPC2.Notes) & ...
    isequal(MPC1.UserData,MPC2.UserData);

data1=getmpcdata(MPC1);
data2=getmpcdata(MPC2);

isoutdist1=isfield(data1,'OutDistModel');
isoutdist2=isfield(data2,'OutDistModel');

if isoutdist1 & isoutdist2,
    flag=flag & isequal(data1.OutDistModel,data2.OutDistModel);
elseif (~isoutdist1 & isoutdist2) | (isoutdist1 & ~isoutdist2),
    flag=0;
end
    
