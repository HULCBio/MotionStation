%LINF Continuous L-Infinity control synthesis.
%
% ----------------------------------------------------------------
%       L-inf optimization for Multivariable Feedback Systems
%
%       LINF (MATLAB) Ver. 2.0 -- R. Y. Chiang & M. G. Safonov
% ----------------------------------------------------------------
% LINF solves the infinity-norm control problem via the Youla
%      parameterization and optimal Hankel approximation.
%
%      Input data: augmented plant
%                 (A,B1,B2,C1,C2,D11,D12,D21,D22) (Note: in upper case !!)
%
%      Output data: controller F(s) := (acp,bcp,ccp,dcp)
%                   CLTF Ty1u1 := (acl,bcl,ccl,dcl)
%

% R. Y. Chiang & M. G. Safonov 6/86
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------------
helplinf
disp('  ')
disp('(strike a key to start LINF computation (if the input data are ready..)')
pause
clc
disp('  ')
disp('  ')
disp('     << LINF Optimal Control Synthesis via Descriptor Hankel MDA >>');
%
flagcase1 = exist('b1');
flagcase2 = exist('B1');
if (flagcase1 > 0) & (flagcase2 < 1)
 error('   THIS SCRIPT FILE REQUIRES THE INPUT VARIABLE NAMES IN UPPER CASE !!!')
end
%
youla
%
if yulacase == 1
   hkl1
end
%
if yulacase == 2
   hkl2
end
%
if yulacase == 3
   hkl3
end
%
if yulacase == 4
   hkl4
end
syscp = [acp bcp;ccp dcp]; xcp = size(acp)*[1;0];
syscl = [acl bcl;ccl dcl]; xcl = size(xcl)*[1;0];
%
% ------ End of LINF.M --- % RYC/MGS %