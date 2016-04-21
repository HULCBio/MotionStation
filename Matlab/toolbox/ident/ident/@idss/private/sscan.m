function [parmat,ms] = sscan(parm,StructureIndices,InputDelay,noise,init)
%SSCAN  private function

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $ $Date: 2004/04/10 23:18:11 $
 
 a=parm.a;b=parm.b;c=parm.c;d=parm.d;k=parm.k;x0=parm.x0;
 [n,dum]=size(a);
 [dum,nu]=size(b);[ny,dum]=size(c);
 if nu>0
    if any(InputDelay~=fix(InputDelay))|any(InputDelay<0)
       error(['The delays must be non-negative integers.'])
    end
    if any(InputDelay==0),dkx(1)=1;else dkx(1)=0;end
 end
 if strcmp(noise,'Estimate'),dkx(2)=1;else dkx(2)=0;end
 if strcmp(init,'Estimate'),dkx(3)=1;else dkx(3)=0;end
 dkx=[dkx,InputDelay];
 if isempty(StructureIndices)|ischar(StructureIndices)
    StructureIndices = [];
    if ny>n
       [u1,d1,v1] = svd(c);
       bestcon = inf;
       rmbest = [1:n];
       stat = rand('state');
       rand('state',0);
       for k1=1:100
          if k1 == 1
             rm1 = [1:n];
          else
             rm = rand(ny,1);
             rmm = sort(rm);
             rm1 = rm<rmm(n+1);
          end
          con = cond(u1(rm1,1:n));
          if con < bestcon
             rmbest = rm1;
             bestcon = con;
          end
          if con < 100
             break
          end
       end
       rand('state',stat);
       StructureIndices=zeros(1,ny);
       StructureIndices(rm1)=ones(1,n);                                      
    else  
       ind1=floor(n/ny);
       for kc=1:ny-1
          StructureIndices(kc)=ind1;
       end
       if ny>1
          StructureIndices(ny)=n-sum(StructureIndices);
       else
          StructureIndices=n;
       end
    end   
 end
 np=sum(StructureIndices);
 if any(StructureIndices<0)
    error('The CanonicalIndices must be non-negative.')
 end
 if length(StructureIndices)~=ny,
    error('The number of the CanonicalIndices must be equal to the number of outputs.')
 end
 if np~=n,
    error(sprintf('The sum of the CanonicalIndices must equal the model order %d.',n))
 end
 
 psz=find(StructureIndices==0);
 r=cumsum(StructureIndices);
 o1=zeros(n,n);
 rown=[];kc=1;
 for ky=1:ny
    for koi=0:StructureIndices(ky)-1
       rown=[rown,koi*ny+ky];
       if ky==1,rr=0;else rr=r(ky-1);end
       o1(kc,rr+1+koi)=1;
       kc=kc+1;
    end
 end
 o2=zeros(n*ny,n);
 for jk = 1:ny
    xx = ltitr(a.',zeros(n,1),zeros(n,1),c(jk,:).');
    o2(jk:ny:ny*(n-1)+jk,:) = xx;
 end
 o2=o2(rown,:);
 if cond(o2)>1/eps
     warning(sprintf(['The transformation to canonical form is illcondiioned.',...
         '\nExpect problems.']))
end
 if min(svd(o1))<100*eps|min(svd(o2))<100*eps
    error(sprintf([' The transformation to canonical form failed.',...
          '\n The reason is probably that outputs are colinear.']))
    end
 T=pinv(o2)*o1;
 Ti=pinv(o1)*o2;
 ac=Ti*a*T;bc=Ti*b;kc=Ti*k;cc=c*T;x0=Ti*x0;
 ms=canform(StructureIndices,nu,dkx);
   
    parmat.a=ac;parmat.b=bc;parmat.c=cc;
 parmat.d=d;
 parmat.k=kc;
 
 parmat.x0=x0;
 
  