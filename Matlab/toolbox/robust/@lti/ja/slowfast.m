% SLOWFAST ��ԋ��slow/fast���[�h����
%
% [SS_1,SS_2] = SLOWFAST(SS_,CUT)�A�܂��́A
% [A11H,B1H,C1H,D1H,A22H,B2H,C2H,D2H] = SLOWFAST(A,B,C,D,CUT) �́AG(s)��
% slow���[�hGs(s)��fast���[�hGf(s)�ɕ������܂��B
%
%                 G(s) = Gs(s) + Gf(s)
%     �����ŁA
%                 Gs(s):= ss_1 = mksys(a11h,b1h,c1h,d1h);
%                 cut = Gs(s)�̃��[�h�̐�
%                 Gf(s):= ss_2 = mksys(a22h,b2h,c2h,d2h);
%
% "branch"���g���āA��ʓI�ȏ�ԋ�ԕ\���ɓW�J�ł��܂��B



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
