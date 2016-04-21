function [gam_opt,acp,bcp,ccp,dcp,acl,bcl,ccl,dcl] = hinfopt(varargin)
%HINFOPT H-Infinity control synthesis via Gamma iteration.
%
% [GAM_OPT,SS_CP,SS_CL] = HINFOPT(TSS_,GAMIND,AUX) or
% [GAM_OPT,ACP,BCP,CCP,DCP,ACL,BCL,CCL,DCL] = HINFOPT(A,B1,..,GAMIND,AUX)
%  does H-inf Gamma-Iteration to compute optimal H-Infinity control
%  laws for a given system Tcl:(TSS_) via the improved Loop-Shifting
%  two-Riccati formulae. "Gam_opt" is the optimal "gamma" for which
%
%                   || gamma * Tcl(gamind,:)   ||
%                   ||                         ||     <= 1
%                   ||         Tcl(otherind,:) || inf
%  where
%       Tcl(gamind,:) contains the rows to be weighted by "gamma",
%       Tcl(otherind,:) contains the other rows of Tcl.
%  Inputs:  Tcl: TSS_ = mksys(A,B1,B2,C1,C2,D11,D12,D21,D22);
%       Optional Inputs:
%           gamind: the index of the outputs to be scaled by gamma
%                   (default: all output channels)
%           aux   : [tol, maxgam, mingam] (default: [0.01 1 0])
%                   tol   : tolerance for stopping the iteration
%                   maxgam: initial guess for maximum "gam_opt"
%                   mingam: initial guess for minimum "gam_opt"
%  Outputs: gam_opt (optimal gamma)
%        H-Inf optimal controller:   ss_cp = mksys(acp,bcp,ccp,dcp)
%        gamma-weighted closed-loop: ss_cl = mksys(acl,bcl,ccl,dcl)

% R. Y. Chiang & M. G. Safonov (1/1989)
% Revised 3/29/98 M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $

nag1 = nargin;
nag2 = nargout;

if nag1 == 1 | nag1 == 9
   % case (TSS_)
[emsg,nag1,xsflag,Ts,A,B1,B2,C1,C2,D11,D12,D21,D22]=mkargs5x('tss',varargin); error(emsg);
   gamind = 1:size(C1)*[1;0];
   aux = [0.01 1 0];
elseif nag1 == 2 | nag1 == 10
   % case (TSS_,gamind)
[emsg,nag1,xsflag,Ts,A,B1,B2,C1,C2,D11,D12,D21,D22,gamind]=mkargs5x('tss',varargin); error(emsg);
   aux = [0.01 1 0];
elseif nag1 == 3 | nag1 == 11
   % case(TSS_,gamind,aux)
[emsg,nag1,xsflag,Ts,A,B1,B2,C1,C2,D11,D12,D21,D22,gamind,aux]=mkargs5x('tss',varargin); error(emsg);
end

if Ts, % discrete case (call to DHINFOPT)
   inargs=cell(1,nag1);
   [junk,junk,junk,inargs{:}]=mkargs5x('tss',varargin);
   [gam_opt,acp,bcp,ccp,dcp,acl,bcl,ccl,dcl] = dhinfopt(inargs{:});
else   % continuous case
   
if length(gamind)==0, gamind = 1:size(C1)*[1;0]; end
if length(aux)==0, aux = [0.01 1 0]; end

%
if size(aux)*[0;1] == 1
   tol = aux(1); rho_h = 1; rho_l = 0;
end
if size(aux)*[0;1] == 2
   tol = aux(1); rho_h = aux(2); rho_l = 0;
end
if size(aux)*[0;1] == 3
   tol = aux(1); rho_h = max(aux(2:3)); rho_l = min(aux(2:3));
end
%
rho_h = max([rho_h 1.e-7]); rho_l = max([rho_l 0]);
mingam = rho_l; maxgam = rho_h;
%
% ----- Initialize all variables:
%
iteration = 0;
rhoi = max([0, maxgam]);         % initial guesss for gamma
p_opt = 0; p = 0;                % initialize gamma iteration counters
relerr = 1.e6;                   % initialize to ensure at least one iteration
xflag = 0;                       % initially not yet sure if maxgam is valid
yflag = 0;                       % initially not yet sure if mingam is valid
if rho_l == 0
   yflag = 1;
end
%
c1 = C1; d11 = D11; d12 = D12;
gam_opt = 0;
%
while relerr > tol
    p = p+1; iteration(p) = p;
    if p == 1
       clc
       disp(' ')
       disp('                   << H-Infinity Optimal Control Synthesis >>')
       disp(' ')
       disp('  No     Gamma    D11<=1   P-Exist   P>=0   S-Exist   S>=0   lam(PS)<1    C.L.')
       disp(' ------------------------------------------------------------------------------')
    end
    C1(gamind,:)  = rhoi*c1(gamind,:);
    D11(gamind,:) = rhoi*d11(gamind,:);
    D12(gamind,:) = rhoi*d12(gamind,:);
    [tacp,tbcp,tccp,tdcp,tacl,tbcl,tccl,tdcl,hinfo] = hinf(...
                             A,B1,B2,C1,C2,D11,D12,D21,D22,0);
    hexist  = setstr(hinfo(1:4));
    D11flag = setstr(hinfo(5:8));
    Pexist  = setstr(hinfo(9:12));
    Pflag   = setstr(hinfo(13:16));
    Sexist  = setstr(hinfo(17:20));
    Sflag   = setstr(hinfo(21:24));
    PSflag  = setstr(hinfo(25:28));
    RHP_cl = hinfo(29);
    if RHP_cl > 0
       CLflag = 'UNST';
    else
       CLflag = 'STAB';
    end
    lamps_max = hinfo(30);
    if hexist == 'FAIL'
       gamaflg = 1;
    else
       gamaflg = 0;
    end
    if gamaflg + RHP_cl == 0
       rho_l = rhoi; yflag = 1;
       acp = tacp; bcp = tbcp; ccp = tccp; dcp = tdcp;
       acl = tacl; bcl = tbcl; ccl = tccl; dcl = tdcl;
       gam_opt = rhoi; p_opt = p;
    else
       rho_h = rhoi;
       xflag = 1;
    end
    disp([sprintf('%4.0f',p),sprintf('%12.4e',rhoi),'   ', D11flag,'     ',Pexist,'     ',Pflag,'    ',Sexist,'     ',Sflag,'      ',PSflag,'      ',CLflag])
    if xflag == 0
       rhoi = 2*rhoi;
    else
       if yflag == 0
          if rhoi == rho_l
             rho_l = rho_l/2;
             rhoi = rho_l;
          else
             rhoi = rho_l;
          end
       end
       rhoi = (rho_l + rho_h)/2;
    end
    if rho_l == 0
       relerr = 1.e6;
    else
       relerr = abs((rho_h - rho_l)/rho_l);
    end
    if xflag*yflag < 0.5, relerr = 1.e6; end;
end
%
disp(' ')
disp(['      Iteration no. ', int2str(p_opt),...
' is your best answer under the tolerance: ', sprintf('%8.4f',tol), ' .'])
%
end % end if Ts

if xsflag
   acp = mksys(acp,bcp,ccp,dcp,Ts);
   if nag2 > 2
      bcp = mksys(acl,bcl,ccl,dcl,Ts);
   end
end
%
% ------- End of HINFOPT.M ---- RYC/MGS %