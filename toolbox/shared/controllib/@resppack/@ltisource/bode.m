function bode(this,r,varargin)
%BODE   Updates frequency response data for Bode plots.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:44 $

Ts = this.Model.Ts;
for ct=1:length(r.Data)
   % Look for visible+cleared responses in response array
   if isempty(r.Data(ct).Magnitude) & strcmp(r.View(ct).Visible,'on')
      % Get frequency response data
      d = r.Data(ct);  
      if nargin<3 & strcmp(r.RefreshMode,'quick')
         % Reuse the current frequency vector for maximum speed
         F = freqresp(this,ct,3,r.Data(ct).Frequency);
      else
         % Default behavior: regenerate data on appropriate grid based on input arguments
         F = freqresp(this,ct,3,varargin{:});
         d.Focus = F.Focus;
         d.SoftFocus = F.SoftFocus;
      end
      % Store in response data object (@freqdata instance)
      d.Frequency = F.Frequency;
      d.Magnitude = F.Magnitude;
      d.Phase = F.Phase;
      d.Ts = Ts;
   end
end