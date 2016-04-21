% BURGERSODE  Burger���������A�ړ����b�V�����@(moving mesh technique)��
%             �g���ĉ����܂��B
% 
% BURGERSODE(N) �́AN�_��(�ړ�)���b�V����ŁA
% u(x,0) = sin(2*pi*x) + 0.5*sin(pi*x) ����� u(0,t) = 0,u(1,t) = 0 ��
% �����Ƃ��A0 <= x <= 1�ɂ����āABurger������ 
% �@�@�@ Du/Dt = 1e-4*D^2 u/Dx^2 - D(0.5u^2)/Dx�@�@
% �������܂��B����́A���� Problem 2 �ł��B
% 
% W. Huang, Y. Ren, and R.D. Russell, Moving mesh methods based on
% moving mesh partial differential equations, J. Comput. Phys. 113(1994)
% 279-290.
% 
% ���̘_���ł́ABurger �������́A(19)�œW�J���Ă���悤�ɒ���������
% ���U�����āA�g�p�����ړ����b�V�� PDE �́Atau = 1e-3 �ł��� MMPDE6 �ł��B
% �} 6 �́AN = 20 �ŁAgamma = 2 ,p = 2 �ŋ�ԕ��������s��ꂽ���̂ł��B
% �����āA���Ό덷���e�͈� 1e-5�A��Ό덷���e�͈� 1e-4 ���g���܂��B
%
% ���̗�ł́A�����v���b�g�������̂͐}6 �Ɏ��Ă��܂����A�����f�[�^��
% �v���b�g����A��肪 t = 1 �ł̂ݐϕ�����Ă���̂ŁA���s���Ԃ����Ȃ�
% �Ȃ��Ă��܂��B���x�N�g�����Ay = (a1,...,aN,x1,...,xN)�Ƃ��܂��B
% ���� t �ŁAaj ��PDE�̉� u(t,xj) ���ߎ����܂��B���b�V���_ xj ��
% ���Ԃ̊֐��ŉ������ ODE�̒��� y �ɁA���ʍs��̋����ˑ����������点�܂��B
% ���̗��ɂ����āA���ʍs��̋�����Ԉˑ�����F�����X�p�[�X�����l�����邱�Ƃ́A% ���ɗL���Ȃ��Ƃł��B
%
% ���� : ���̕ϐ��̏��ԕt���́A�������̃R�[�h���ɕ֗��ł����A�эs���
% ���p�ł��Ȃ��Ƃ������_�������Ă��܂��B����́ALSODI �܂��� DASSL ��
% ode15s ����ʂ��܂��B��ʓI�ȃX�p�[�X�s��ɑ΂��ė^����ꂸ�A�܂� 
% dF/dy �� dMy/dy �̃X�p�[�X�p�^�[���̈Ⴂ�ɑ΂��Ă��^�����܂���B
% ���̗��ł́AdMy/dy �� dF/dy �����傫���X�p�[�X���������܂��B
%
% �Q�l�FODE15S, ODE23T, ODE23TB, ODESET, @.


%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
