function [A,B,dA,dB]=th2arx(eta)
%TH2ARX converts a THETA-format model to an ARX-model.
%   OBSOLETE function. Use ARXDATA instead.
%
%   [A,B]=TH2ARX(TH)
%
%   TH: The model structure defined in the THETA-format (See also TEHTA.)
%
%   A, B : Matrices defining the ARX-structure:
%
%          y(t) + A1 y(t-1) + .. + An y(t-n) = 
%          = B0 u(t) + ..+ B1 u(t-1) + .. Bm u(t-m)
%
%          A = [I A1 A2 .. An],  B=[B0 B1 .. Bm]
%
%
%   With [A,B,dA,dB] = TH2ARX(TH), also the standard deviations
%   of A and B, i.e. dA and dB are computed.
%
%   See also ARX2TH, and ARX

%   L. Ljung 10-2-90,3-13-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/04/06 14:21:40 $

if nargin < 1
   disp('Usage: [A,B,dA,dB] = TH2ARX(TH)')
   return
end
[A,B,dA,dB] = arxdata(eta);
