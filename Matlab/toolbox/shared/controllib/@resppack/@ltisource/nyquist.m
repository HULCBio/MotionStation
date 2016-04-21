function nyquist(this, r, w)
%NYQUIST  Updates frequency response data.

%  Author(s): P. Gahinet, B. Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:01 $
s = size(this.Model);
if prod(s(3:end))~=length(r.Data)
   return  % number of models does not match number of data objects
end

% Get new data from the @ltisource object.
NormalRefresh = strcmp(r.RefreshMode, 'normal');
isFinite = isfinite(this.Model);  % detect models with NaN's
for ct = 1:length(r.Data)
   % Look for visible+cleared responses in response array
   if isFinite(ct) && isempty(r.Data(ct).Response) && strcmp(r.View(ct).Visible,'on')
      % Get frequency response data
      d = r.Data(ct);  
      if NormalRefresh
         % Default behavior: regenerate data on appropriate grid based on input
         % arguments
         F = freqresp(this,ct,1,w);
         d.Focus = F.FocusInfo.Range(1,:);
         d.SoftFocus = F.FocusInfo.Soft;
      else
         % Reuse the current frequency vector for maximum speed
         F = freqresp(this,ct,1,d.Frequency);
      end
      % Store in response data object (@magphasedata instance)
      d.Frequency = F.Frequency;
      d.Response = F.Magnitude .* exp(1i*F.Phase);
   end
end
