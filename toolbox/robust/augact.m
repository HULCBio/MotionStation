%AUGACT Two-port plant augmentation using AUGMENT.M.

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.

disp(' ')
disp(' ')
disp('                << Plant Augmentation >>')
Gam = input('           Input cost coefficient "Gam" = ');
[aw1,bw1,cw1,dw1] = tf2ss(Gam*dnw1i,nuw1i); sysw1 = [aw1 bw1;cw1 dw1];
[aw3,bw3,cw3,dw3] = tf2ss(dnw3i,nuw3i);     sysw3 = [aw3,bw3;cw3 dw3];
sysw2 = []; sysg = [ag bg;cg dg]; dim = [3 2 0 1];
[A,B1,B2,C1,C2,D11,D12,D21,D22] = augment(sysg,sysw1,sysw2,sysw3,dim);
disp('  ')
disp('     - - - State-Space (A,B1,B2,C1,C2,D11,D12,D21,D22) is ready for')
disp('           the Small-Gain problem - - -')
%
% -------- End of AUGACT.M --- RYC/MGS %