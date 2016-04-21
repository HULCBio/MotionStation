function x = idwtper(a,d,varargin)
%IDWTPER Single-level inverse discrete 1-D wavelet transform (periodized).
%   X = IDWTPER(CA,CD,'wname') returns the single-level
%   reconstructed approximation coefficients vector X
%   based on approximation and detail vectors CA and CD
%   at a given level, using the periodized inverse wavelet
%   transform.
%   'wname' is a string containing the wavelet name (see WFILTERS).
%
%   Instead of giving the wavelet name, you can give the filters.
%   For X = IDWTPER(CA,CD,Lo_R,Hi_R),
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter
%
%   If la = length(CA) = length(CD) then length(X) = 2*la.
%
%   For X = IDWTPER(CA,CD,'wname',L) or 
%   X = IDWTPER(CA,CD,Lo_R,Hi_R,L), L is the length of
%   the result.
%
%   See also DWTPER.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 07-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.13.4.2 $

% Check arguments.
if errargn(mfilename,nargin,[3:5],nargout,[0:1]), error('*'), end

la = length(a);
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r');
    if nargin==4 , lx = varargin{2}; else , lx = 2*la; end
else
    Lo_R = varargin{1}; Hi_R = varargin{2};
    if nargin==5 , lx = varargin{3}; else , lx = 2*la; end
end

% Reconstruction.
lf = length(Lo_R);
lm = floor((lf-1)/2)/2;
I  = [la-floor(lm)+1:la , 1:la , 1:ceil(lm)];
if lf>2*la
    I  = mod(I,la);
    I(I==0) = la;
end
a = a(I);
d = d(I);
x = conv(dyadup(a),Lo_R)+conv(dyadup(d),Hi_R);
x = wkeep1(x,lx);