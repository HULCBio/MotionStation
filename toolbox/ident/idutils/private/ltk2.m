function dec = ltk2(y,u,ecb,c,nc,ts,na,nb,nk,nobs,ei)
%LTK2  private function

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/10 23:20:19 $

[N,nu]=size(u);
yfb=filter(1,c,y(end-1:-1:ts-na));
for ku=1:nu
  % ufb(:,ku)=filter(1,c,u(end-nk(ku):-1:ts-nk(ku)-nb(ku)+1,ku));
end
efb=filter(1,c,[0;ecb(1:end-1)]);
yl=length(yfb);
%ul=size(ufb,1);

el=length(efb);
  
  ir=filter(1,c,[1;zeros(nobs+ts,1)]);
lky=zeros(na-1,na);
 for kk=1:na
    psi(:,na-kk+1)=yfb([yl-nc+1:yl]+1-kk);
  lky(kk:na-1,kk)=y(end-1:-1:end-na+kk);
  end
 
 jj=conv2(lky,ir(nobs-ts:nobs+ts-1));
% keyboard 
 if ~isempty(jj)
   psi(:,1:na)=psi(:,1:na)-jj(end-ts+3-nc:end-ts+2,end:-1:1);
 end
ss=na;lk=zeros(max(nb)-1,sum(nb));
revind=[];
for ku=1:nu
   ufb=filter(1,c,u(end-nk(ku):-1:ts-nk(ku)-nb(ku)+1+1,ku));
   ul=size(ufb,1);

   for kk=1:nb(ku)
      lk(kk:nb(ku)-1,ss-na+kk)=u(end-nk(ku):-1:end-nb(ku)+kk+1-nk(ku),ku);
      psi(:,ss+nb(ku)-kk+1)=-ufb([ul-nc+1:ul]-kk+1);
   end
   %disp('loop'),keyboard
   ss=ss+nb(ku);revind=[revind,ss-na:-1:ss-na-nb(ku)+1];
end
jj=conv2(lk,ir(nobs-ts:nobs+ts-1));
%keyboard
if ~isempty(jj)
      psi(:,na+1:na+sum(nb))=psi(:,na+1:na+sum(nb))+jj(end-ts+3-nc:end-ts+2,revind);
 end     %ss=na+nb;
   for kk=1:nc
      psi(:,ss+kk)=-efb([el-nc+1:el]+1-kk);
   end
    ll=conv2(c(end:-1:2),psi(end:-1:1,:)');
    dwc=ll(:,nc:-1:1); % 4 = vad
    if nc>0
         dwc(end-nc+1:end,:)=...
   toeplitz(ecb(end:-1:end-nc+1),[ecb(end),zeros(1,nc-1)])... 
   -hankel([ei(nc-1:-1:1),0])+dwc(end-nc+1:end,:); 
   dwc=dwc(:,nc:-1:1);
end
   dec=zeros(size(dwc));
   if ~isempty(dwc)
   for kk=1:na+sum(nb)+nc
      dec(kk,:)=filter(1,c,dwc(kk,:));
   end
end