function lsim(this, r)
% SIMRESP Updates lsim plot response data
%

%  Author(s): James G. owen
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:58 $

s = size(this.Model);
if prod(s(3:end))~=length(r.Data)
   return  % number of models does not match number of data objects
end

% Get new data from the @ltisource object.
NormalRefresh = strcmp(r.RefreshMode, 'normal');
Ts = getst(this.Model);

% Get input names and number of inputs
[junk, innames] = getrcname(this); 

% Get initial condition
x0 = r.Context.IC;
  
% If there are insufficient inputs or missing time vectors ->
% exception
SimInput = r.Parent.Input;
if strcmp(r.Parent.InputStyle,'tiled')
   theseInputs = SimInput.Data(r.Context.InputIndex);
   if any(cellfun('isempty',get(theseInputs,{'Amplitude'}))) || ...
         any(cellfun('isempty',get(theseInputs,{'Time'})))
      return
   end
   % Get the input and initial states
   t = theseInputs(1).Time;
   for k=s(2):-1:1
      u(:,k) = theseInputs(k).Amplitude;
   end
else
   t = SimInput.Data.Time;
   u = SimInput.Data.Amplitude;
end

for ct = 1:length(r.Data)
   % Look for visible+cleared responses in response array
   if isempty(r.Data(ct).Amplitude) && strcmp(r.View(ct).Visible,'on')
      sys = this.Model(:,:,ct);
      if isfinite(sys) && iscomputable(sys,'lsim',NormalRefresh,t,x0,u)
         % Skip if model is NaN or response cannot be computed
         d = r.Data(ct);  
         if NormalRefresh
            % Regenerate data on appropriate grid based on input arguments
             [d.Amplitude,d.Time,d.Focus] = gentresp(sys, 'lsim', t,x0,u,r.Parent.Input.Interpolation);
         else
            % Reuse the current time vector for maximum speed
             d.Amplitude = gentresp(sys, 'lsim', d.Time, x0,u,r.Parent.Input.Interpolation);
         end
         d.Ts = Ts;
      end
   end
end
