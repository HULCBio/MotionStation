function Models = looptransfers(LoopData,ModelIDs)
%LOOPTRANSFERS  Returns requested loop transfer models.
%
%   Each loop transfer function is specified by a string 
%   identifier.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.20 $  $Date: 2002/05/11 17:35:51 $

% RE: Closed-loop model is from [r,dy,du,n] to [y,u]
if isa(ModelIDs,'char')
    ModelIDs = {ModelIDs};
end

% Incorporate gain of F and set I/O names in closed-loop model
if any(strncmp(ModelIDs,'$S',2)) | any(strncmp(ModelIDs,'$T',2))
   ClosedLoop = getclosedloop(LoopData);
   if isfinite(ClosedLoop)
      if any(LoopData.Configuration==[1 2])
         % Optimized for speed - replace by product when efficient
         ClosedLoop = gseries(ClosedLoop , blkdiag(getzpkgain(LoopData.Filter,'mag'),eye(3)));
      end
      set(ClosedLoop,'inputname',{'r','dy','du','n'},'outputname',{'y','u'});
   end
end

% Get models
Models = cell(length(ModelIDs),1);
for ct=1:length(ModelIDs)
   switch ModelIDs{ct}
      case '$G'
         Models{ct} = LoopData.Plant.Model;
      case '$H'
         Models{ct} = LoopData.Sensor.Model;
      case '$F'
         Models{ct} = zpk(LoopData.Filter);
      case '$C'
         Models{ct} = zpk(LoopData.Compensator);
      case '$L'
         OL = getopenloop(LoopData);  % zpk model
         if isfinite(OL) 
            % Optimized for speed - replace by product when efficient
            Models{ct} = gseries(OL , getzpkgain(LoopData.Compensator,'mag'));
         else
            % Algebraic loop
            Models{ct} = OL;
         end
      case '$T_r2y'
         Models{ct} = ClosedLoop(1,1);
      case '$T_r2u'
         Models{ct} = ClosedLoop(2,1);
      case '$S_output'
         Models{ct} = ClosedLoop(1,2);
      case '$S_input'
         Models{ct} = ClosedLoop(1,3);
      case '$S_noise'
         Models{ct} = ClosedLoop(1,4);
      case '$Tcl'
         Models{ct} = ClosedLoop;
      otherwise
         % Look in list of saved compensators
         SavedComps = {LoopData.SavedDesigns.Name};  
         isC = strcmp(ModelIDs{ct},strcat(SavedComps,{'_C'}));
         isF = strcmp(ModelIDs{ct},strcat(SavedComps,{'_F'}));
         if any(isC)
            Models{ct} = LoopData.SavedDesigns(isC).Compensator.Model;
         else
            Models{ct} = LoopData.SavedDesigns(isF).Filter.Model;
         end
   end    
end
