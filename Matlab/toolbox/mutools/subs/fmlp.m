% [basic,sol,cost,lambda,tnpiv] = fmlp(a,b,c,startbasic,tnpivmax)
%
%  *****  UNTESTED SUBROUTINE  *****

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [basic,sol,cost,lambda,tnpiv] = fmlp(a,b,c,startbasic,tnpivmax)

tnpiv = 0;
[ncon,nvar] = size(a);
if nargin<5, tnpivmax=500;end
basic = startbasic;
nonbasic = comple(basic,nvar);
go = 1;
tnpiv = 0;
while go == 1
  lambda = c(basic)/a(:,basic);
  sol = a(:,basic) \ b;
  cc = c(nonbasic) - lambda*a(:,nonbasic);
  desdir = find(cc<-0.00000000001);
  if length(desdir) == 0
    go = 0;
    opt = basic;
    optsol = sol;
  else
   [tmp,indx]=sort(cc(desdir));desdir=desdir(indx);
   if rand<.9 | length(desdir)==1, desdirn=desdir(1);
      else desdirn=desdir(2);end
   to_enter = nonbasic(desdirn);
   a_to_enter = a(:,nonbasic(desdirn));
   alinvar = a(:,basic) \ a_to_enter;
   avail_piv = find(alinvar>0.0000001);
   if length(avail_piv) == 0, avail_piv = find(alinvar>0.0); end
   if length(avail_piv) == 0,
     disp('unbounded')
     opt = basic;
     optsol = -inf;
     go = 0;
   else
     rat = sol(avail_piv)./alinvar(avail_piv);
     pivots = find(rat==min(rat));
     to_leave = basic(avail_piv(pivots(1)));
     basic(avail_piv(pivots(1))) = to_enter;
     nonbasic(desdirn) = to_leave;
     tnpiv = tnpiv + 1;
   end
  end
  if tnpiv>=tnpivmax-1, opt = basic;
     optsol = -1;  %this denotes no feasible solution to the
                   %primal problem fitmaglp.
     go = 0;end

end
cost = c(basic)*sol;
%
%