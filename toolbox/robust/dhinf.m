function [acp,bcp,ccp,dcp,acl,bcl,ccl,dcl,hinfo,ak,bk1,bk2,ck1,ck2,dk11,dk12,dk21,dk22]=dhinf(varargin)
%DHINF Discrete H-Infinity control synthesis (bilinear transform version).
%
%     << Discrete 4-block Optimal H-inf Controller (all solution formulae) >>
%       (via Bilinear Transform, Safonov, Limebeer and Chiang, 1989 IJC)
%
%   [SS_CP,SS_CL,HINFO,TSS_K]=DHINF(TSS_P,SS_U,VERBOSE) computes the
%   discrete H-inf controller F(z) and the controller parameterization K(z)
%   using the "loop-shifting formulae" of Safonov, Limebeer and Chiang
%   (IJC, 1989) and Bilinear Transform.  Given any stable U(z) having inf-norm
%   not greater than one, F(z) is formed by feeding back U(z) around K(z).
%   Required inputs --
%      Augmented plant P(z): TSS_P=MKSYS(A,B1,B2,C1,C2,D11,D12,D21,D22)
%   Optional inputs --
%          Stable contraction U(z): SS_U=MKSYS(AU,BU,CU,DU) (default: U=0)
%          VERBOSE:  if  1,  a verbose display results (default),
%                    if  0, HINF operates silently
%   Output data: Controller F(z):        SS_CP=MKSYS(ACP,BCP,CCP,DCP)
%                Closed-Loop Ty1u1(z):   SS_CL=MKSYS(ACL,BCL,CCL,DCL)
%                 hinfo = (hinflag,RHP_cl,lamps_max)
%                "hinflag" is the H-Infinity existence flag in ASCII
%                All-solutions controller parameterization K(z):
%                     TSS_K=MKSYS(A,BK1,BK2,CK1,CK2,DK11,DK12,DK21,DK22)
%   This file can also used as a script file by typing DHINF with input
%   variables (A,B1,B2,C1,C2,D11,D12,D21,D22) ready in the main workspace
%   in which case the variables (ss_cp,ss_cl,acp,bcp,ccp,dcp,acl,bcl,ccl,
%   dcl,hinfo) are returned in the main workspace.

% R. Y. Chiang & M. G. Safonov 9/18/1988
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------------

% COMMENT:  This function also supports the following format for
% input and output data which is not described above.  Possible
% alternative usages include the following:
%     [ACP,BCP,CCP,DCP,ACP,BCL,CCL,DCL,HINFO,AK,BK1,BK2,CK1,CK2,DK11,DK12,..
%          DK21,DK22]=DHINF(A,B1,B2,C1,C2,D11,D12,D21,D22,AU,BU,CU,DU,VERBOSE)
%     [ACP,BCP,CCP,DCP,ACP,BCL,CCL,DCL,HINFO,AK,BK1,BK2,CK1,CK2,DK11,DK12,..
%          DK21,DK22]=DHINF(A,B1,B2,C1,C2,D11,D12,D21,D22,VERBOSE)
% In all cases, the input data for U(z) and for VERBOSE is optional with
% defaults U(z)=0 and VERBOSE=1. If no output arguments are supplied the
% variables (ss_cp,ss_cl,acp,bcp,ccp, dcp,acl,bcl,ccl,dcl) are automatically
% returned in the main workspace.

%%%
%
% --------- Expand input arguments
%
nag1 = nargin;
nag2 = nargout;
sysuflag=0;       % This flag will be set to one if U(s) data is input

[emsg,nag1,xsflag,Ts,A,B1,B2,C1,C2,D11,D12,D21,D22,AU,BU,CU,DU,disp_hinf]=mkargs5x('tss,ss',varargin); error(emsg);
                % NAG1  may have changed if U(s) is given as system SS_U
                % or if plant is given is system TSS_P
%   disp('   - - - - Transform the Plant via Bilinear Transform - - - -')
   [aa,bb,cc,dd] = bilin(A,[B1 B2],[C1;C2],[D11 D12;D21 D22],-1,'Tustin',2);
   dimp = [size(A)*[1;0],size(B1)*[0;1],size(B2)*[0;1],size(C1)*[1;0],...
           size(C2)*[1;0]];
   [A,B1,B2,C1,C2,D11,D12,D21,D22] = asys2ss([aa bb;cc dd],dimp);
   if nag1==9
     % Case A,B1,B2,C1,C2,D11,D12,D21,D22
     [acp,bcp,ccp,dcp,acl,bcl,ccl,dcl,hinfo,ak,bk1,bk2,ck1,ck2,...
      dk11,dk12,dk21,dk22] = hinf(A,B1,B2,C1,C2,D11,D12,D21,D22);
   elseif nag1==10   % If only 10 input args after expansion
     % Case A,B1,B2,C1,C2,D11,D12,D21,D22,disp_hinf
     disp_hinf=AU;
     [acp,bcp,ccp,dcp,acl,bcl,ccl,dcl,hinfo,ak,bk1,bk2,ck1,ck2,...
      dk11,dk12,dk21,dk22] = hinf(A,B1,B2,C1,C2,D11,D12,D21,D22,disp_hinf);
   elseif nag1==13
     % Case A,B1,B2,C1,C2,D11,D12,D21,D22,AU,BU,CU,DU
     [acp,bcp,ccp,dcp,acl,bcl,ccl,dcl,hinfo,ak,bk1,bk2,ck1,ck2,...
      dk11,dk12,dk21,dk22] = hinf(A,B1,B2,C1,C2,D11,D12,D21,D22,AU,BU,CU,DU);
   elseif nag1==14
     % Case A,B1,B2,C1,C2,D11,D12,D21,D22,AU,BU,CU,DU,disp_hinf
     [acp,bcp,ccp,dcp,acl,bcl,ccl,dcl,hinfo,ak,bk1,bk2,ck1,ck2,...
      dk11,dk12,dk21,dk22] = hinf(A,B1,B2,C1,C2,D11,D12,D21,D22,...
                                  AU,BU,CU,DU,disp_hinf);
   else
     error('Incompatible number or type of input arguments')
   end

%
% ------- Convert the w-plane solution back to z-plane:
%
%disp('   - - - - Transform the Controller via Bilinear Transform - - - -')
[acp,bcp,ccp,dcp] = bilin(acp,bcp,ccp,dcp,1,'Tustin',2);
[acl,bcl,ccl,dcl] = bilin(acl,bcl,ccl,dcl,1,'Tustin',2);
[aak,bbk,cck,ddk] = bilin(ak,[bk1 bk2],[ck1;ck2],[dk11,dk12;dk21,dk22],...
                    1,'Tustin',2);
dimk = [size(ak)*[1;0],size(bk1)*[0;1],size(bk2)*[0;1],...
        size(ck1)*[1;0],size(ck2)*[1;0]];
[ak,bk1,bk2,ck1,ck2,dk11,dk12,dk21,dk22] = asys2ss([aak bbk;cck ddk],dimk);
%
% -------- Convert to system matrices:
%

   if xsflag
     % Case     [SS_CP,SS_CL,HINFO,TSS_K]=HINF(TSS_P,SS_U,..)
     acp=mksys(acp,bcp,ccp,dcp);
     if nag2>1,
           bcp=mksys(acl,bcl,ccl,dcl);
           ccp=hinfo;
           if nag2>3,
             dcp=mksys(ak,bk1,bk2,ck1,ck2,dk11,dk12,dk21,dk22,'tss');
           end
     end
   end

%
% --------- End of DHINF.M  % RYC/MGS %