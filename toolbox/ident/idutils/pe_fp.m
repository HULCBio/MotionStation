function [e,xi]=pe_fp(ze,m,init)%a,b,c,d,f,Y,U,w,OM,wf,T,cdindic)
%function [V,lam,e1]=vlpem(a,b,c,d,f,Y,U,w,OM,wf,T,cdindic)
%if nargin<12,cdindic=0;end

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:18:45 $

%%LL Check what is returned
if nargin<3
    init = [];
end
xi =[];
if isempty(init)
    if isa(m,'idarx')
        init='z';
    else
        init=get(m,'InitialState');
    end
    init=lower(init(1));
    
    if init=='a'|init=='b',
        init='e';
    elseif init=='f'|init=='n'
        init = 'm';   
    end
elseif ischar(init)
    init=lower(init(1));
    if ~any(strcmp(init,{'m','z','e'}))
        error('Init must be one of ''E(stimate)'', ''Z(ero)'', ''M(odel)'' or a vector.')
    end
    
end
if init=='e'|init=='oe'
    m = pvset(m,'CovarianceMatrix',[]);
    m = idss(m);
    [e,xi]=pe_f(ze,m,'e');
    return
end
a = pvget(m,'a'); b = pvget(m,'b'); c = pvget(m,'c'); d = pvget(m,'d'); f = pvget(m,'f');
%% Ne = 1 %%
if iscell(ze)
    ze = ze{1};
end
if isa(ze,'iddata')
    ze=[ze.fre,ze.y,ze.u]; %LL fix
end
w = ze(:,1); Y = ze(:,2); U = ze(:,3:end);
na = pvget(m,'na');nf = pvget(m,'nf');nk = pvget(m,'nk');nc = pvget(m,'nc');nd = pvget(m,'nd');
nb = pvget(m,'nb'); T = pvget(m,'Ts');
i=sqrt(-1);nm=max([na+nf,nb+nk-1,nc,nd+na]);
if T>0,OM=exp(-i*[0:nm]'*w'*T);
else OM=ones(1,length(w));
     for kom=1:nm
         OM=[OM;(i*w').^kom];
     end
end


na=length(a)-1;[nu,nb]=size(b);[nu,nf]=size(f);
if T>0
   inda=1:na+1;indb=1:nb;indf=1:nf;
else
   inda=na+1:-1:1;indb=nb:-1:1;indf=nf:-1:1;
end
nm=max(na,nb);

gffr=length(w);
a1=fstab(a,1);
A=a*OM(inda,:);
A1=a1*OM(1:na+1,:);
GC=zeros(gffr,1);
for ku=1:nu
	GC=GC+(((b(ku,:)*OM(indb,:))./(f(ku,:)*OM(indf,:))).').*U(:,ku);
end 
e=-(GC-Y.*(A.'));%e=e1.*wf;
return
%%LL iddata etc
nd=length(d)-1;nc=length(c)-1;
nm=max(nd,nc);
if T>0
  CO=cos([0:nm]'*w'*T);
else
  CO=ones(1,length(w));
     for kom=1:nm
         CO=[CO;(-w'.^2).^kom];
     end
end
if cdindic
   if T>0 indd=1:nd+1;indc=1:nc+1;else indd=nd+1:-1:1;indc=nc+1:-1:1;end
   D=abs(d*OM(indd,:)).^2;
   C=abs(c*OM(indc,:)).^2;
else
   D=d*CO(1:nd+1,:);C=c*CO(1:nc+1,:);
end
if cdindic==0
if T>0
   dpol=[d(length(d):-1:2) 2*d(1) d(2:length(d))]; %%% Fix for T==0
   cpol=[c(length(c):-1:2) 2*c(1) c(2:length(c))];
   if any(abs(abs(roots(dpol))-1)<0.0001)|...
      any(abs(abs(roots(cpol))-1)<0.0001)
      V=100000000;
      return  
   end
else
   cc=zeros(1,2*nc+1);
   dd=zeros(1,2*nd+1);
   cc(1:2:2*nc+1)=c; cr=roots(cc(length(cc):-1:1));
   dd(1:2:2*nd+1)=d; dr=roots(dd(length(dd):-1:1));
   if any(abs(real(cr))<0.00001)|...
      any(abs(real(dr))<0.00001)
      V=10000000000;
      return
   end
end
end % if cdindic

vv1=((D).'./(C).').*abs(e).^2;vv2=-log(D.')+log(C.')-log(abs(A1).^2).';
lam=sum(vv1)/length(w);
V=length(w)*log(sum(vv1))+sum(vv2);
