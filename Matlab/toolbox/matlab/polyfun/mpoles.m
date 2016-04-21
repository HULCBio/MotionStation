function [mults, indx] = mpoles( p, mpoles_tol, reorder )
%MPOLES Identify repeated poles & their multiplicities.
%     [MULTS, IDX] = mpoles(P,TOL)
%        P:     the list of poles
%        TOL:   tolerance for checking when two poles
%                 are the "same" (default=1.0e-03)
%        REORDER: Sort the poles?  0=don't sort, 1=sort (default)
%        MULTS: list of pole multiplicities
%        IDX:   indices used to sort P
%     NOTE: this is a support function for RESIDUEZ.
%
%   Example:
%       input:  P = [1 3 1 2 1 2]
%       output: [MULTS, IDX] = mpoles(P)
%                   MULTS' = [1 1 2 1 2 3], IDX' = [2 4 6 1 3 5]
%                   P(IDX) = [3 2 2 1 1 1]
%       Thus, MULTS contains the exponent for each pole in a
%       partial fraction expansion.
%
%       There are times when the poles shouldn't be sorted in descending order,
%       such as when the poles correspond to given residuals from RESIDUEZ.  
%       In that case, set REORDER=0.  For example:
%       input:  P = [1 3 1 2 1 2]
%       output: [MULTS, IDX] = mpoles(P,[],0)
%                   MULTS' = [1 2 3 1 1 2], IDX' = [1 3 5 2 4 6]
%                   P(IDX) = [1 1 1 3 2 2]
%
%   Class support for input P:
%      float: double, single

%   Copyright 1984-2004 The MathWorks, Inc.
%       $Revision: 1.6.4.1 $  $Date: 2004/03/02 21:47:51 $

if nargin<2, mpoles_tol=[]; end
if nargin<3, reorder=[]; end
if isempty(mpoles_tol), mpoles_tol = 1.0e-03; end
if isempty(reorder), reorder=1; end

Lp = length(p);
if reorder 
   [pmag,indp] = sort(-abs(p(:))); %--work largest to smallest
   p = p(indp);
else
   indp=1:Lp;
end
   
mults = zeros(Lp,1,class(p));
indx = zeros(Lp,1);
ii = 1;
while Lp>1
   test = abs( p(1) - p );
   if abs(p)>0
       jkl = find( test < mpoles_tol*abs(p(1)) );
   else
       jkl = find( test < mpoles_tol );
   end
   kk = 0:length(jkl)-1;
   mults(ii+kk) = kk+1;
   done = jkl;
   indx(ii+kk) = indp( done );
   indp(done) = [];
   p(done) = [];
   Lp = length(p);
   ii = ii+length(done);
end
if Lp==1
   indx(ii) = indp(1);
   mults(ii) = 1;
end

