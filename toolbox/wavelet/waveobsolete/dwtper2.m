function [a,h,v,d] = dwtper2(x,varargin)
%DWTPER2  Single-level discrete 2-D wavelet transform (periodized).
%   [CA,CH,CV,CD] = DWTPER2(X,'wname') computes the approximation
%   coefficients matrix CA and details coefficients matrices 
%   CH, CV, CD, obtained by periodized wavelet decomposition 
%   of the input matrix X.
%   'wname' is a string containing the wavelet name
%   (see WFILTERS).
%
%   Instead of giving the wavelet name, you can give
%   the filters. When used with three arguments: 
%   [CA,CH,CV,CD] = DWTPER2(X,Lo_D,Hi_D),
%   Lo_D is the decomposition low-pass filter and
%   Hi_D is the decomposition high-pass filter.
%
%   If sx = size(X) then
%      size(CA) = size(CH) = size(CV) = size(CD) = CEIL(sx/2).
%
%   See also DWT2, IDWTPER2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 07-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.12.4.2 $

% Check arguments.
if errargn(mfilename,nargin,[2 3],nargout,[0,1,4]), error('*'), end
if nargin==2
    [Lo_D,Hi_D] = wfilters(varargin{1},'d');
else
    Lo_D = varargin{1}; Hi_D = varargin{2};
end

% Periodization.
sx = size(x); rx = sx(1); cx = sx(2);
lf = length(Lo_D);

if rem(rx,2) , x(rx+1,:) = x(rx,:); rx = rx+1; end
I = [rx-lf+1:rx , 1:rx , 1:lf];
if rx<lf
    I = mod(I,rx);
    I(I==0) = rx;
end
x = x(I,:);

if rem(cx,2) , x(:,cx+1) = x(:,cx); cx = cx+1; end
I = [cx-lf+1:cx , 1:cx , 1:lf];
if cx<lf
    I = mod(I,cx);
    I(I==0) = cx;
end
x = x(:,I);

% Decomposition.
sp = ceil(sx/2);
y = dyaddown(conv2(x,Lo_D),'c');
a = wkeep2(dyaddown(conv2(y,Lo_D'),'r'),sp);
h = wkeep2(dyaddown(conv2(y,Hi_D'),'r'),sp);

y = dyaddown(conv2(x,Hi_D),'c');
v = wkeep2(dyaddown(conv2(y,Lo_D'),'r'),sp);
d = wkeep2(dyaddown(conv2(y,Hi_D'),'r'),sp);