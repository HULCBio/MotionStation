%EPS  ���������_���ԋ���
% D = EPS(X) �́AABS(X) ���� X �Ɠ������x�ő傫�������ɑ傫�ȕ��������_��
% �܂ł̐��̋����ł��BX �́A�{���x�A�܂��́A�P���x�̂����ꂩ�ɂȂ�܂��B
% ���ׂĂ� X �ɑ΂��āAEPS(X) = EPS(-X) = EPS(ABS(X)) �ł��B
%
% EPS �́A�������Ȃ��ꍇ�A1.0 ������ɑ傫�Ȕ{���x�̐��܂ł̋����A
% ���Ȃ킿�AEPS = 2^(-52) �ł��B
%
% EPS('double') �́AEPS, �܂��́AEPS(1.0) �Ɠ����ł��B
% EPS('single') �́AEPS(single(1.0)), �܂��� single(2^-23) �Ɠ����ł��B
%
% �񐳋K����(denormals)�������āA2^E <= ABS(X) < 2^(E+1) �̏ꍇ�A�������藧���܂��B
%      EPS(X) = 2^(E-23) if ISA(X,'single')
%      EPS(X) = 2^(E-52) if ISA(X,'double')
%
%      if Y < EPS * ABS(X)
% �Ƃ����`���̕\�����A���ɒu�������Ă��������B
%      if Y < EPS(X)
%
% ���:
%      �{���x
%         eps(1/2) = 2^(-53)
%         eps(1) = 2^(-52)
%         eps(2) = 2^(-51)
%         eps(realmax) = 2^971
%         eps(0) = 2^(-1074)
%         if(abs(x)) <= realmin, eps(x) = 2^(-1074)
%         eps(Inf) = NaN
%         eps(NaN) = NaN
%      �P���x
%         eps(single(1/2)) = 2^(-24)
%         eps(single(1)) = 2^(-23)
%         eps(single(2)) = 2^(-22)
%         eps(realmax('single')) = 2^104
%         eps(single(0)) = 2^(-149)
%         if(abs(x)) <= realmin('single'), eps(x) = 2^(-149)
%         eps(single(Inf)) = single(NaN)
%         eps(single(NaN)) = single(NaN)
%
% �Q�l REALMAX, REALMIN.
%
%   Copyright 1984-2002 The MathWorks, Inc.
