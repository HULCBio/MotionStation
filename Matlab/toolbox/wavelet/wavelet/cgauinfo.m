function cgauinfo
%CGAUINFO Information on complex Gaussian wavelets.
%
%   Complex Gaussian Wavelets.
%
%   Definition: derivatives of the complex Gaussian 
%   function
%
%   cgau(x) = Cn * diff(exp(-i*x)*exp(-x^2),n) where diff denotes
%   the symbolic derivative and where Cn is a constant
%
%   Family                  Complex Gaussian
%   Short name              cgau
%
%   Wavelet name            cgau"n"
%
%   Orthogonal              no
%   Biorthogonal            no
%   Compact support         no
%   DWT                     no
%   Complex CWT             possible
%
%   Support width           infinite
%   Symmetry                yes
%                       n even ==> Symmetry
%                       n odd  ==> Anti-Symmetry

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jul-99.
%   Last Revision: 05-Jul-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 19:47:19 $
