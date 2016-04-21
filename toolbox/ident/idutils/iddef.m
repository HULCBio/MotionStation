function [str,props,type,values] = iddef(arg)
%IDDEF  basic definition of structures used in IDENT
%

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $ $Date: 2004/04/10 23:18:32 $

switch arg
case 'algorithm'
   props    = {'Approach','Focus','MaxIter','Tolerance','LimitError','MaxSize',...
         'SearchDirection','FixedParameter','Trace','N4Weight',...
         'N4Horizon','Advanced'};
   
   sea = struct('GnsPinvTol',1e-9,'LmStep',2,'StepReduction',2,'MaxBisections',10,...
      'LmStartValue',0.001,'RelImprovement',0);
   thresh = struct('Zstability',1.01,'Sstability',0,'AutoInitialState',1.2);
   advanced = struct('Search',sea,'Threshold',thresh);
   values   = {'','Prediction',20,0.01,1.6,'Auto','Auto',[],'Off',...
         'Auto','Auto',advanced};
   str      = cell2struct(values,props,2);
   if nargout > 2
      type = {{'Pem','Arx','Subspace','Iv'},...
            {'Prediction','Simulation','Stability'},...
            {'integer'},{'positive'},{'positive'},...
            {'integer'},{'Auto','Lm','Gns','Gn'},{''},{'Off','On','Full'},...
            {'Auto','MOESP','CVA'},{'intarray'},{'struct'}};
   end
   
case 'structpoly'
   props  = {'na','nb','nc','nd','nf','nk','InitialState'};
   values = {0,[],0,0,[],[],'Zero'};
   str    = cell2struct(values,props,2); 
   if nargout > 2
      type  = {{'integer'},{'integer'},{'integer'},{'integer'},{'integer'},...
            {'integer'},{'Zero','Estimate','Backcast','Auto'}};
   end
   
case 'estimation'
   props = {'Status','Method','LossFcn','FPE','DataName','DataLength','DataTs',...
         'DataDomain','DataInterSample','WhyStop','UpdateNorm','LastImprovement',...
         'Iterations','InitialState','Warning'};
   values={'Not estimated',[],[],[],[],[],[],'Time',[],[],[],[],[],[],'None'};
   str = cell2struct(values,props,2); 
   if nargout > 2
      type  ={{'Not estimated','Estimated model',...
               'Model modified after last estimate'},...
            {'positive'},{'positive'},{'string'},{'integer'},{'positive'},...
            {'Zero order hold','First order hold','BandLimited'},{'string'},...
            {'positive'},{'positive'},{'integer'},{'string'}};
   end
otherwise
   error('Unrecognized input option.');
end
