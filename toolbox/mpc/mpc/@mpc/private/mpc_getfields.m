function [ManipulatedVariables,OutputVariables,Plant,Disturbance,Noise,... %InputCovariance,DisturbanceCovariance,NoiseCovariance,...
      Ts,MinOutputECR,MaxIter,...
      PredictionHorizon,ControlHorizon,Nominal,MPCData,Weights]=...
   mpc_getfields(mpcobj);

% MPC_GETFIELDS Get fields from MPC object

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/04/16 22:09:18 $   


if ~isa(mpcobj,'mpc'),  
   error('mpc:mpc_getfields:obj','Invalid MPC object')
end

mpcobj=struct(mpcobj);

fields={'ManipulatedVariables','OutputVariables','Model', ... %'StateEstimator',...
      'Ts','MPCData','Optimizer','PredictionHorizon','ControlHorizon',...
      'Weights'};

for i=1:length(fields),
   %eval(['isf=isfield(mpcobj,''' fields{i} ''');']);
   isf=isfield(mpcobj,fields{i});
   if isf,
      %aux=['mpcobj.' fields{i}];
      aux=mpcobj.(fields{i});
   else
      %aux='[]';
      aux=[];
   end
   %eval([fields{i} '=' aux ';']);
   switch fields{i}
       case 'ManipulatedVariables'
           ManipulatedVariables=aux;
       case 'OutputVariables'
           OutputVariables=aux;
       case 'Model' ;%case 'StateEstimator'
           Model=aux;
       case 'Ts'
           Ts=aux;
       case 'MPCData'
           MPCData=aux;
       case 'Optimizer'
           Optimizer=aux;
       case 'PredictionHorizon'
           PredictionHorizon=aux;
       case 'ControlHorizon'
           ControlHorizon=aux;
       case 'Weights'
           Weights=aux;
   end
end


fields={'Plant','Disturbance','Noise','Nominal'};

for i=1:length(fields),
   %aux=['Model.' fields{i}]; 
   aux=Model.(fields{i}); % Field exists because MPC constructor checked for it
   
   %eval([fields{i} '=' aux ';']);
   switch fields{i}
       case 'Plant'
           Plant=aux;
       case 'Disturbance'
           Disturbance=aux;
       case 'Noise'
           Noise=aux;
       case 'Nominal'
           Nominal=aux;
   end
end

%fields={'InputCovariance','DisturbanceCovariance','NoiseCovariance'};
%
%for i=1:length(fields),
%   eval(['isf=isfield(StateEstimator,''' fields{i} ''');']);
%   if isf,
%      aux=['StateEstimator.' fields{i}];
%   else
%      aux='[]';
%   end
%   eval([fields{i} '=' aux ';']);
%end

fields={'MinOutputECR','MaxIter'};

for i=1:length(fields),
   %eval(['isf=isfield(Optimizer,''' fields{i} ''');']);
   isf=isfield(Optimizer,fields{i});
   if isf,
      %aux=['Optimizer.' fields{i}];
      aux=Optimizer.(fields{i});
   else
       %aux='[]';
       aux=[];
   end
   %eval([fields{i} '=' aux ';']);
   switch fields{i}
       case 'MinOutputECR'
           MinOutputECR=aux;
       case 'MaxIter'
           MaxIter=aux;
   end
end


%fields={'InitialState','InitialInput'};
%
%for i=1:length(fields),
%   eval(['isf=isfield(MPCData,''' fields{i} ''');']);
%   if isf,
%      aux=['MPCData.' fields{i}];
%   else
%      aux='[]';
%   end
%   eval([fields{i} '=' aux ';']);
%end

% Fill in possible missing fields in Nominal

fields={'X','U','Y','DX'};

for i=1:length(fields),
   %eval(['isf=isfield(Nominal,''' fields{i} ''');']);
   isf=isfield(Nominal,fields{i});
   if ~isf
      %eval(['Nominal.' fields{i} '=[];']);
      Nominal.(fields{i})=[];
   end
end

%% Fill in possible missing fields in InitialState
%
%fields={'Plant','Disturbance','Noise'};
%
%for i=1:length(fields),
%   eval(['isf=isfield(InitialState,''' fields{i} ''');']);
%   if ~isf
%      eval(['InitialState.' fields{i} '=[];']);
%   end
%end
