function initial(this, r, T)
% SIMRESP Updates initial plot response data
%
%  T = Tfinal or time vector.

%  Author(s): James G. owen
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:56 $

s = size(this.Model);
if prod(s(3:end))~=length(r.Data)
   return  % number of models does not match number of data objects
end

% Get new data from the @ltisource object.
NormalRefresh = strcmp(r.RefreshMode, 'normal');
Ts = getst(this.Model);

% Get initial condition
x0 = r.Context.IC;
     
for ct = 1:length(r.Data)
   % Look for visible+cleared responses in response array
   if isempty(r.Data(ct).Amplitude) && strcmp(r.View(ct).Visible,'on')
      sys = this.Model(:,:,ct);
      if isfinite(sys) && iscomputable(sys,'initial',NormalRefresh,T,x0)
         % Skip if model is NaN or response cannot be computed
         d = r.Data(ct);  
         if NormalRefresh
            % Regenerate data on appropriate grid based on input arguments
             [d.Amplitude,d.Time,d.Focus] = gentresp(sys, 'initial', T, x0);
         else
            % Reuse the current time vector for maximum speed
             d.Amplitude = gentresp(sys, 'initial', d.Time, x0);
         end
         d.Ts = Ts;
      end
   end
end
