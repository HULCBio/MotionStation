%function [basic,sol,cost,lambda,tnpiv,flopcnt] = mflinp(a,b,c,startbasic)
%
%  *****  UNTESTED  *****
%
% A simplex routine for linear programs arising in MAGFIT. MFLINP
%  is a modification of LINP that exploits some structure in MAGFIT
%  and tailors some of the constantswhile trying to avoid degeneracy
%  associated with the special structure of MAGFIT.
%
%  See Also: FITMAG, LINP, MAGFIT, MFLP and MFFIXBAS.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.4.5 $

function [basic,sol,cost,lambda,tnpiv,flopcnt] = mflinp(a,b,c,startbasic)

 if nargin < 4
   disp('usage: [basic,sol,cost,lambda] = mflinp(a,b,c,startbasic)')
   return
 end
 ws = warning('off','MATLAB:flops:UnavailableFunction');
 flopin = flops;tnpiv=0;piv=0;
 warning(ws);
 [con,var] = size(a);
 [nrb,ncb] = size(b);
 [nrc,ncc] = size(c);
 if con ~= nrb | var ~= ncc
   disp('error dimensioning')
   return
 end

%check conditioning of startbasic and change if necessary

startbasic=sort(startbasic); stdiff=diff(startbasic);
if  any([length(startbasic)~=con,stdiff==0,max(startbasic)>var]),
   [q2,r2,e2]=qr(a); for i=1:con, startbasic(i)=find(e2(:,i));end;
 else [q1,r1,e1]=qr(a(:,startbasic));
      [q2,r2,e2]=qr(a);
     if r1(con,con)<(1e-4)*r2(con,con),
       for i=1:con, startbasic(i)=find(e2(:,i));end;end
  end
 sol1=a(:,startbasic)\b;
 negind=find(sol1<0);
 p=length(negind);
 if p>0,posind=startbasic(comple(negind,con));
     else posind=startbasic(con);  end;%if p>0
 feasbasic=startbasic;
 cost1=-sum(sol1(negind));
 if p>0,   %find an initial basic feasible solution
   newstartbasic=[posind var+1:var+p];
   auga = [a -a(:,startbasic(negind))];
   augc = [2*cost1 zeros(1,var-1) ones(1,p)];
   [feasbasic,augsol,cost2,auglambda,piv,err] = mflp(auga,b,augc,newstartbasic);
   tnpiv=tnpiv+piv;
   if max(feasbasic)>var,
     augc(1,1)=0;
     [feasbasic,augsol,cost3,auglambda,piv,err] = mflp(auga,b,augc,feasbasic);
     tnpiv=tnpiv+piv;
     [feasbasic,err] = mffixbas(a,feasbasic,augsol,var,con);
     if err==1,  %problem with feasible solution so form degenerate one.
          feasbasic=sort(feasbasic);augsol=[1 ; zeros(con-1,1)];
          [feasbasic,err] = mffixbas(a,feasbasic,augsol,var,con);
      end %if err==1
    end %if max(feasbasic)>var
  end %if p>0

[basic,sol,cost,lambda,tnpiv,err] = mflp(a,b,c,feasbasic);
if err==1, cost=-1; end % this indicates that no solution tnpivmax was
                      %exceeded and MAGFIT gets no positive 'eps'.
tnpiv=tnpiv+piv;

ws = warning('off', 'MATLAB:flops:UnavailableFunction');
flopout = flops;
warning(ws);
flopcnt = flopout - flopin;
%
%