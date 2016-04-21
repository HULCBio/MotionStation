function [thr,sorh,keepapp,crit] = ddencmp(dorc,worwp,x)
%DDENCMP Default values for de-noising or compression.
%   [THR,SORH,KEEPAPP,CRIT] = DDENCMP(IN1,IN2,X)
%   returns default values for de-noising or compression,
%   using wavelets or wavelet packets, of an input vector
%   or matrix X which can be a 1-D or 2-D signal.
%   THR is the threshold, SORH is for soft or hard
%   thresholding, KEEPAPP allows you to keep approximation
%   coefficients, and CRIT (used only for wavelet packets)
%   is the entropy name (see WENTROPY).
%   IN1 is 'den' or'cmp' and IN2 is 'wv' or 'wp'.
%
%   For wavelets (three output arguments):
%   [THR,SORH,KEEPAPP] = DDENCMP(IN1,'wv',X) 
%   returns default values for de-noising (if IN1 = 'den')
%   or compression (if IN1 = 'cmp') of X.
%   These values can be used for WDENCMP.
%
%   For wavelet packets (four output arguments):
%   [THR,SORH,KEEPAPP,CRIT] = DDENCMP(IN1,'wp',X) 
%   returns default values for de-noising (if IN1 = 'den')
%   or compression (if IN1 = 'cmp') of X.
%   These values can be used for WPDENCMP.
%
%   See also WDENCMP, WENTROPY, WPDENCMP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.10.4.2 $

% Check arguments.
nbIn = nargin;
if nbIn<3
    error('Not enough input arguments.');
elseif isequal(worwp,'wv')
    if (nargout>3)
        error('Too many output arguments.');
    end
elseif isequal(worwp,'wp')
    if (nargout>4)
        error('Too many output arguments.');
    end
else
    error('Invalid argument value');
end


% Set problem dimension.
if min(size(x))~=1, dim = 2; else , dim = 1; end

% Set keepapp default value.
keepapp = 1;

% Set sorh default value.
if isequal(dorc,'den') & isequal(worwp,'wv') , sorh = 's'; else ,sorh = 'h'; end

% Set threshold default value.
n = prod(size(x));

% nominal threshold.
switch dorc
  case 'den'
    switch worwp
      case 'wv' , thr = sqrt(2*log(n));               % wavelets.
      case 'wp' , thr = sqrt(2*log(n*log(n)/log(2))); % wavelet packets.
    end

  case 'cmp' ,  thr = 1;
end

% rescaled threshold.
if dim == 1
    [c,l] = wavedec(x,1,'db1');
    c = c(l(1)+1:end);
else
    [c,l] = wavedec2(x,1,'db1');
    c = c(prod(l(1,:))+1:end);
end

normaliz = median(abs(c));

% if normaliz=0 in compression, kill the lowest coefs.
if dorc == 'cmp' & normaliz == 0 
    normaliz = 0.05*max(abs(c)); 
end

if dorc == 'den'
    if worwp == 'wv'
        thr = thr*normaliz/0.6745;
    else
        crit = 'sure';
    end
else
    thr = thr*normaliz;
    if worwp == 'wp', crit = 'threshold'; end
end
