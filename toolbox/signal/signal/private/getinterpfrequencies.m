function [upn_or_w, upfactor, iswholerange] = getinterpfrequencies(n_or_w, varargin)
%GETINTERPFREQUENCIES  Define the interpolation factor for phasez and zerophase.
%   [UPN_OR_W, UPFACTOR, ISWHOLERANGE] = GETINTERPFREQUENCIES(N_OR_W, VARARGIN) returns
%   the nfft (respectively w frequencies vector) UPN_OR_W to pass to freqz that is 
%   greater than a treshold (2^13), the upsampling factor UPFACTOR and a 
%   the ISWHOLERANGE boolean. 

%   Author(s): V.Pellissier, R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 01:09:09 $ 

% Minimum number of point where the frequenciy response will be evaluated.
threshold = 2^13;

% Determine if the whole range is needed
iswholerange = 0;
if nargin>2 & any(strcmpi('whole', varargin)),
    iswholerange = 1;
end

isn = 0;
N = length(n_or_w);
if length(n_or_w)==1,
    isn = 1;
    N = n_or_w;
end
 
% Default values
upn_or_w = N;;
upfactor = 1;

% Compute the upfactor
if N<threshold,
    upfactor = ceil(threshold/N);
    if iswholerange,
        upfactor = 2*upfactor;
    end
end
    
if isn,
    upn_or_w = N*upfactor;
else
    % Interpolate w if needed
    w = n_or_w(:);
    upn_or_w = interp(w, upfactor);
end
    
% [EOF]
