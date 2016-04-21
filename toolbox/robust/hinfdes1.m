% A function for use with the h-infinity Control Toolbox demonstration

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $
format short e
clear ae be ce de;
sys = ss(a,b,c,d);
[aw1,bw1,cw1,dw1] = tf2ss(den1,num1); sysw1 = ss(aw1,bw1,cw1,dw1);
[aw2,bw2,cw2,dw2] = tf2ss(num2,den2); sysw2 = ss(aw2,bw2,cw2,dw2);
[aw3,bw3,cw3,dw3] = tf2ss(den3,num3); sysw3 = ss(aw3,bw3,cw3,dw3);
clear aw1 aw2 aw3 bw1 bw2 bw3 cw1 cw2 cw3 dw1 dw2 dw3
disp('Use AUGMENT to construct the augmented plant');
disp('   ');
sys_=augss(sys,sysw1,sysw2,sysw3,0);
disp('Build a balanced system using OBALREAL');
disp('   ');
[A,B1,B2,C1,C2,D11,D12,D21,D22]=branch(sys_);
[aa,bb,cc,mm,tt] = obalreal(A,[B1 B2],[C1;C2]);
A = aa; B1 = bb(:,1); B2 = bb(:,2); C1 = cc(1:3,:); C2 = cc(4,:);
sys_ = rct2lti(mksys(A,B1,B2,C1,C2,D11,D12,D21,D22,'tss'));
disp('   ');
disp('Use HINF to design an H_INF controller');
disp('   ');
[ss_cp]=hinf(sys_);
[ae,be,ce,de]=ssdata(ss_cp);
clear A B1 B2 C1 C2 D11 D12 D21 D22 aa bb cc sysw1 sysw2 sysw3 ss_cp
disp('Done')





