function rlocus(this,r,varargin)
%RLOCUS   Computes or updates root locus data.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:21:04 $
s = size(this.Model);
if prod(s(3:end))~=length(r.Data)
   return  % number of models does not match number of data objects
end

% Get new data from the @ltisource object.
NormalRefresh = strcmp(r.RefreshMode, 'normal');
Ts = getst(this.Model);
for ct=1:length(r.Data)
   % Look for visible+cleared responses in response array
   if isempty(r.Data(ct).Roots) && strcmp(r.View(ct).Visible,'on')
      sys = this.Model(:,:,ct);
      if isfinite(sys) && iscomputable(sys,'rlocus',NormalRefresh)
         d = r.Data(ct);
         if nargin>=3 || NormalRefresh
            [Roots,Gains,d.SystemZero,d.SystemPole,d.SystemGain] = ...
               genrlocus(sys,varargin{:});
            % Focus
            [d.XFocus,d.YFocus] = rloclims(Roots,Ts);
         else
            % Reuse the current gain vector for maximum speed
            [Roots,Gains,d.SystemZero,d.SystemPole,d.SystemGain] = ...
               genrlocus(sys,d.Gains);
         end
         % Store in response data object (@rldata instance)
         d.Gains = Gains(:);
         d.Roots = Roots.';
         d.Ts = Ts;
      end
   end
end