function [A,B,dA,dB]=arxdata(M)
%ARXDATA returns the ARX-polynomials for a SISO IDPOLY model.
%
%   [A,B] = ARXDATA(M)
%
%   M: The IDPOLY model object. See help IDPOLY.
%
%   A, B : corresponding ARX polynomials
%
%   y(t) + A1 y(t-1) + .. + An y(t-n) = 
%          = B0 u(t) + ..+ B1 u(t-1) + .. + Bm u(t-m)
%
%   With [A,B,dA,dB] = ARXDATA(M), also the standard deviations
%   of A and B, i.e. dA and dB are computed.
%
%   See also IDARX, IDPOLY and ARX

%   L. Ljung 10-2-90,3-13-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/04/06 14:22:18 $

if nargin < 1
   disp('Usage: [A,B,dA,dB] = ARXDATA(M)')
   return
end

if M.nc + M.nd + M.nf ~= 0
  error('Model does not have an ARX structure.  Use POLYDATA instead.');
end
 
[A,B,c,d,f,dA,dB,dc,dd,df] = polydata(M);
 
