% [gopt,X1,X2,Y1,Y2] = goptric(P,r,gmin,gmax,tol)
%
% Computes the optimal H-infinity performance GOPT for the
% continuous-time plant P using the Riccati-based characterization.
%
% NOT MEANT TO BE CALLED BY THE USER.
%
% Output:
%  GOPT       best H_infinity performance in the interval [GMIN,GMAX]
%  X1,X2,..   X = X2/X1  and  Y = Y2/Y1  are the solutions of the two
%             H_infinity Riccati equations for  gamma = GOPT  (the
%             reduced-order Riccati equations in the singular case)
%
% See also  HINFRIC, HINFLMI.

% Authors: P. Gahinet and A.J. Laub  10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [gopt,x1,x2,y1,y2,sing12,sing21]=goptric(P,r,gmin,gmax,tol,knobjw)

%  sing12: 1 if D12 is rank-deficient
%  sing21: same for D21

ubo=1; lbo=1;   % default = specified bounds

if nargin <5,
  error('usage:  [gopt,X1,X2,Y1,Y2] = goptric(P,r,gmin,gmax,tol)');
elseif nargin <6,
  knobjw=0;
end

if gmax==0,  ubo=0; gmax=1e3;  end
if gmin==0,  lbo=0; gmin=1e-1; end

x1=[]; x2=[]; y1=[]; y2=[];


% tolerances
macheps=mach_eps;
toleig=macheps^(2/3);
tolsing=macheps^(3/8);


% retrieve the plant data
[a,b1,b2,c1,c2,d11,d12,d21]=hinfpar(P,r);
na=size(a,1);  [p1,m1]=size(d11); m2=size(b2,2); p2=size(c2,1);
if ~m1, error('D11 is empty according to the dimensions R of D22'); end
d11X=d11; m1X=m1;
d11Y=d11'; m1Y=p1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       DETECT AND REMOVE THE SINGULARITIES IN D12 OR D21
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% D12
[aX,b1X,c1X,b2X,d12X,Z12,sing12,u1]=rankreg(a,b1,c1,b2,d12,tolsing,toleig);
naX=size(aX,1);  m2X=size(d12X,2);   p1X=size(d11X,1);

% D21
[aY,b1Y,c1Y,b2Y,d12Y,Z21,sing21,z1]=rankreg(a',c1',b1',c2',d21',...
                                                           tolsing,toleig);
naY=size(aY,1);  m2Y=size(d12Y,2);   p1Y=size(d11Y,1);

% coordinate transformation X-Y
ZZ=Z12'*Z21;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       DETECT AND REMOVE JW-AXIS ZEROS OF P12(s) or P21(s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% P12(s)
[aX,flag]=jwreg(aX,b2X,c1X,d12X,knobjw);
if flag,
  disp('** jw-axis zeros of P12(s) regularized');
end

% P21(s)
[aY,flag]=jwreg(aY,b2Y,c1Y,d12Y,knobjw);
if flag,
  disp('** jw-axis zeros of P21(s) regularized');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% reset gmin if D11 nonzero

nd11=norm(d11,1); abslb=0;
if nd11 > 0,
  if isempty(u1) | isempty(z1),
     abslb=norm(d11);
  else
     abslb=max(norm((eye(p1)-u1*u1')*d11) , norm((eye(m1)-z1*z1')*d11'));
  end
  if abslb>1e-5 & ~lbo, gmin=abslb; lbo=1; else gmin=max(gmin,abslb); end
end



% Hamiltonian set-up

HX11=[aX zeros(naX,naX+p1X); zeros(naX) -aX' -c1X' ; ...
      c1X zeros(p1X,naX) -eye(p1X) ];
HX22=mdiag(-eye(m1X),zeros(m2X));
EX=mdiag(eye(2*naX),zeros(p1X+m1X+m2X));


HY11=[aY zeros(naY,naY+p1Y); zeros(naY) -aY' -c1Y' ; ...
      c1Y zeros(p1Y,naY) -eye(p1Y) ];
HY22=mdiag(-eye(m1Y),zeros(m2Y));
EY=mdiag(eye(2*naY),zeros(p1Y+m1Y+m2Y));




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                GAMMA-ITERATION  STARTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


gap=Inf;
g=sqrt(gmin*gmax);
gopt=[];

disp(sprintf('\n\n Gamma-Iteration: \n\n     Gamma                Diagnosis  '));


while  gap >= tol*gmin & (lbo | gmax > 1e-4),


  HX12=[b1X/g , b2X ; zeros(naX,m1X+m2X) ; d11X/g , d12X];
  HX21=[zeros(m1X,naX) b1X'/g d11X'/g ; ...
                     zeros(m2X,naX) b2X' d12X'];
  HX=[HX11 HX12 ; HX21  HX22];

  HY12=[b1Y/g , b2Y ; zeros(naY,m1Y+m2Y) ; d11Y/g , d12Y];
  HY21=[zeros(m1Y,naY) b1Y'/g d11Y'/g ; ...
                     zeros(m2Y,naY) b2Y' d12Y'];
  HY=[HY11 HY12 ; HY21  HY22];


  [xr1,xr2,dx1,dx2]=ricpen(HX,EX);
  pass=(naX==0 | ~isempty(xr1));

  if ~pass,
    disp(sprintf('    %6.4f     :    infeasible  (Hx has imaginary axis eigenvalues)',g));
  else
    [yr1,yr2,dy1,dy2]=ricpen(HY,EY);
    if naY > 0 & isempty(yr1),
      disp(sprintf('    %6.4f     :    infeasible  (Hy has imaginary axis eigenvalues)',g));
      pass=0;
    end
  end


  % test positivity of X
  if naX > 0 & pass,
%    [d1,d2]=qz(xr1,xr2);
%    d1=diag(d1); d2=diag(d2);   % signed svd's of x1,x2
%    if min(abs(d1)) < toleig | min(real(conj(d1).*d2)) < - toleig,
    pass=min(abs(dx1)) >= macheps;
    if pass, pass=min(real(dx2./dx1)) >= -10*toleig; end
    if ~pass,
      disp(sprintf(...
       '    %6.4f     :    infeasible  (X is not positive semi-definite)',g));
    end
  end


  % test positivity of Y
  if naY > 0 & pass,
%    [d1,d2]=qz(yr1,yr2);
%    d1=diag(d1); d2=diag(d2);   % signed svd's of y1,y2
%    if min(abs(d1)) < toleig | min(real(conj(d1).*d2)) < - toleig,
    pass=min(abs(dy1)) >= macheps;
    if pass, pass=min(real(dy2./dy1)) >= -10*toleig; end
    if ~pass,
      disp(sprintf(...
       '    %6.4f     :    infeasible  (Y is not positive semi-definite)',g));
    end
  end


  % test spectral radius condition
  if naX > 0 & naY > 0 & pass,
    XX1=mdiag(xr1,eye(na-naX));
    XX2=mdiag(xr2,zeros(na-naX));
    YY1=mdiag(yr1,eye(na-naY));
    YY2=mdiag(yr2,zeros(na-naY));
    if max(real(eig(XX2'*ZZ*YY2,XX1'*ZZ*YY1))) > (1+toleig)*g^2,
      disp(sprintf(...
       '    %6.4f     :    infeasible  ( rho(XY) > gamma^2 )',g));
      pass=0;
    end
  end


  if pass,    % all tests passed
    disp(sprintf('    %6.4f     :    feasible ',g));
    gmax=g;  ubo=1; gopt=gmax;
    if ~lbo & gmax < 10*gmin,  gmin=gmin/10; end
    x1=xr1; x2=xr2; y1=yr1; y2=yr2;
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
     disp(sprintf('\n The plant is unstabilizable or undetectable\n'));
  end
elseif gopt==Inf,
  disp(sprintf('\n Best closed-loop gain (GAMMA_OPT):   larger than 1e6'));
else
  disp(sprintf('\n Best closed-loop gain (GAMMA_OPT):   %6.6f \n',gopt));
end



