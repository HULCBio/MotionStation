% function [basic,sol,cost,lambda,tnpiv,flopcnt] = linp(a,b,c,startbasic)
%
%   Simplex algorithm for linear programs. The data is three
%   matrices A (mxn, m<=n), B (mx1), and C (1xn), and an optional
%   vector of integers, called STARTBASIC, corresponding to a
%   basic, feasible solution. If this variable is omitted, then
%   a basic solution is obtained via an auxiliary problem. the
%   outputs are:
%     BASIC   -  the indexes for the optimal basic solution
%     SOL     -  basic solution vector (size = m)
%     COST    -  the optimal cost
%     LAMBDA  -  the solution of the dual problem
%     TNPIV   -  total number of pivot operations
%     FLOPCNT -  flop count
%   
%   See also: MU.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

function [basic,sol,cost,lambda,tnpiv,flopcnt] = linp(a,b,c,startbasic)
 if nargin < 3
   disp('usage: [basic,sol,cost,lambda] = linp(a,b,c)')
   return
 end

 if ~exist('lp')
   error('I cannot find lp.m -- is the optimization toolbox installed?');
 end

 flopin = flops;
 if nargin == 3
   startbasic = 0;
 end
 [con,var] = size(a);
 [nrb,ncb] = size(b);
 [nrc,ncc] = size(c);
 if con ~= nrb | var ~= ncc  % b is COLUMN ,  c is ROW
   disp('error_in_LINP: error in dimensioning of A, B, C')
   return
 end
 if nargin == 3 | startbasic == 0
   swi = find(sign(b)<0);
   for i=1:length(swi)
     b(swi(i)) = -b(swi(i));
     a(swi(i),:) = -a(swi(i),:);
   end
   auga = [a eye(con)];
   augc = [zeros(1,var) ones(1,con)];
   augst = var+1:var+con;

   % This should thwart the compiler ;-)
   eval('[augbasic,augsol,cost] = lp(auga,b,augc,augst);');

   if cost < 1e-10
     [augbasic,err] = fmfixbas(augbasic,augsol,var,con);
     if err ~= 0
       error('error in finding feasible solution')
       return
     else
       eval('[basic,sol,cost,lambda,tnpiv] = lp(a,b,c,augbasic);');
     end
   else
     disp('NO FEASIBLE SOLUTION')
   end
 else
   eval('[basic,sol,cost,lambda,tnpiv] = lp(a,b,c,startbasic);');
 end
 flopout = flops;
 flopcnt = flopout - flopin;
   
