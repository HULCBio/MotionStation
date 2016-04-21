function x = idwtper2(a,h,v,d,varargin)
%IDWTPER2 Single-level inverse discrete 2-D wavelet transform (periodized).
%   X = IDWTPER2(CA,CH,CV,CD,'wname') returns the single-level
%   reconstructed approximation coefficients matrix X based on
%   approximation and details matrices CA, CH, CV and CD at a 
%   given level, using the periodized inverse wavelet transform.
%   'wname' is a string containing the wavelet name (see WFILTERS).
%
%   Instead of giving the wavelet name, you can give the filters.
%   For X = IDWTPER2(CA,CH,CV,CD,Lo_R,Hi_R), 
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter
%
%   If sa = size(CA) = size(CH) = size(CV) = size(CD) then
%   size(X) = 2*sa.
%
%   For X = IDWTPER2(CA,CH,CV,CD,'wname',S) or
%   X = IDWTPER2(CA,CH,CV,CD,Lo_R,Hi_R,S), S is the size of
%   the result.
%
%   See also DWTPER2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 02-Aug-2000.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.13.4.2 $

% Check arguments.
if errargn(mfilename,nargin,[5:7],nargout,[0 1]), error('*'), end
sa = size(a);
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r');
    if nargin==6, sx = varargin{2}; else, sx = 2*sa; end
else
    Lo_R = varargin{1}; Hi_R = varargin{2};
    if nargin==7, sx = varargin{3}; else, sx = 2*sa; end
end

% Reconstruction.
lf = length(Lo_R);
lm = floor((lf-1)/2)/2;
la = sa(1);
I  = [la-floor(lm)+1:la , 1:la , 1:ceil(lm)];
if lf>2*la
    I  = mod(I,la);
    I(I==0) = la;
end
a = a(I,:); h = h(I,:); v = v(I,:); d = d(I,:);

la = sa(2);
I  = [la-floor(lm)+1:la , 1:la , 1:ceil(lm)];
if lf>2*la
    I  = mod(I,la);
    I(I==0) = la;
end
a = a(:,I); h = h(:,I); v = v(:,I); d = d(:,I);

t0 = conv2(dyadup(a,'r'),Lo_R') + conv2(dyadup(h,'r'),Hi_R');
clear a h
d0 = conv2(dyadup(v,'r'),Lo_R') + conv2(dyadup(d,'r'),Hi_R');
clear v d
x  = conv2(dyadup(t0,'c'),Lo_R) + conv2(dyadup(d0,'c'),Hi_R);
x  = wkeep2(x,sx);
