function varargout = biorfilt(Df,Rf,in3)
%BIORFILT Biorthogonal wavelet filter set.
%   The BIORFILT command returns either four or eight filters
%   associated with biorthogonal wavelets.
%
%   [LO_D,HI_D,LO_R,HI_R] = BIORFILT(DF,RF) computes four
%   filters associated with biorthogonal wavelet specified
%   by decomposition filter DF and reconstruction filter RF.
%   These filters are:
%   LO_D  Decomposition low-pass filter
%   HI_D  Decomposition high-pass filter
%   LO_R  Reconstruction low-pass filter
%   HI_R  Reconstruction high-pass filter
%
%   [LO_D1,HI_D1,LO_R1,HI_R1,LO_D2,HI_D2,LO_R2,HI_R2] = 
%                       BIORFILT(DF,RF,'8')
%   returns eight filters, the first four associated with
%   the decomposition wavelet and the last four associated
%   with the reconstruction wavelet.
%
%   See also BIORWAVF, ORTHFILT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.10.4.2 $

% The filters must be of the same even length.
lr = length(Rf);
ld = length(Df);
lmax = max(lr,ld);
if rem(lmax,2) , lmax = lmax+1; end
Rf = [zeros(1,floor((lmax-lr)/2)) Rf zeros(1,ceil((lmax-lr)/2))];
Df = [zeros(1,floor((lmax-ld)/2)) Df zeros(1,ceil((lmax-ld)/2))];

[Lo_D1,Hi_D1,Lo_R1,Hi_R1] = orthfilt(Df);
[Lo_D2,Hi_D2,Lo_R2,Hi_R2] = orthfilt(Rf);
switch nargin
  case 2 ,  varargout = {Lo_D1,Hi_D2,Lo_R2,Hi_R1};
  case 3 ,  varargout = {Lo_D1,Hi_D1,Lo_R1,Hi_R1,Lo_D2,Hi_D2,Lo_R2,Hi_R2};
end
