% GFDECONV   �K���A�̏�̑������̏��Z
%
% [Q, R] = GFDECONV(B, A) �́AGF(2) �� B �� A �ŏ��Z���A�� Q �Ə�] R ��
% �v�Z���܂��B
%
% A, B, Q, R �́A���x�L�̏��ɕ��񂾑������W���������A�s�x�N�g���ł��B
%
% [Q, R] = GFDECONV(B, A, P) �́AGF(P) �� B �� A �ŏ��Z���A�� Q �Ə�] R
% ���v�Z���܂��B�����ŁAP �̓X�J���̑f���ł��B
%
% [Q, R] = GFDECONV(B, A, FIELD) �́A2�� GF(P^M) �������Ԃŏ��Z���A 
% �� Q �Ə�] R ���v�Z���܂��B������ FIELD �� GF(P^M) �̑S����M-�^�v����
% �܂ލs��ł��BP�͑f���ŁAM�͐��̐����ł��BGF(P^M) �̑S����M-�^�v����
% ��������ɂ́AFIELD = GFTUPLE([-1:P^M-2]', M, P) ���g���Ă��������B
%
% ���̃V���^�b�N�X�ł́A�e�W���͎w���`���Ŏw�肳��܂��B�܂�A
% [-Inf, 0, 1, 2, ...] �� GF(P^M) �̑̌� [0, 1, alpha, alpha^2, ...] ��
% �\�����܂��B
%
% ���:
%     GF(5)��ł̏��Z: (1+ 3x+ 2x^3+ 4x^4)/(1+ x) = (1+ 2x+ 3x^2+ 4x^3)
%        [q, r] = gfdeconv([1 3 0 2 4], [1 1], 5)
%     q = [1 2 3 4], r = 0 ��Ԃ��܂��B
%
%     GF(2^4)��ł̏��Z:
%        field = gftuple([-1:2^4-2]', 4, 2);
%        [q, r] = gfdeconv([2 6 7 8 9 6],[1 1],field)
%     q = [1 2 3 4 5], r = -Inf ��Ԃ��܂��B
%
% GF(P) �܂��� GF(P^M) ��̗v�f���Ƃ̏��Z�ɂ��ẮAGFDIV ���Q�Ƃ���
% ���������B
%
% �Q�l�F GFCONV, GFADD, GFSUB, GFTUPLE.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $Date: 2003/06/23 04:34:34 $
