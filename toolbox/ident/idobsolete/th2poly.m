function [a,b,c,d,f,lam,T]=th2poly(th)
%TH2POLY computes the polynomials associated with a given model.
%   OBSOLETE function. Use POLYDATA instead.
%
%   [A,B,C,D,F,LAM,T]=TH2POLY(TH)
%
%   TH is the model with format described by (see also) THETA.
%
%   A,B,C,D, and F are returned as the corresponding polynomials
%   in the general input-output model. A, C and D are then row
%   vectors, while B and F have as many rows as there are inputs.
%   LAM is the variance of the noise source.
%   T is the sampling interval.
%   See also POLY2TH.

%   L. Ljung 10-1-86, 8-27-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/04/06 14:21:41 $

if nargin < 1
   disp('Usage: [A,B,C,D,F,NOISE_VARIANCE] = TH2POLY(TH)')
   return
end
[a,b,c,d,f] = polydata(th);
T = get(th,'Ts');
lam = get(th,'NoiseVariance');

