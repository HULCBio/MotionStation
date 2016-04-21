% LAPLACE   ���v���X�ϊ�
% L = LAPLACE(F) �́A�f�t�H���g�̓Ɨ��ϐ� t �����X�J���V���{���b�N�I�u
% �W�F�N�gF �̃��v���X�ϊ��ł��B�f�t�H���g�̏o�͂́As �̊֐��ł��BF = F
% (s) �Ȃ�΁ALAPLACE �́At �̊֐� L = L(t) ���o�͂��܂��B
% 
% ��`�ɂ��AL(s) = int(F(t)*exp(-s*t),0,inf) �ŁAt �ɂ��Đϕ������
% ���B
%
% L = LAPLACE(F, t) �́A�f�t�H���g�� s �̑���ɁAt �̊֐�L���v�Z���܂��B
% 
%      LAPLACE(F,t) <=> L(t) = int(F(x)*exp(-t*x),0,inf)
%
% L = LAPLACE(F, w, z) �́A�f�t�H���g�� s �̑���ɁAz �̊֐�L���v�Z��
% �܂�(w �ɂ��Đϕ����܂�)�B
%   
%     LAPLACE(F,w,z) <=> L(z) = int(F(w)*exp(-z*w),0,inf)
%
% ��� :
%      syms a s t w x
%      laplace(t^5) �́A120/s^6 ���o�͂��܂��B
%      laplace(exp(a*s)) �́A1/(t-a) ���o�͂��܂��B
%      laplace(sin(w*x),t) �́Aw/(t^2+w^2) ���o�͂��܂��B
%      laplace(cos(x*w),w,t) �́At/(t^2+x^2) ���o�͂��܂��B
%      laplace(x^sym(3/2),t) �́A3/4*pi^(1/2)/t^(5/2) ���o�͂��܂��B
%      laplace(diff(sym('F(t)'))) �́Alaplace(F(t),t,s)*s-F(0) ���o�͂�
%      �܂��B
%
% �Q�l�F ILAPLACE, FOURIER, ZTRANS.



%   Copyright 1993-2002 The MathWorks, Inc.
