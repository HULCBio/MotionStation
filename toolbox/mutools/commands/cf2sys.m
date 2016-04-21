% function sysout=cf2sys(sysrcf)
%
% Creates a SYSTEM/CONSTANT/VARYING matrix from a
%  coprime factorization.
%
% See Also: NCFSYN

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function sysout=cf2sys(syscf)

[type,p,m,n]=minfo(syscf);
if  p==m,
   error('input not a coprime factor system')
   return
 end
if type=='syst'
[a,b,c,d]=unpck(syscf);
 if p>m,
   pout=p-m;
   d1=d(1:pout,:);
   d2=d(pout+1:p,:);
   c2=c(pout+1:p,:);
   aout=a-b*(d2\c2);
   bout=b/d2;
   cout=[eye(pout) -d1/d2]*c;
   dout=d1/d2;
   sysout=pck(aout,bout,cout,dout);
  else
   mout=m-p;
   d1=d(:,1:mout);
   d2=d(:,mout+1:m);
   b2=b(:,mout+1:m);
   aout=a-(b2/d2)*c;
   bout=b*[eye(mout); -d2\d1];
   cout=d2\c;
   dout=d2\d1;
   sysout=pck(aout,bout,cout,dout);
 end
end

if type=='cons'
  if p>m,
    pout=p-m;
    d1=syscf(1:pout,:);
    d2=syscf(pout+1:p,:);
    sysout=d1/d2;
   end; % if p>m
  if m>p,
    mout=m-p;
    d1=syscf(:,1:mout);
    d2=syscf(:,mout+1:m);
    sysout=d2\d1;
   end; % if m>p
  end; % if type=='cons'

if type=='vary',
   if p>m,
     pout=p-m;
     sysout=mmult(sel(syscf,1:pout,1:m),vinv(sel(syscf,pout+1:p,1:m)));
    end; % if p>m
   if m>p,
     mout=m-p;
     sysout=mmult(vinv(sel(syscf,1:p,mout+1:m)),sel(syscf,1:p,1:mout));
    end; % if m>p
  end; % if type=='vary'
%
%