function K=pdeasmc(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,g1x,g1y,g2x,g2y,g3x,g3y,c)
%PDEASMC Assemble the C coefficient.

%       A. Nordmark 12-19-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.1 $  $Date: 2003/11/01 04:28:06 $

nrc=size(c,1);

if nrc==1,
  cc1=pdetexpd(x,y,sd,u,ux,uy,time,c(1,:));
  c3=((cc1.*(g1x.*g2x+g1y.*g2y)).*ar);
  c1=((cc1.*(g2x.*g3x+g2y.*g3y)).*ar);
  c2=((cc1.*(g3x.*g1x+g3y.*g1y)).*ar);
elseif nrc==2,
  cc1=pdetexpd(x,y,sd,u,ux,uy,time,c(1,:));
  cc2=pdetexpd(x,y,sd,u,ux,uy,time,c(2,:));
  c3=((cc1.*g1x.*g2x+cc2.*g1y.*g2y).*ar);
  c1=((cc1.*g2x.*g3x+cc2.*g2y.*g3y).*ar);
  c2=((cc1.*g3x.*g1x+cc2.*g3y.*g1y).*ar);
elseif nrc==3,
  cc1=pdetexpd(x,y,sd,u,ux,uy,time,c(1,:));
  cc2=pdetexpd(x,y,sd,u,ux,uy,time,c(2,:));
  cc3=pdetexpd(x,y,sd,u,ux,uy,time,c(3,:));
  c3=((cc1.*g1x.*g2x+cc2.*(g1x.*g2y+g1y.*g2x)+cc3.*g1y.*g2y).*ar);
  c1=((cc1.*g2x.*g3x+cc2.*(g2x.*g3y+g2y.*g3x)+cc3.*g2y.*g3y).*ar);
  c2=((cc1.*g3x.*g1x+cc2.*(g3x.*g1y+g3y.*g1x)+cc3.*g3y.*g1y).*ar);
elseif nrc==4,
  cc1=pdetexpd(x,y,sd,u,ux,uy,time,c(1,:));
  cc2=pdetexpd(x,y,sd,u,ux,uy,time,c(2,:));
  cc3=pdetexpd(x,y,sd,u,ux,uy,time,c(3,:));
  cc4=pdetexpd(x,y,sd,u,ux,uy,time,c(4,:));
  c12=((cc1.*g1x.*g2x+cc2.*g1y.*g2x+cc3.*g1x.*g2y+cc4.*g1y.*g2y).*ar);
  c23=((cc1.*g2x.*g3x+cc2.*g2y.*g3x+cc3.*g2x.*g3y+cc4.*g2y.*g3y).*ar);
  c31=((cc1.*g3x.*g1x+cc2.*g3y.*g1x+cc3.*g3x.*g1y+cc4.*g3y.*g1y).*ar);
  c21=((cc1.*g2x.*g1x+cc2.*g2y.*g1x+cc3.*g2x.*g1y+cc4.*g2y.*g1y).*ar);
  c32=((cc1.*g3x.*g2x+cc2.*g3y.*g2x+cc3.*g3x.*g2y+cc4.*g3y.*g2y).*ar);
  c13=((cc1.*g1x.*g3x+cc2.*g1y.*g3x+cc3.*g1x.*g3y+cc4.*g1y.*g3y).*ar);
else
  error('PDE:pdeasmc:SizeC', 'c must have 1, 2, 3 or 4 rows.');
end

if nrc<4,
  K=sparse(it1,it2,c3,np,np);
  K=K+sparse(it2,it3,c1,np,np);
  K=K+sparse(it3,it1,c2,np,np);
  K=K+K.';
  K=K+sparse(it1,it1,-c2-c3,np,np);
  K=K+sparse(it2,it2,-c3-c1,np,np);
  K=K+sparse(it3,it3,-c1-c2,np,np);
else
  K=sparse(it1,it2,c12,np,np);
  K=K+sparse(it2,it3,c23,np,np);
  K=K+sparse(it3,it1,c31,np,np);
  K=K+sparse(it2,it1,c21,np,np);
  K=K+sparse(it3,it2,c32,np,np);
  K=K+sparse(it1,it3,c13,np,np);
  K=K+sparse(it1,it1,-c12-c13,np,np);
  K=K+sparse(it2,it2,-c23-c21,np,np);
  K=K+sparse(it3,it3,-c31-c32,np,np);
end

