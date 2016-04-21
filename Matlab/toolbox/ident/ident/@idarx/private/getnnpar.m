function [par,nna,nnb,nnk,ny,nu,status] = getnnpar(A1,B1)
%GETNNPAR  private function

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2004/04/10 23:16:11 $

status = [];
nnb=[];nnk=[];
[ny] = size(A1,1);
if nargin>1
   nu = size(B1,2);
else
   nu=0;
end

A=[]; B=[];
for k=1:size(A1,3)
   A=[A,A1(:,:,k)];
end
if nargin>1
   for k=1:size(B1,3);
      B=[B,B1(:,:,k)];
   end
end

[ra,ca]=size(A);
if isempty(B),
   rb=ra;nu=0;
else 
   [rb,cb,nb]=size(B);
end
na=(ca-ny)/ny; 
if nu>0,
   nb=(cb-nu)/nu;
else 
   nb=0;rb=ny;
end
if ra~=ny | rb~=ny, 
   error('The A and the B polynomials must have the same number of rows as the number of outputs!'),
end
if floor(na)~=na | floor(nb)~=nb,
   error(sprintf(['The size of A or B is not consistent with an ARX-model.',...
         '\nThe number of columns must be a multiple of the number of rows.']))
end
for outp=1:ny
   for kk=1:ny
      sl=A(outp,ny+kk:ny:na*ny+ny);
      sl=(sl~=0);sl=sl(length(sl):-1:1);
      sl=cumsum(sl);ksl=max(find(sl==0));
      if length(ksl)==0,ksl=0;end
      
      nna(outp,kk)=na-ksl;
   end
   for kk=1:nu
      sl=B(outp,kk:nu:nb*nu+nu);
      sl1=(sl~=0);ksl=max(find(cumsum(sl1)==0));
      if length(ksl)==0,ksl=0;end
      nnk(outp,kk)=ksl;
      sl1=sl1(length(sl1):-1:1);sl=cumsum(sl1);
      ksl=max(find(sl==0));
      if length(ksl)==0,ksl=0;end
      if ksl==nb+1,
         nnb(outp,kk)=0;nnk(outp,kk)=0;
      else
         nnb(outp,kk)=nb-ksl-nnk(outp,kk)+1;
      end
   end
end

nn=[nna nnb nnk];
%nd=sum(sum(nna)')+sum(sum(nnb)');
%eta0=mketaarx(nn,ones(1,nd));

ms = getarxms(nna,nnb,nnk);
nx=size(ms.As,1);
if na>0 
   A1 = [eye(ny) ms.As(1:ny,1:na*ny)];
   if nu >0
      B1 = [ms.Bs(1:ny,:) ms.As(1:ny,na*ny+1:nx)];
   else
      B1 = [];
      
   end
else
   
   if ~any(isnan(ms.Cs))
      B1 = ms.Ds;
   else
      B1 = [ms.Ds(1:ny,:) ms.Cs(1:ny,na*ny+1:nx)];
   end
end


%[A1,B1]= %th2arx(eta0);
[ra,ca]=size(A1);
[rb,cb]=size(B1);
A1=A1(:,ny+1:ca);
Am=A(:,ny+1:ca);
B2=B1(:,nu+1:cb);Bm=B(:,nu+1:cb);
C=[A1 B2];
par=[];
for kk=1:ny
   if ~isempty(Am),filla=-Am(kk,find(isnan(A1(kk,:))));else filla=[];end
   if ~isempty(Bm),fillb=Bm(kk,find(isnan(B2(kk,:))));else fillb=[];end
   par=[par filla fillb];
end

for kk=1:ny
    try
   if nu>0,par=[par B(kk,find(isnan(B1(kk,1:nu))))];end
end
end
par = par.';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 