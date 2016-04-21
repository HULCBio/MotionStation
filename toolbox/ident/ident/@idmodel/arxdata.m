function [A,B,dA,dB]=arxdata(sys)
%ARXDATA returns the ARX-polynomials for a multivariable IDARX model.
%
%   [A,B] = ARXDATA(M)
%
%   M: The IDARX model object. See help IDARX.
%
%   A, B : ny-by-ny-by-n and ny-b-ynu-by-m matrices defining 
%   the ARX-structure. (ny: number of outputs, nu: number of inputs)
%
%   y(t) + A1 y(t-1) + .. + An y(t-n) = 
%          = B0 u(t) + ..+ B1 u(t-1) + .. + Bm u(t-m)
%
%          A(:,:,k+1) = Ak,  B(:,:,k+1) = Bk
%
%
%   With [A,B,dA,dB] = ARXDATA(M), also the standard deviations
%   of A and B, i.e. dA and dB are computed.
%
%   See also IDARX, and ARX

%   L. Ljung 10-2-90,3-13-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:22:13 $

error(sprintf([' ARXDATA only applies to IDARX models and',...
	       '\n IDPOLY models with nf = nc = nd = 0']))

 