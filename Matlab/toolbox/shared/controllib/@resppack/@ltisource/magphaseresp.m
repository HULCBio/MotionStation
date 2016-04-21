function magphaseresp(this, RespType, r, w)
%MAGPHASERESP  Updates magnitude and phase data of @magphasedata
%         objects.
%
%  RESPTYPE = 'bode' or 'nichols'

%  Author(s): P. Gahinet, B. Eryilmaz
%  Copyright 1986-2002 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:05:40 $
s = size(this.Model);
if prod(s(3:end))~=length(r.Data)
   return  % number of models does not match number of data objects
end

% Plot-type-specific settings
switch RespType
   case 'bode'
      grade = 3;  
   case 'nichols'
      grade = 2;
end

% Get new data from the @ltisource object.
NormalRefresh = strcmp(r.RefreshMode, 'normal');
isFinite = isfinite(this.Model);  % detect models with NaN's
Ts = getst(this.Model);
for ct = 1:length(r.Data)
   % Look for visible+cleared responses in response array
   if isFinite(ct) && isempty(r.Data(ct).Magnitude) && strcmp(r.View(ct).Visible,'on')
      % Get frequency response data
      d = r.Data(ct);  
      if NormalRefresh
         % Default behavior: regenerate data on appropriate grid based on input
         % arguments
         F = freqresp(this,ct,grade,w);
         d.Focus = F.FocusInfo.Range(grade,:);
         d.SoftFocus = F.FocusInfo.Soft;
      else
         % Reuse the current frequency vector for maximum speed
         F = freqresp(this,ct,grade,d.Frequency);
      end
      
      % Ignore phase where gain is 0 or Inf (see g144852)
      phase = F.Phase;
      phase(~isfinite(F.Magnitude) | F.Magnitude==0) = NaN;  % phase of 0 or Inf undefined
      
      % Store in response data object (@magphasedata instance)
      d.Frequency = F.Frequency;
      d.Magnitude = F.Magnitude;
      d.Phase = phase;
      d.Ts = Ts;
   end
end
