% HYPERBOLIC   �o�Ȑ��^ PDE ���������܂��B
%
% U1 = HYPERBOLIC(U0,UT0,TLIST,B,P,E,T,C,A,F,D) �́AP, E, T �ŋL�q�����
% ���b�V����ŁAB �ɂ���ė^����ꂽ���E�����Ə����l U0 �Ɠ��֐��̏����l
% UT0 �����X�J�� PDE ��� d*d^2u/dt^2-div(c*grad(u))+a*u = f �� FEM �`
% ���ɍ��킹�ĉ������܂��B
%
% �X�J���̏ꍇ�A���s�� U1 �̊e�s�́AP �őΉ����Ă����ɂ���ė^������
% ���W��ł̉��ł��BU1 �̊e��́ATLIST �őΉ����Ă��鍀�ڂɂ���ė^����
% ��鎞���ł̉��ł��BNP �ߓ_������ N �����̃V�X�e���̏ꍇ�AU1 �̍ŏ��� 
% NP �s�� u �̍ŏ��̐�����\�����A���� U1 �� NP �s�� u �̑�2�̐������A��
% �����悤�ɕ\�����܂��B���̂悤�ɂ��āAu �̐����́A�ߓ_�̍s���� N �u��
% �b�N�Ƃ��āA�u���b�N U �ɐݒ肵�܂��B
%
% B �́APDE ���̋��E������\���܂��BB �́ABoundary Condition �s��܂�
% �� Boundary M-�t�@�C���̃t�@�C�����̂ǂ���ł��\�ł��B�ڍׂ́APDEB-
% OUND ���Q�Ƃ��Ă��������B
%
% PDE ���̌W�� C, A, F, D �́A���푽�l�ȕ��@�ŗ^���邱�Ƃ��ł��܂��B��
% �ׂ́AASSEMPDE ���Q�Ƃ��Ă��������B
%
% U1 = HYPERBOLIC(U0,UT0,TLIST,B,P,E,T,C,A,F,D,RTOL) �� U1 = HYPERBOL-
% IC(U0,UT0,TLIST,B,P,E,T,C,A,F,D,RTOL,ATOL) �́A��΋��e�덷�Ƒ��΋��e
% �덷�� ODE �\���o�ɓn���܂��B
%
% U1 = HYPERBOLIC(U0,UT0,TLIST,K,F,B,UD,M) �́A�����l U0 �� UT0 ������ 
% ODE ��� B'*M*B*(d^2ui/dt^2)+K*ui = F, u = B*ui+ud �ɑ΂�������쐬��
% �܂��B
%
% �Q�l   ASSEMPDE, PARABOLIC



%       Copyright 1994-2001 The MathWorks, Inc.
