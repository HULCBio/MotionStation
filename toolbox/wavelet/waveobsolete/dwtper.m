function [a,d] = dwtper(x,varargin)
%DWTPER Single-level discrete 1-D wavelet transform (periodized).
%   [CA,CD] = DWTPER(X,'wname') computes the approximation
%   coefficients vector CA and detail coefficients vector CD,
%   obtained by periodized wavelet decomposition of the 
%   vector X.
%   'wname' is a string containing the wavelet name
%   (see WFILTERS).
%
%   Instead of giving the wavelet name, you can give
%   the filters. When used with three arguments: 
%   [CA,CD] = DWTPER(X,Lo_D,Hi_D),
%   Lo_D is the decomposition low-pass filter and
%   Hi_D is the decomposition high-pass filter.
%
%   If lx = length(X) then
%       length(CA) = length(CD) = CEIL(lx/2).
%
%   See also DWT, IDWTPER.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 07-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $

% Check arguments.
if errargn(mfilename,nargin,[2:3],nargout,[0:2]), error('*'), end
if nargin == 2
    [Lo_D,Hi_D] = wfilters(varargin{1},'d');
else
    Lo_D = varargin{1}; Hi_D = varargin{2};
end

% Periodization.
lx = length(x);
lf = length(Lo_D);
if rem(lx,2) , x(lx+1) = x(lx); lx = lx+1; end
I = [lx-lf+1:lx , 1:lx , 1:lf];
if lx<lf
    I = mod(I,lx);
    I(I==0) = lx;
end
x = x(I);

% Decomposition.
lp = ceil(lx/2);
a  = wkeep1(dyaddown(conv(x,Lo_D)),lp);
d  = wkeep1(dyaddown(conv(x,Hi_D)),lp);