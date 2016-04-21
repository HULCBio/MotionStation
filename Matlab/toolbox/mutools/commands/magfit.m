% function [sys,fit,extracons] = magfit(vmagdata,dim,wt)
%
%  MAGFIT fits a stable, minimum phase transfer function
%  to magnitude data, VMAGDATA, with a supplied frequency
%  domain weighting function, WT. VMAGDATA is a VARYING
%  matrix giving the magnitude and frequency points to be
%  matched,
%
%     [mag,rowpoint,omega,err] = vunpck(vmagdata).
%
%  DIM is a 1 by 4 vector with dim= [hmax,htol,nmin,nmax].
%  The output system, SYS, is a stable minimum phase SISO
%  system that satisfies:
%
%             1/(1+ h/W) < g^2/mag^2 < 1+ h/W
%
%  where g is the magnitude of the frequency response of SYS
%  for frequencies omega, [W,rowpoint,omega,err] = vunpck(WT).
%  The degree of SYS is N, where 0<=NMIN<=N<=NMAX is the minimum
%  degree to meet the specification with H<=HMAX. If no such n
%  exists then N=NMAX. The value of H is approximately minimized
%  between upper and lower bounds terminating when
%  hupper-hlower<=HTOL. FIT is the achieved value of H.
%
% See Also: FITMAG, FITMAGLP, MUSYNFIT, and MUSYNFLP.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $


% The method used is note that g^2 is the ratio of
% polynomials in omega^2 ,  g^2=p/q, with p and q having no
% positive real roots.  A scaled version of the  following linear
% program is then solved
%  max epp, s.t.
% epp/(W*(1+h/W)^2)+q/(qbar*(1+h/W))<= p/mag^2*qbar
%      <= (1+h/W)*q/qbar-epp/W
% (the coefs. of  p and q are named a and b in the code),
% and W is initially ones if not specified and qbar is an estimate of q.
% If epp>0 and p and q have no real positive roots then a solution
% exists.  If epp>0 but p or q have positive real roots then
% extra cutting plane constraints are incorporated, with additional
% frequency points having to be within a factor, sqrt(exfact),
% (exfact=16 in the code at present) of the adjacent given magnitude values.
% The dual LP is solved via modifications to LP and LINP called
% MFLINP and MFLP.

function [sys,fit,extracons] = magfit(vmagdata,dim,Wt)

if ((nargin>3)|(nargin<2)),
   disp('usage: [sys,fit,extracons] = magfit(vmagdata,dim)')
   return
 elseif (nargin>=2 & size(dim)~=[1 4]),
   disp('usage [sys,fit,extracons] = magfit(vmagdata,dim)')
   return
 end


hmax=dim(1);htol=dim(2);nmin=dim(3);nmax=dim(4);
[mattype,rows,cols,pts] = minfo(vmagdata);
if mattype~='vary', error('data must be of type varying'),end
[magdata,rowpoint,omega,err]=vunpck(vmagdata);
[sz_mg1,sz_mg2]=size(magdata);
if any(sign(magdata)-ones(sz_mg1, sz_mg2))|any(sign(omega)-ones(sz_mg1, sz_mg2)),
       error('magnitude and frequency data must be positive'), end,
om=omega.^2;mag=magdata.^2;
if nargin==2, Wdata=ones(pts,1);Winv=Wdata;
   else Wt=vabs(Wt);
       [Wdata,rowpoint,indv,err] = vunpck(Wt); Winv=Wdata.^(-1);
  end % if nargin==2
[om,index]=sort(om); mag=mag(index);
%define average frequency value.
n=nmin;
if om(1)==0, omav=sqrt(om(2)*om(pts));
              else omav=sqrt(om(1)*om(pts));end,
% rescale frequency list for numerical reasons.
 om=om/omav;bold=ones(n+1,1);
maxmag=max(mag);  minmag=min(mag);
%initialize h-iteration variables.
h=hmax;hupper=hmax;hlower=0;
if htol>=0.49*hmax, htol=0.49*hmax;end,

%initialize matrices for the LP with n=nmin.
foundn=0;extracons=0;
M=(om*ones(1,n+1)).^(ones(pts,1)*[n:-1:0]);
N=(mag*ones(1,n+1)).\M;
extracons=0;exfact=16; %this factor gives the bounds on extra points >1.
inc=floor((pts-1)/(2*n+1));
startbasic=[2:2*inc:2*n*inc+2,pts+inc+2:2*inc:pts+2+(2*n+1)*inc];
while((hupper-hlower)>htol*max(hupper/hmax,1)),
  qbar=polyval(bold,om);
  ophw=1+h*Winv;ophwinv=ophw.^(-1);
  P=(ophw*ones(1,n)).*M(:,2:n+1);
  R=(ophwinv*ones(1,n)).*M(:,2:n+1);
  Winv2=Winv.*(ophwinv.^2);
  if n==0; extraA=[];lngthexa=0;
     else extraA=[zeros(1,n) 1 zeros(1,n-1) -maxmag*100 0;
                  zeros(1,n) -1 zeros(1,n-1) minmag/100 0];
          lngthexa=2;
     end; %if n==0
  A=[ zeros(1,2*n+1) 1; -1 zeros(1,2*n+1); zeros(1,n) -1 zeros(1,n+1);
      zeros(1,2*n) -1 0; extraA;
[qbar*ones(1,2*n+1);qbar*ones(1,2*n+1)].\[ N -P ; -N  R],[Winv;Winv2]];
  B=[zeros(1,2*n+1) 1 ];
  C=[h; -minmag/100; zeros(2+lngthexa,1);
    [qbar;qbar].\[M(:,1).*ophw;-M(:,1)./ophw]];
% scale A, B and C.
 % D1=max(abs([A C]'));
%  A=(D1'*ones(1,2*n+2)).\A;
%  C=D1'.\C;
  D2=max(abs([A;B]));
  A=A./(ones(2*(pts+extracons)+4+lngthexa,1)*D2);
  B=B./D2;
  [basic,sol,epp,lambda,tnpiv,flopcount] = mflinp(A',B',C',startbasic);
  x=D2'.\(A(basic,:)\C(basic));
  oldh=h;
  if epp<=0,
      if foundn, hlower=h;h=(0.5*hlower+0.5*hupper);
         else
           if n==nmax,
             hlower=h; h=2*h;hupper=h;
           else n=n+1;
             M=[om.*M(:,1),M];
             N=[mag.\M(:,1),N];
             bold=ones(n+1,1);
           end, %if n==nmax
          inc=floor((pts-1)/(2*n+1));
          startbasic=[5:2*inc:2*n*inc+5,...
              extracons+pts+inc+5:2*inc:extracons+pts+5+(2*n+1)*inc];
        end,%if foundn
     end, %if epp<=0,


  if epp>0,   %must check that a and b do not have any positive real roots.
    a=x(1:n+1);
    b=[1; x(n+2:2*n+1)];
    rootsb=roots(b);
    rootsa=roots(a);
    realposinxb=[];bnotpos=0;
    for i=1:length(rootsb), if ((imag(rootsb(i))==0)&(real(rootsb(i))>0)),
      bnotpos=1;  realposinxb=[realposinxb, i];
      end,end, %for i=1:length(rootsb)
    realposinxa=[];anotpos=0;
    for i=1:length(rootsa), if ((imag(rootsa(i))==0)&(real(rootsa(i))>0)),
      anotpos=1; realposinxa=[realposinxa, i];
     end,end,%for i=1:length(rootsa)

    if (bnotpos),
      pass=0;
      realposb=sort(rootsb(realposinxb));
      if (max(size(realposb))==1), newomb=realposb(1)*[.9 ;1;1.1];
         else  rb1=realposb(1);rb2=realposb(2);
            newomb=[(rb1^0.25)*(rb2^0.75);sqrt(rb1*rb2);(rb2^0.25)*(rb1^0.75)];
        end, %if (max(size(realposb))==1)
      placeb=(pts-sum(sign(om(1:pts)-newomb(2)*ones(pts,1))))/2;
      if placeb==0, newmagb=mag(1);newW=(exfact-1)/h;
         elseif placeb==pts, newmagb=mag(pts);newW=(exfact-1)/h;
           else newmagb=sqrt(mag(placeb)*mag(placeb+1));
                newW= (exfact*max(mag(placeb),mag(placeb+1))/newmagb-1)/h;
        end % if placeb==0,
      lob=length(newomb);
      tmp1=(newomb*ones(1,n+1)).^(ones(lob,1)*(n:-1:0));
      M=[M;tmp1];
      N=[N;newmagb\tmp1];
      Winv=[Winv;newW*ones(lob,1)];
      om=[om;newomb];
      mag=[mag;newmagb*ones(lob,1)];
      extracons=extracons+lob;
    end, %if (bnotpos)

    if (anotpos),
      pass=0;
          realposa=sort(rootsa(realposinxa));
          if (max(size(realposa))==1), newoma=realposa(1)*[.9 ;1;1.1];                      else   ra1=realposa(1);ra2=realposa(2);
             newoma=[(ra1^0.25)*(ra2^0.75);sqrt(ra1*ra2);(ra2^0.25)*(ra1^0.75)];
            end; %if (max(size(realposa))==1)
          placea=(pts-sum(sign(om(1:pts)-newoma(2)*ones(pts,1))))/2;
          if placea==0, newmaga=mag(1);newW=(exfact-1)/h;
              elseif placea==pts, newmaga=mag(pts);newW=(exfact-1)/h;
               else newmaga=sqrt(mag(placea)*mag(placea+1));
                newW= (exfact*max(mag(placea),mag(placea+1))/newmaga-1)/h;
          end % placea==0
      loa=length(newoma);
      tmp1=(newoma*ones(1,n+1)).^(ones(loa,1)*(n:-1:0));
      M=[M;tmp1];
      N=[N;newmaga\tmp1];
      Winv=[Winv;newW*ones(loa,1)];
      om=[om;newoma];
      mag=[mag;newmaga*ones(loa,1)];
      extracons=extracons+loa;
    end, %if (anotpos)


   if (~anotpos&~bnotpos),
    foundn=1;
    g=abs(polyval(a,om(1:pts))./polyval(b,om(1:pts)));
    fit=max([((g(1:pts)./mag(1:pts)-1)./Winv(1:pts));...
             ((mag(1:pts)./g(1:pts)-1)./Winv(1:pts))]);
    hupper=fit; h=(0.5*hupper+0.5*hlower);
    agood=a; bgood=b; startbasic=basic;bold=b;
    end, %if (~anotpos&~bnotpos)
   end, %if epp>0
  if (h~=oldh & extracons~=0),
    Winv(pts+1:pts+extracons)=(oldh/h)*Winv(pts+1:pts+extracons);
    end, %if (h~=oldh &

 end,% while((hupper-hlower)


sqrootsa=-sqrt(-roots(agood))*sqrt(omav);
[absrootsa,inda]=sort(abs(sqrootsa));
sqrootsa=sqrootsa(inda);
sqrootsb=-sqrt(-roots(bgood))*sqrt(omav);
[absrootsb,indb]=sort(abs(sqrootsb));
sqrootsb=sqrootsb(indb);

if agood(1)==0, agood(1)=1e-12; end  %something has gone numerically wrong.
dega=n;for i=1:n, if absrootsa(i)==0, dega=dega-1;end;end
degb=n;for i=1:dega, if absrootsb(i)==0 , degb=degb-1;end;end
num=real(sqrt(abs(agood(1)))*poly(sqrootsa(1:dega)));
den=real(poly(sqrootsb(1:degb)));
g=abs(polyval(num,sqrt(-1)*omega)./polyval(den,sqrt(-1)*omega));
fit=max([(((g.^2)./(magdata.^2)-1).*Wdata);...
             (((magdata.^2)./(g.^2)-1).*Wdata)]);

if n>0, sys=nd2sys(num,den);
   else sys=  num/den;
 end
%
%