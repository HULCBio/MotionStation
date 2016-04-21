function [StartTime,StopTime] = getSimInterval(this)
% Gets simulation interval [StartTime,StopTime].

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:13 $
%   Copyright 1986-2004 The MathWorks, Inc.
ModelWS = get_param(this.Model,'ModelWorkspace');
s = whos(ModelWS);
ModelWSVars = {s.name};

% Evaluate user-defined start and stop times
SimOptions = this.SimOptions;
StartTime = NaN; % default = inherited from model
if ~strcmp(SimOptions.StartTime,'auto')
   [Ts,Fail] = utEvalModelVar(SimOptions.StartTime,ModelWS,ModelWSVars);
   if ~Fail, StartTime = Ts;  end
end
StopTime = NaN;  
if ~strcmp(SimOptions.StopTime,'auto')
   [Tf,Fail] = utEvalModelVar(SimOptions.StopTime,ModelWS,ModelWSVars);
   if ~Fail, StopTime = Tf;   end
end

% Evaluate from model
if isnan(StartTime) || isnan(StopTime)
   [Ts,Tf,Fail] = utGetSimInterval(this.Model,'finite');
   if Fail
      error('Cannot evaluate model start or stop time.')
   else
      if isnan(StartTime), StartTime = Ts; end
      if isnan(StopTime),  StopTime = Tf;  end
   end  
end

% Edge cases
if isinf(StopTime) || StartTime>=StopTime
   % Always return finite Stop time
   StopTime = 2 * StartTime + 10 * (StartTime==0);
end

% Single output -> return [StartTime,StopTime]
if nargout<2
   StartTime = [StartTime,StopTime];
end