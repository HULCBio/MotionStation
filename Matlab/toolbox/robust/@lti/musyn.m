function [acp,bcp,ccp,dcp,mu,logd0,ad,bd,cd,dd,gam] = musyn(varargin)
%MUSYN Automated MU-synthesis procedure.
%
% [SS_CP,MU,LOGD,SS_D,GAM] = MUSYN(TSS_,W) or
% [SS_CP,MU,LOGD,SS_D,GAM] = MUSYN(TSS_,W,GAMIND,AUX,LOGD0,N,BLKSZ,FLAG)
% automates the MU-synthesis D-F iteration using hinfopt, fitd and ssv.
% Inputs: TSS_ = mksys(A,B1,B2,...,D21,D22)  --- the plant
%         W    = frequency vector used for curve fitting by fitd
% Outputs:
%         SS_CP = mksys(ACP,BCP,CCP,DCP) --- MU-synthesis controller
%         LOGD     --- log magnitude of closed-loop
%                      diagonal scaling from psv.m


%  R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.6.4.3 $
% All Rights Reserved.

nag1 = nargin;
nag2 = nargout;

% Expand system input arguments and modify NARGIN as needed:
[emsg,nag1,xsflag,Ts,A,B1,B2,C1,C2,D11,D12,D21,D22,w,gamind,aux,logd0,n,blksz,flag]=mkargs5x('tss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end

mu=[];  %initialize

% Now define defaults for input variables:
if nag1<10,
  error('Too few input arguments')
end

% Set any absent optional input variables to []:
if nag1<11, gamind=[]; end
if nag1<12,    aux=[]; end
if nag1<13,  logd0=[]; end
if nag1<14,      n=[]; end
if nag1<15,  blksz=[]; end
if nag1<16,   flag=[]; end

% Determine the number of uncertainty blocks NBLKS from BLKSZ using
% same rules as in psv.m and fitd.m
temp=length(blksz);
if temp>1        % If BLKSZ is a vector
   nblks=temp;            % NBLKS = size of BLKSZ vector
else             % otherwise
   [rD11,cD11]=size(D11);
   nblks=rD11;            % default NBLKS=length(D11) and
   if rD11~=cD11,         % D11 must be a square matrix in this case
       error('plant D11 matrix must be square')
   end
   if temp==1,
                          % default NBLKS=length(D11)/BLKSZ
      nblks=nblks/blksz(1);
      if nblks*blksz(1)~=rD11,
         error('size(D11) should be a multiple BLKSZ')
      end
   end
end

% Do some cursory dimensional compatibility checks on w, logd0, blksz
%nblklogd0 = min(size(logd0));
nblklogd0 = size(logd0,1);
%nwlogd0 = max(size(logd0));
nwlogd0 = size(logd0,2);
if min([nblks,nblklogd0])>1,
   if nblks~=nblklogd0,
     error('Number of rows of LOGD0 must equal dimension of vector BLKSZ'),
   end
end
nw=length(w);
if nwlogd0>0 & nwlogd0~=nw,
   error('Number of columns of LOGD0 must equal number of frequencies W'),
end

% Set flag if mu plot is to be computed
muflag=0;
if (xsflag & nargout>1) | nargout>4
   muflag=1;
end

% Initialize variables for D-F iteration loop
if min(size(aux))>0
   tol=aux(1)  %  Tolerance for terminating D-F iteration loop
else
   tol=0.01;
end
gams=Inf;
done=0;    % 0:=FALSE; D-F iteration loop terminates when DONE=1 (TRUE).

% Commence D-F iteration loop:
while ~done,
 % Augment plant with a state-space curve-fit to the bode data LOGD0:
                                % If LOGD is constant times identity
 if min(size(logd0))==0,
     noscale=1;
 elseif min(abs(logd0(:)))==max(abs(logd0(:)))
     noscale=1;
 else
     noscale=0;
 end
 if noscale,
   logd0=zeros(nblks,nw);           % set LOGD0 to zero
   logdfit=logd0;                  % set LOGDFIT to zero
   [ad,bd,cd,dd]=ssdata(ss(eye(rD11)));
   AD =A;   BD1 =B1;   BD2 =B2;    % and use unaugmented plant
   CD1=C1;  DD11=D11;  DD12=D12;
   CD2=C2;  DD21=D21;  DD22=D22;
 else                           % otherwise,
                                   % curve-fit logd0 using fitd.m
   [ad,bd,cd,dd,logdfit]=fitd(logd0,w,n,blksz);
                                   % and use augd.m to augment the
                                   % plant with the fitted diagonal-
                                   % scaling [ad,bd,cd,dd].
   [AD,BD1,BD2,CD1,CD2,DD11,DD12,DD21,DD22]=...
       augd(A,B1,B2,C1,C2,D11,D12,D21,D22,ad,bd,cd,dd);
 end

 % Do hinfopt.m on the diagonally-scaled, augmented plant:
 [gam,acp,bcp,ccp,dcp,acl,bcl,ccl,dcl]=...
     hinfopt(AD,BD1,BD2,CD1,CD2,DD11,DD12,DD21,DD22,gamind,aux);

 % Test for convergence:
 if gams-gam > tol,  % If cost decrease is greater than TOL
    acls=acl;  bcls=bcl;       % then store current values
    ccls=ccl;  dcls=dcl;       % and continue D-F loop
    acps=acp;  bcps=bcp;
    ccps=ccp;  dcps=dcp;
    mus=mu;
    logd0s=logd0;
    gams=gam;
 else                      % otherwise
    if gams-gam < 0;              % first, check if cost increased
      acl=acls;  bcl=bcls;            % if so, restore the values
      ccl=ccls;  dcl=dcls;            % from the previous iteration
      acp=acps;  bcp=bcps;
      ccp=ccps;  dcp=dcps;
      mu=mus;
      logd0=logd0s;
      gam=gams;
    end
    done=1;                       % prepare to exit D-F iteration loop
 end                 % End of convergence test

 % Do ssv.m to evaluate MU bode and update LOGD0, if needed:
 if ~done | muflag,
    [mu,logd1]=ssv(acl,bcl,ccl,dcl,w,blksz,'psv');
    if noscale,
         logd0=logd1;
    else
         logd0=logd1+logdfit;
    end
 end
end   % End D-F iteration loop

% If input was in SYSTEM form, then convert output to SYSTEM form:
if xsflag,
   if nag2>6,
      disp('WARNING:  Too many output arguments for SYSTEM form output'),
   end
   acp=mksys(acp,bcp,ccp,dcp);
   bcp=mu;
   ccp=logd0;
   dcp=mksys(ad,bd,cd,dd);
   mu=gam;
end

% ------------ End of MUSYN.M -----------------%  RYC/MGS 5/19/92 %