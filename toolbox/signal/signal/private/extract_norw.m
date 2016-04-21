function [n_or_w, options] = extract_norw(varargin)
%EXTRACT_NORW Deal optional inputs of phasez and zerophase.
%   [N_OR_W, OPTIONS]=EXTRACT_NORW(VARARGIN) return the third input of freqz N_OR_W
%   that can be either nfft or a vector of frequencies where the frequency response 
%   will be evaluated.

%   Author(s): V.Pellissier, R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 01:09:06 $ 

% Default values
n_or_w = 512;
options = {};

if nargin>0 & isnumeric(varargin{1}) & ~isempty(varargin{1}) & ...
        isreal(varargin{1}),
    n_or_w = varargin{1};
    varargin{1} = [];
    if nargin>1,
        options = {varargin{2:end}};
    end
else
    options = {varargin{:}};
end


% [EOF]
