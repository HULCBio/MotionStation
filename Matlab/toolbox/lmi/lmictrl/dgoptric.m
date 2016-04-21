% [gopt,X1,X2,Y1,Y2] = dgoptric(P,r,gmin,gmax,tol)
%
% Computes the optimal H_infinity performance GOPT for the REGULAR
% discrete-time plant P(z) using the Riccati-based characterization.
%
% NOT MEANT TO BE CALLED BY THE USER.
%
% Output:
%  GOPT       best H_infinity performance in the interval [GMIN,GMAX]
%  X1,X2,..   X = X2/X1  and  Y = Y2/Y1  are the solutions of the two
%             H_infinity Riccati equations for  gamma = GOPT
%
% See also  DHINFRIC, DKCEN.

% Authors: P. Gahinet and A.J. Laub  10/93, modified 9/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [gopt,x1,x2,y1,y2,sing12,sing21]=dgoptric(P,r,gmin,gmax,tol,knobjw)

ubo=1; lbo=1;   % default = specified bounds

if nargin < 5,
  error('usage:  [gopt,X1,X2,Y1,Y2] = dgoptric(P,r,gmin,gmax,tol)');
elseif nargin <6,
  knobjw=0;
end


if gmax==0,  ubo=0; gmax=1e3;  end
if gmin==0,  lbo=0; gmin=1e-1; end

x1=[]; x2=[]; y1=[]; y2=[];


% tolerances
macheps=mach_eps;
tolsing=sqrt(macheps);
toleig=macheps^(2/3);


% retrieve plant data

[a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(P,r);
na=size(a,1); [p1,m1]=size(d11); [p2,m2]=size(d22);
if ~m1, error('D11 is empty according to the dimensions R of D22'); end


% orthogonalize [B2;D12] and [C2';D21']

w12=svdparts([b2;d12],0,tolsing);
b2=w12(1:na,:); d12=w12(na+(1:p1),:); m2=size(b2,2);

w21=svdparts([c2';d21'],0,tolsing);
c2=w21(1:na,:)'; d21=w21(na+(1:m1),:)'; p2=size(c2,1);


% detect rank-deficiencies in D12/D21

sing12=0;  sing21=0;
[u1,sr12]=svdparts(d12,tolsing,tolsing);      r12=length(sr12);
[xxx,sr21,z1]=svdparts(d21,tolsing,tolsing);  r21=length(sr21);

if r12 < m2, sing12=1;  end
if r21 < p2, sing21=1;  end
if sing12 | sing21, gopt=[]; return, end


% reset gmin if D11 nonzero

nd11=norm(d11,1);
if nd11 > 0,
  aux=max(norm((eye(p1)-u1*u1')*d11) , norm(d11*(eye(m1)-z1*z1')));
  if aux>1e-5 & lbo==0, gmin=aux; else gmin=max(gmin,aux); end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       DETECT AND REMOVE UNIT CIRCLE ZEROS OF P12(s) or P21(s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aX=a; b1X=b1; b2X=b2; d12X=d12; c1X=c1; naX=na;  m2X=m2;
aY=a'; b1Y=c1'; c1Y=b1'; b2Y=c2'; d12Y=d21'; naY=na;  p2Y=p2;

% P12(s)
[aX,b2X,flag]=ucreg(aX,b2X,c1X,d12X,knobjw);
if flag,
  disp('** unit-circle zeros of P12(z) regularized');
end

% P21(s)
[aY,b2Y,flag]=ucreg(aY,b2Y,c1Y,d12Y,knobjw);
if flag,
  disp('** unit-circle zeros of P21(z) regularized');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set-up for Hx and Hy

auxh11=mdiag(aX,eye(naX));
auxh13=[b2X;zeros(naX,m2X)];
auxh21=mdiag(c1X,zeros(m1,naX));
auxh23=[d12X ; zeros(m1,m2X)];

EX=mdiag(eye(naX),aX');
EX(2*naX+m1+p1+m2X,2*naX+m1+p1+m2X)=0;


auxj11=mdiag(aY,eye(naX));
auxj13=[b2Y;zeros(naY,p2Y)];
auxj21=mdiag(c1Y,zeros(p1,naY));
auxj23=[d12Y ; zeros(p1,p2Y)];
auxj31=zeros(p2Y,2*naY);

EY=mdiag(eye(naY),aY');
EY(2*naY+m1+p1+p2Y,2*naY+m1+p1+p2Y)=0;



%%%%%%%%%%%%%%%%%%%%%%%%%%
%  gamma iteration starts
%%%%%%%%%%%%%%%%%%%%%%%%%%


gap=1e99;
g=sqrt(gmin*gmax);

disp(sprintf('\n Gamma-Iteration: \n\n     Gamma                Diagnosis  '));

while  gap > tol*gmin & gmax > 1e-4 & gmin < 1e6,

  pass=1;

  % rescale [B2;D12] and [C2';D21'] to minimize the condition nbr of
  %          [-I  D11/g  D12 ; D11'/g -I 0 ; D12' 0 0]
  sclf=max(1,nd11/g);

  d11g=d11/g; b1Xg=b1X/g; b1Yg=b1Y/g;
  auxh12=[zeros(naX,p1) b1Xg; -c1X' zeros(naX,m1)];
  auxh22=[-eye(p1) , d11g ; d11g' -eye(m1) ];
  HX=[auxh11 auxh12 sclf*auxh13; auxh21 auxh22 sclf*auxh23; ...
                       zeros(m2X,2*naX) sclf*auxh23' zeros(m2X)];
  EX(2*naX+p1+(1:m1),naX+(1:naX))=-b1Xg';
  EX(2*naX+m1+p1+(1:m2X),naX+(1:naX))=-sclf*b2X';

  auxj12=[zeros(naY,m1) b1Yg; -c1Y' zeros(naY,p1)];
  auxj22=[-eye(m1) , d11g' ; d11g -eye(p1)];
  HY=[auxj11 auxj12 sclf*auxj13; auxj21 auxj22 sclf*auxj23; ...
                          zeros(p2Y,2*naY) sclf*auxj23' zeros(p2Y)];
  EY(2*naY+m1+(1:p1),naY+(1:naY))=-b1Yg';
  EY(2*naY+m1+p1+(1:p2Y),naY+(1:naY))=-sclf*b2Y';

  [xx1,xx2,dx1,dx2]=dricpen(HX,EX,naX);

  if isempty(xx1),
    disp(sprintf(...
      '    %6.4f     :    infeasible  (Hx has unit-circle eigenvalues)',g));
    pass=0;
  else
    [yy1,yy2,dy1,dy2]=dricpen(HY,EY,naY);
    if isempty(yy1),
      disp(sprintf(...
      '    %6.4f     :    infeasible  (Hy has unit-circle eigenvalues)',g));
      pass=0;
    end
  end


  % test positivity of X using the QZ trick
  if pass,
    if min(abs(dx1)) < toleig | min(real(conj(dx1).*dx2)) < - toleig,
      disp(sprintf(...
       '    %6.4f     :    infeasible  (X is not positive semi-definite)',g));
      pass=0;
    end
  end


  % test positivity of Y using the QZ trick
  if pass,
    if min(abs(dy1)) < toleig | min(real(conj(dy1).*dy2)) < - toleig,
      disp(sprintf(...
       '    %6.4f     :    infeasible  (Y is not positive semi-definite)',g));
      pass=0;
    end
  end

  % test spectral radius condition
  if pass,
    if max(real(eig(xx2'*yy2,xx1'*yy1))) > (1+toleig)*g^2,
      disp(sprintf(...
       '    %6.4f     :    infeasible  ( rho(XY) > gamma^2 )',g));
      pass=0;
    end
  end

  % test extra positivity conditions
  if pass,
     d1112=[d11g d12X]; b12=[b1Xg b2X];
     Delta=d1112'*d1112+(b12'*xx2)*(xx1\b12);
     Delta(1:m1,1:m1)=Delta(1:m1,1:m1)-eye(m1);
     if length(find(real(eig(Delta))<0))~=m1,
       disp(sprintf(...
        '    %6.4f     :    infeasible  (extra condition failed)',g));
       pass=0;
     end
  end

  if pass,
     d1121=[d11g' d12Y]; c12=[b1Yg b2Y];
     Delta=d1121'*d1121+(c12'*yy2)*(yy1\c12);
     Delta(1:p1,1:p1)=Delta(1:p1,1:p1)-eye(p1);
     if length(find(real(eig(Delta))<0))~=p1,
       disp(sprintf(...
        '    %6.4f     :    infeasible  (extra condition failed)',g));
       pass=0;
     end
  end


  if pass,    % all tests passed
    disp(sprintf('    %6.4f     :    feasible ',g));
    gmax=g;  ubo=1; gopt=gmax;
    if ~lbo & gmax < 10*gmin,  gmin=gmin/10; end
    x1=xx1; x2=xx2; y1=yy1; y2=yy2;
  else
    gmin=g;  lbo=1;
    if ~ubo & gmin > gmax/10, gmax=100*gmax; end
  end


  if gmin==Inf,
     gap=0; g=Inf;
  elseif ~ubo & gmin > 1e6,
     g=Inf; gmin=Inf; gmax=Inf; gap=Inf;
  else
     gap=gmax-gmin;
     if gmax>10*gmin, g=sqrt(gmin*gmax); else g=(gmin+gmax)/2; end
  end


end % while



%%%%%%%%%%%%%%%% POST-ANALYSIS %%%%%%%%%%%%%%%%%%


if isempty(gopt),
  if gmax==Inf,
     disp(sprintf('\n The plant is unstabilizable or undetectable!\n'));
  end
  return
elseif gopt==Inf,
  disp(sprintf('\n Best closed-loop gain (GAMMA_OPT):   larger than 1e6!...'));
  disp(sprintf('\n      ... computing the optimal LQG controller (GAMMA = Inf)\n'));
else
  disp(sprintf('\n Best closed-loop gain (GAMMA_OPT):   %6.6f \n',gopt));
  if ~lbo & gmax < 1e-4,
     disp(sprintf(' DHINFRIC:  GAMMA_OPT is nearly zero (less than 1e-4)\n'));
  end
end




%if nargout<4,
%  x1=real(x2/x1);  x2=real(y2/y1);
%end
