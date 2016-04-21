% [Preg,gbest,x1,x2,y1,y2]=plantreg(P,r,gama,x1,x2,y1,y2,sing12,sing21)
%
% Called by HINFRIC, NOT MEANT TO BE CALLED BY USERS.
%
%
% Regularizes a plant P(s) where D12 or D21 are rank-deficient.
%
% The eps-regularization is optimized wrt. numerical stability
% and magnitude of the controller parameters.  GAMA is increased
% to GBEST when necessary for numerical reliability.
%
% Input:
%   P             plant state-space data in packed form
%   R             size of D22   (R = [ # measurements , # controls ])
%   GAMA          required H-infinity performance
%   X1,X2,Y1,Y2   output of GOPTRIC
%   SING12        SING12 > 0  indicates that D12 is rank deficient
%   SING21        same for D21
%
% Output
%   PREG          regularized plant (in packed form)
%   GBEST         best achievable performance in  [GAMA, +Inf] after
%                 regularization
%   X1,X2,Y1,Y2   X = X2/X1 and  Y = Y2/Y1 are the stabilizing
%                 solutions of the two H_infinity Riccati equations
%                 for gamma = GBEST
%
% See also  HINFRIC.

% Authors: P. Gahinet and A.J. Laub 10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $



function [Preg,gopt,x1,x2,y1,y2]=...
         plantreg(P,r,gopt,x1,x2,y1,y2,sing12,sing21,knobrk,knobjw,macheps)


if nargin<10,
  macheps=mach_eps; knobrk=0; knobjw=0;
end

% regular problem w/o gain limitation -> exit
if knobrk < .1 & ~(sing12 | sing21),
  Preg=P; return
end

if sing12 | sing21,
  disp(sprintf('\n** regularizing D12 or D21 to compute K(s):'));
else
  disp(sprintf('\n** improving the numerical conditioning of K(s):'));
end


% tolerances:
%     tolsing is the tolerance for singularity. The singular part of D12
%     is determined by the requirement:    || B2 D12^+ ||  < 1/tolsing
tolsing=macheps^(3/8);
toleig=macheps^(2/3);


% set control parameters
magobj=1e5/10^(2*knobrk);         % target for norm of Ak,Bk,Ck
maxmag=1e9/10^(2*knobrk);         % target for max. mag. of Ak,Bk,Ck




% retrieve the plant data
[a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(P,r);
na=size(a,1); [p1,m1]=size(d11);
naX=na; m2X=size(d12,2); m1X=m1;
naY=na; m2Y=size(d21,1); m1Y=p1;


% scales of X/Y
if isempty(x1), normX=0; else normX=norm(x2/x1,1); end
if isempty(y1), normY=0; else normY=norm(y2/y1,1); end
scaleX=max(1e-2,normX^(1/3));
scaleY=max(1e-2,normY^(1/3));




% set-up for regularization loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aX=a; b1X=b1; c1X=c1; b2X=b2; d11X=d11; Z12=1; Z12p=[];
aY=a'; b1Y=c1'; c1Y=b1'; b2Y=c2'; d11Y=d11'; Z21=1; Z21p=[];

[u,s12,v12]=svd(d12);   nor12=s12(1,1);  nb2X=norm(b2X,1);
rk=length(find(s12 > max(toleig*nor12,macheps*nb2X)));
s12=u*s12;  b2X=b2X*v12;  d12X=s12;
absX=[abs(b2X);nor12*ones(1,m2X)];
tolX=toleig*nb2X*ones(1,m2X);


% remove jw-axis zeros
aX=jwreg(aX,b2X(:,1:rk),c1X,s12(:,1:rk),knobjw);
p1Xjw=size(d11X,1);




[u,s21,v21]=svd(d21');  nor21=s21(1,1); nb2Y=norm(b2Y,1);
rk=length(find(s21 > max(toleig*nor21,macheps*nb2Y)));
s21=u*s21;  b2Y=b2Y*v21; d12Y=s21;
absY=[abs(b2Y);nor21*ones(1,m2Y)];
tolY=toleig*nb2Y*ones(1,m2Y);


% remove jw-axis zeros
aY=jwreg(aY,b2Y(:,1:rk),c1Y,s21(:,1:rk),knobjw);
p1Yjw=size(d11Y,1);


ZZ=Z12'*Z21;


% Hamiltonian set-up

HX11=mdiag(aX,-aX'); HX33=mdiag(-eye(m1X),zeros(m2X));
HY11=mdiag(aY,-aY'); HY33=mdiag(-eye(m1Y),zeros(m2Y));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               REGULARIZATION LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Initialization

stopX=0; stopY=0;                % termination flags
accelX=1; accelY=1;              % acceleration flags
regX=tolsing;  regY=tolsing;     % initial regularization thresholds
g=gopt;                          % initial gamma

compX=(sing12 > 0); compY=(sing21 > 0);
betaX=regX;  betaY=regY;
magX=1e99;   magY=1e99;


% initialize magnitude estimates
if ~sing12,
  if normX>100, sclf=sqrt(normX); tmp=orth([x1*sclf;x2/sclf]);
  else          sclf=1;           tmp=[x1;x2];                 end
  magX=norm(tmp'*[c1X'*d12X;b2X*sclf^2]/(d12X'*d12X)*b2X',1);
end

if ~sing21,
  if normY>100, sclf=sqrt(normY); tmp=orth([y1*sclf;y2/sclf]);
  else          sclf=1;           tmp=[y1;y2];                 end
  magY=norm(tmp'*[c1Y'*d12Y;b2Y*sclf^2]/(d12Y'*d12Y)*b2Y',1);
end

fprintf(1,' ');


while ~(stopX & stopY),
%%%%%%%%%%%%%%%%%%%%%%%

   pass=1;
   fprintf(1,'.');

   % regularize D12  for current betaX as
   %           ( C1X )          ( D11X )          ( D12X )
   %    C1X -> (  0  )  D11X -> (   0  )  D12X -> ( reg.  )
   % same for D21

   scale=max([betaX*absX;tolX]);  ratio=max([s12;zeros(1,m2X)])./scale;
   ind2X=find(ratio < 1);
   d12X=s12;   stmpX=scale(ind2X);  l2X=length(ind2X);  p1X=p1Xjw+l2X;
   if l2X > 0,
      d12X(p1Xjw+(1:l2X),ind2X)=diag(stmpX);
      z=orth(d12X);  z=eye(p1X)-z*z';
      absmin=1.01*norm(z(:,1:p1Xjw)*d11X);
      if absmin > g,        % reset gopt to lower bound absmin if appropriate
        if compX < 2,                   % betaX = regX -> reset gopt
           gopt=absmin; g=gopt; compY=1;
        elseif magX > maxmag/100,       % still large mag. -> reset g
           g=absmin; compY=1;
        else                            % undo last increase of betaX
           pass=0; stopX=1;
        end
      end
   elseif compX==2, compX=0;
   end


   scale=max([betaY*absY;tolY]);  ratio=max([s21;zeros(1,m2Y)])./scale;
   ind2Y=find(ratio < 1);
   d12Y=s21;   stmpY=scale(ind2Y);  l2Y=length(ind2Y);  p1Y=p1Yjw+l2Y;
   if l2Y > 0,
      d12Y(p1Yjw+(1:l2Y),ind2Y)=diag(stmpY);
      z=orth(d12Y);  z=eye(p1Y)-z*z';
      absmin=1.01*norm(z(:,1:p1Yjw)*d11Y);
      if absmin > g,
        if compY < 2,                   % betaY = regY -> reset gopt
           gopt=absmin; g=gopt; compX=1;
        elseif magY > maxmag/100,       % still large mag. -> reset g
           g=absmin; compX=1;
        else                            % undo last increase of betaY
           pass=0; stopY=1;
        end
      end
   elseif compY==2, compY=0;
   end


  if pass & compX,   % recompute X
     c1Xt=[c1X ; zeros(l2X,naX)];  d11Xt=[d11X ; zeros(l2X,m1X)];
     scalbd=diag(max(abs([b2X;d12X])));
     b2Xt=b2X/scalbd; d12Xt=d12X/scalbd;
     HX12=[zeros(naX,p1X);-c1Xt'] ;
     HX13=[b1X/g  b2Xt;zeros(naX,m1X+m2X)];
     HX21=[c1Xt zeros(p1X,naX)] ;
     HX31=[zeros(m1X,naX) b1X'/g;zeros(m2X,naX) b2Xt'];
     HX23=[d11Xt/g  d12Xt];
     HX=[HX11 HX12/scaleX scaleX*HX13;HX21/scaleX -eye(p1X) HX23;scaleX*HX31 HX23' HX33];


     [x1t,x2t]=ricpen(HX,mdiag(eye(2*naX),zeros(p1X+m1X+m2X)));
     pass=(naX == 0 | ~isempty(x1t));
     if naX > 0 & pass,
        [d1,d2]=qz(x1t,x2t,'complex');
        d1=diag(d1); d2=diag(d2);
        pass=(min(abs(d1)) > macheps*scaleX^2);
        if pass, pass=(min(real(d2./d1)) > -toleig); end
        x2t=x2t*scaleX^2;   sqnorX=sqrt(max(abs(d2./d1)))*scaleX;
     end
  else
     x1t=x1; x2t=x2;
  end


  if pass & compY,   % recompute Y
     c1Yt=[c1Y ; zeros(l2Y,naY)];     d11Yt=[d11Y ; zeros(l2Y,m1Y)];
     scalbd=diag(max(abs([b2Y;d12Y])));
     b2Yt=b2Y/scalbd; d12Yt=d12Y/scalbd;
     HY12=[zeros(naY,p1Y);-c1Yt'];
     HY13=[b1Y/g  b2Yt;zeros(naY,m1Y+m2Y)];
     HY21=[c1Yt zeros(p1Y,naY)];
     HY31=[zeros(m1Y,naY) b1Y'/g;zeros(m2Y,naY) b2Yt'];
     HY23=[d11Yt/g d12Yt];
     HY=[HY11 HY12/scaleY HY13*scaleY;HY21/scaleY -eye(p1Y) HY23;HY31*scaleY HY23' HY33];

     [y1t,y2t]=ricpen(HY,mdiag(eye(2*naY),zeros(m1Y+p1Y+m2Y)));
     pass=(naY == 0 | ~isempty(y1t));

     if naY > 0 & pass,
        [d1,d2]=qz(y1t,y2t,'complex');
        d1=diag(d1); d2=diag(d2);
        pass=(min(abs(d1)) > macheps*scaleY^2);
        if pass, pass=(min(real(d2./d1)) > -toleig); end
        y2t=y2t*scaleY^2;  sqnorY=sqrt(max(abs(d2./d1)))*scaleY;
     end
  else
     y1t=y1; y2t=y2;
  end

  rho=~pass*gopt;

  if naX > 0 & naY > 0 & pass & (compX | compY),
    xx1=mdiag(x1t,eye(na-naX));    xx2=mdiag(x2t,zeros(na-naX));
    yy1=mdiag(y1t,eye(na-naY));    yy2=mdiag(y2t,zeros(na-naY));
    rho=max(real(eig(xx2'*ZZ*yy2,xx1'*ZZ*yy1)));
    if rho > 0, rho=sqrt(rho); pass=(rho < (1+toleig)*g); end
  end


  % estimate the corresponding norm of BK and CK
  % NB: rescaling of x1t,x2t is consistent with KRIC
  if naX > 0 & compX & pass,
    if sqnorX>10, sclf=sqnorX; else sclf=1; end
    tmp=orth([x1t*sclf;x2t/sclf]);
    magX=norm(tmp'*[c1X'*s12;(b2X+b1X*d11X'*s12/g^2)*sclf^2]/(d12X'*d12X)*b2X',1);
  end


  if naY > 0 & compY & pass,
    if sqnorY>10, sclf=sqnorY; else sclf=1; end
    tmp=orth([y1t*sclf;y2t/sclf]);
    magY=norm(tmp'*[c1Y'*s21;(b2Y+b1Y*d11Y'*s21/g^2)*sclf^2]/(d12Y'*d12Y)*b2Y',1);
  end



  %%%%%%%%%%%%%    decision making    %%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%    ---------------    %%%%%%%%%%%%%%%%%%%%%%%

  if pass,        % set gopt to current g, increase betaX, betaY

     gopt=g; regX=betaX;  regY=betaY;
     if compX,  x1=x1t; x2=x2t; scaleX=min(1e5,max(1e-3,sqnorX)); end
     if compY,  y1=y1t; y2=y2t; scaleY=min(1e5,max(1e-3,sqnorY)); end
     stopX=stopX | magX < magobj | (magX <= maxmag & betaX > 1);
     stopY=stopY | magY < magobj | (magY <= maxmag & betaY > 1);
     compX=2*(~stopX & (magX > magY | stopY));
     compY=2*(~stopY & (magY >= magX | stopX));

  elseif betaX > 1e3*regX | betaY > 1e3*regY,   % turn off acceleration

     accelX=accelX & (betaX <= 100*regX);    betaX=regX;
     accelY=accelY & (betaY <= 100*regY);    betaY=regY;

  else            % increase gamma, or stop increasing betaX, betaY

     betaX=regX; betaY=regY;
     if max(magX,magY) > maxmag & gopt<Inf,    % large magnitudes -> inc. gamma
        fact=1.3+.4*(gopt > 1e3)+2*(gopt < 1e-2);
        gopt=gopt*fact;
        if rho > 0, gopt=max(gopt,sqrt(rho*gopt)); end
        if gopt>1e6, gopt=Inf; end
        g=gopt;  compX=1;   compY=1;
     else                             % can no longer increase betaX, betaY
        stopX=stopX | (compX == 2);   compX=2*(~stopX);
        stopY=stopY | (compY == 2);   compY=2*(~stopY);
     end
  end


  %% update beta
  if compX==2, betaX=max(100,accelX*magX/1e6)*betaX; end
  if compY==2, betaY=max(100,accelY*magY/1e6)*betaY; end

end   %%% WHILE


fprintf(1,'\n\n');

%%%%%%%%%%%%%  FORM THE REGULARIZED PLANT  %%%%%%%%%%%%%%%%%%%%%%%


scale=max([regX*absX;tolX]);  ratio=max([s12;zeros(1,m2X)])./scale;
ind2=find(ratio < 1); l2=length(ind2);
if l2>0,
   stmp=zeros(l2,m2X); stmp(:,ind2)=diag(scale(ind2));
   d12=[d12;stmp*v12']; d11=[d11;zeros(l2,m1)];
   c1=[c1;zeros(l2,na)]; p1=size(d11,1);
end


scale=max([regY*absY;tolY]);  ratio=max([s21;zeros(1,m2Y)])./scale;
ind2=find(ratio < 1); l2=length(ind2);
if l2>0,
   stmp=zeros(m2Y,l2); stmp(ind2,:)=diag(scale(ind2));
   d21=[d21 v21*stmp]; d11=[d11 zeros(p1,l2)]; b1=[b1 zeros(na,l2)];
end



Preg=ltisys(a,[b1 b2],[c1;c2],[d11 d12;d21 d22]);





%CHECK1(a,b1,c1,b2,d12,d11,x1,x2,gopt);
%CHECK1(a',c1',b1',c2',d21',d11',y1,y2,gopt);
