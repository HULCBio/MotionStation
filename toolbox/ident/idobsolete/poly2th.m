function th=poly2th(a,b,c,d,f,LAM,T,inhib)
%POLY2TH Constructs a "theta-matrix" from given polynomials.
%   OBSOLETE function. Use IDPOLY instead. See HELP IDPOLY.
%
%   TH = POLY2TH(A,B,C,D,F,LAM,T)
%
%   TH: returned as a matrix of the standard format, describing the model
%   A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
%   The exact format is given as in IDPOLY.
%
%   A,B,C,D and F are entered as the polynomials. A,C,D and F start with
%   1 , while B contains leading zeros to indicate the delay(s) for discr.
%   time models. For multi-input systems B and F are matrices with the
%   number of rows equal to the number of inputs. For a time series, B and
%   F are entered as []. POLY2TH is thus the inverse of (see also) TH2POLY.
%
%   LAM is the variance of the noise term e, and T is the sampling interval
%   T = 0 indicates a time-continuous model. Then the polynomials are 
%   entered in descending powers of s. Example: A=1,B=[1 2;0 3]
%   C=1;D=1;F=[1 0;0 1]; T=0 corresponds to the time-continuous system
%   Y = (s+2)/s U1 + 3 U2.
%
%   Trailing C,D,F, LAM, and T can be omitted, in which case they are
%   taken as 1's (if B=[], then F=[]).
%   See also IDINPUT, IDSIM, TH2POLY.

%   L. Ljung 10-1-86
%   Revised 4-21-91,9-9-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $ $Date: 2004/04/10 23:20:09 $

if nargin<2,
   disp('Usage: TH = POLY2TH(A,B)')
   disp('       TH = POLY2TH(A,B,C,D,F,LAM,T)')
   return
end
[nu,nb1]=size(b); nu=nu(1);
if nargin<8,inhib=0;end
if nargin<7, T=[];end
if nargin<6, LAM=[];end
if nargin<5, f=[];end
if nargin<4, d=[];end
if nargin<3, c=[];end

if isempty(a), a=1;end
if isempty(c),c=1;end
if isempty(d),d=1;end
if isempty(f)&~isempty(b),f=ones(nu,1);end
if isempty(T),T=1;end
if isempty(LAM),LAM=1;end

th = idpoly(a,b,c,d,f,'Ts',T,'NoiseVariance',LAM);
