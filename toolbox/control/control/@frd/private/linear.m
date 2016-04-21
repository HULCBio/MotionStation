function h = linear(sys,w)
%LINEAR  Interpolates frequency response data linearly.
%
%   H = LINEAR(SYS,W) interpolates the frequency response
%   data in the FRD model SYS at the frequencies W.  The 
%   units of W and SYS.FREQUENCY are assumed consistent.
%
%   See also FREQRESP, INTERP.

%	 Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/19 02:48:16 $

% Find relative indices of frequencies W in SYS.FREQUENCY

iw = interp1(sys.Frequency,1:length(sys.Frequency),w(:));  % relative indices
idx_nan = isnan(iw);
validiw = iw(~idx_nan);                   % Get the Valid Non-NaN frequencies.
%
sizes = size(sys.ResponseData);
sizes(3) = length(w);
% Initialize
h = zeros(sizes);
% ----- Generate response data for valid relative indices
if max(abs(iw-round(iw)))<sqrt(eps),
    % W is a subset of SYS.FREQUENCY (all relative indices IW are integers)
    validsizes = size(sys.ResponseData(:,:,round(validiw),:));
    h(:,:,~idx_nan,:) = reshape(sys.ResponseData(:,:,round(validiw),:),validsizes);
else
    % Interpolate FRD data linearly at requested frequencies
    % If iw(k) = i + t with t in [0,1), then w(k) = (1-t) sys.f(i) + t sys.f(i+1)
    iw0 = floor(validiw);
    iw1 = min(iw0+1,size(sys.ResponseData,3));
    t = reshape(validiw-iw0,[1 1 length(validiw)]);
    t = t(ones(1,sizes(1)),ones(1,sizes(2)),:);
    for k=1:prod(sizes(4:end)),
        h(:,:,~idx_nan,k) = (1-t) .* sys.ResponseData(:,:,iw0,k) + ...
            t .* sys.ResponseData(:,:,iw1,k);
    end
end
h(:,:,idx_nan,:) = NaN;

