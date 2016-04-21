function loadNCDStruct(this,ncdStruct,PortNum)
% Reads old NCD structure (pre-R14)

%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:45:03 $
%   Copyright 1986-2004 The MathWorks, Inc.
Warn = {};

% Assumptions: the constraints are listed in the same order as in the
%              original structure
C = this.Tests(1).Specs;
nC  = length(C);
if nargin<3
   PortNum = 1:nC;
end

% Parameter list and settings
ParNames = localGetPars(ncdStruct.TvarStr);
npars = length(ParNames);
if npars>0
   % Check against list of all model parameters
   TunablePars = getTunableParams(this);
   isDefined = ismember(strtok(ParNames,'.({'),{TunablePars.Name});
   if any(~isDefined)
      Warn = [Warn ; {'Some tuned parameters in ncdStruct do not exist in the model.'}];
      ParNames = ParNames(isDefined);
      npars = length(ParNames);
   end
   % Create parameter specs
   ParSpec = [];
   for ct=1:npars
      ps = srogui.ParameterForm(ParNames{ct});
      ParSpec = [ParSpec ; ps];
   end
   % Try evaluating lower and upper bounds
   try
      LB = evalin('base',['{' ncdStruct.TvlbStr '}']);
      if length(LB)==npars
         for ct=1:npars
            ParSpec(ct).Minimum = mat2str(LB{ct},8);
         end
      end
   catch
      Warn = [Warn ; {'Could not evaluate parameter lower bound in workspace.'}];
   end
   try
      UB = evalin('base',['{' ncdStruct.TvubStr '}']);
      if length(UB)==npars
         for ct=1:npars
            ParSpec(ct).Maximum = mat2str(UB{ct},8);
         end
      end
   catch
      Warn = [Warn ; {'Could not evaluate parameter upper bound in workspace.'}];
   end
   % Initialize parameters
   this.setTunedParams(ParSpec)
end

% Reload constraint settings
for ct=1:nC
   port = PortNum(ct);
   % Lower bounds
   idx = find(ncdStruct.CnstrLB(1,:)==port);
   nlb = length(idx)/2;
   if nlb>0
      lbx = ncdStruct.CnstrLB(2,idx);
      C(ct).LowerBoundX = reshape(lbx(:),[2 nlb])';
      lby = ncdStruct.CnstrLB(3,idx);
      C(ct).LowerBoundY = reshape(lby(:),[2 nlb])';
      lbw = ncdStruct.CnstrLB(4,idx(1:2:end));
      C(ct).LowerBoundWeight = reshape(lbw,[nlb 1]);
   end
   % Upper bounds
   idx = find(ncdStruct.CnstrUB(1,:)==port);
   nub = length(idx)/2;
   if nub>0
      ubx = ncdStruct.CnstrUB(2,idx);
      C(ct).UpperBoundX = reshape(ubx(:),[2 nub])';
      uby = ncdStruct.CnstrUB(3,idx);
      C(ct).UpperBoundY = reshape(uby(:),[2 nub])';
      ubw = ncdStruct.CnstrUB(4,idx(1:2:end));
      C(ct).UpperBoundWeight = reshape(ubw,[nub 1]);
   end
end

% Uncertainty
if ~isempty(ncdStruct.UvarStr)
   % Add uncertainty test
   if length(this.Tests)==1
      UTest = copy(this.Tests(1));
      UTest.Specs = C;
      UTest.SimOptions = this.Tests(1).SimOptions;
   else
      UTest = this.Tests(2);
   end
   UPars = localGetPars(ncdStruct.UvarStr);
   USet = srogui.RandSetForm;
   np = length(UPars);
   ValidSpec = true;
   % Try evaluating lower and upper bounds
   try
      LB = evalin('base',['{' ncdStruct.UvlbStr '}']);
   catch
      Warn = [Warn ; {'Could not evaluate uncertainty lower bound in workspace.'}];
      ValidSpec = false;
   end
   try
      UB = evalin('base',['{' ncdStruct.UvubStr '}']);
   catch
      Warn = [Warn ; {'Could not evaluate uncertainty upper bound in workspace.'}];
      ValidSpec = false;
   end
   % Try gettting nominal values
   Nominal = cell(np,1);
   for ct=1:np
      p = UPars{ct};
      % Evaluate nominal value
      try
         Nominal{ct} = evalin('base',p);
      catch
         Warn = [Warn ; {sprintf('Could not find uncertain parameter %s.',p)}];
         ValidSpec = false;  break
      end
   end
   if ValidSpec && length(LB)==np && length(UB)==np
      for ct=1:np
         USet.addpar(UPars{ct},Nominal{ct});
         USet.Parameters(ct).Min = mat2str(LB{ct},8);
         USet.Parameters(ct).Max = mat2str(UB{ct},8);
      end
      USet.NumSamples = num2str(ncdStruct.NumMC);
      % Optim settings
      if ncdStruct.PlntON(4)
         USet.Optimized = 'all';
      elseif any(ncdStruct.PlntON(2:3))
         USet.Optimized = 'vertex';
      else
         USet.Optimized = 'none';
      end
      UTest.Runs = USet;
      % Update test
      this.Tests(2,1) = UTest;
      if ncdStruct.PlntON(1)
         this.Tests(1).Optimized = 'on';
      else
         this.Tests(1).Optimized = 'off';
      end
   end
end

% Issue warning
if ~isempty(Warn)
   warndlg(Warn,'Update Warning','modal')
end


%--------------- Local Functions ------------------

function p = localGetPars(pstr)
% Converts 'a b c' to {'a','b','c'}
p = cell(1,0);
while ~isempty(pstr)
   [t,pstr] = strtok(pstr);
   if ~isempty(t)
      p(1,end+1) = {t};
   end
end



