% STABPROJ ��ԋ�� ����/�s���胂�[�h����
%
% [SS_1,SS_2,M] = STABPROJ(SS_)�A�܂��́A
% [A11H,B1H,C1H,D1H,A22H,B2H,C2H,D2H,M] = STABPROJ(A,B,C,D) �́AG(s)����
% �胂�[�hG1(s)�ƕs���胂�[�hG2(2)�ɕ������܂��B�����ŁA
%
%                  G(s):= ss_ = mksys(a,b,c,d);
%                  G1(s):= ss_1 = mksys(a11h,b1h,c1h,d1h);
%                  G2(s):= ss_2 = mksys(a22h,b2h,c2h,d2h);
%
% "branch"���g���āA��ʓI�ȏ�ԋ�ԕ\���ɓW�J�ł��܂��B



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
