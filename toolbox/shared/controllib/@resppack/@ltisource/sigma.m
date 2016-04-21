function sigma(this,r,w)
%SIGMA   Updates Singular Value data for SIGMA plots.

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:21:06 $
s = size(this.Model);
if prod(s(3:end))~=length(r.Data)
   return  % number of models does not match number of data objects
end

% Get new data from the @ltisource object.
NormalRefresh = strcmp(r.RefreshMode, 'normal');
Ts = getst(this.Model);
isFinite = isfinite(this.Model);  % detect models with NaN's
for ct=1:length(r.Data)
   % Look for visible+cleared responses in response array
   if isFinite(ct) && isempty(r.Data(ct).SingularValues) && strcmp(r.View(ct).Visible,'on')
      % Get frequency response data
      d = r.Data(ct);  
      if NormalRefresh
         % Default behavior: regenerate data on appropriate grid based on input arguments
         F = freqresp(this, ct, 4, w);
         d.Focus = F.FocusInfo.Range(4,:);
         d.SoftFocus = F.FocusInfo.Soft;
      else
         % Dynamic update: reuse the current frequency vector for maximum speed
         F = freqresp(this, ct, 4, d.Frequency);
      end
      % Store in response data object (@sigmadata instance)
      d.Frequency = F.Frequency;
      d.SingularValues = LocalSigResp(this,F);
      d.Ts = Ts;
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sv = LocalSigResp(this,F)
%SIGRESP   Computes the singular value response of the LTI system SYS
%          over the frequency grid w

% Calculate complex frequency response
[lw,ny,nu] = size(F.Magnitude);
nsv = min(ny,nu);
sv = zeros(lw,nsv);
for ct=1:lw,
   % Guard against Inf values
   resp = reshape(F.Magnitude(ct,:,:).*exp(1i*F.Phase(ct,:,:)),[ny nu]);
   if all(isfinite(resp)),
      sv(ct,:) = svd(resp)';
   else
      sv(ct,:) = Inf;
   end
end
