%NUMJAC �֐� F(T,Y)�� ���R�r�A�� dF/dY �𐔒l�I�Ɍv�Z���܂�
%
% [DFDY,FAC] = NUMJAC(F,T,Y,FTY,THRESH,FAC,VECTORIZED) 
% T �͓Ɨ��ϐ��ŁA��x�N�g�� Y �͏]���ϐ����܂�ł��܂��B�֐� F �́A��
% �x�N�g����߂��܂��B�x�N�g�� FTY �́A(T,Y)�Ōv�Z���� F �ł��B��x�N�g�� 
% THRESH �́AY �ɑ΂���M�����x���̃X���b�V���z�[���h�ł��B���Ȃ킿�A
% abs(Y(i)) < THRESH(i) �𖞂����v�f Y(i) �̐��m�Ȓl�͏d�v�ł͂���܂���B
% THRESH �̂��ׂĂ̗v�f�́A���łȂ���΂Ȃ�܂���B�� FAC �́A���[�L
% ���O�X�g���[�W�ł��B�ŏ��̃R�[���ł́AFAC �� []�ɐݒ肵�܂��B�R�[����
% �ԂŖ߂�l��ύX�ł��܂���BVECTORIZED �́ANUMJAC �ɁAF �̕�����
% �l���P��֐��v�Z�œ����邩�ۂ���`������̂ł��B���ɁA
% VECTORIZED=1 �́AF(t,[y1 y2 ...]) ���A[F(t,y1) F(t,y2) ...] ��߂��A
% VECTORIZED=2 �́AF([x1 x2 ...] ,[y1 y2 ...]) ���A[F(x1,y1) F(x2,y2) ...] 
% ��߂����Ƃ������܂��BODE���������Ƃ��AODE �֐��ŁAF(t,[y1 y2 ...]) ��
% [F(t,y1) F(t,y2) ...] ���o�͂���悤�ɃR�[�h������Ă���ꍇ�AODESET��
% �g���āAODE�\���o'Vectorized'�v���p�e�B�� 'on' �ɐݒ肵�܂��BBVP����
% �����Ƃ��AODE �֐��ŁAF([x1 x2 ...],[y1 y2 ...]) �� [F(x1,y1) F(x2,y2) ...] 
% ���o�͂���悤�ɃR�[�h������Ă���ꍇ�ABVPSET ���g����BVP �\���o��
% 'Vectorized'�v���p�e�B�� 'on' �ɐݒ肵�܂��B�֐� F ���x�N�g�������邱�Ƃ́A
% DFDY �̌v�Z�̃X�s�[�h���A�b�v���邱�ƂɂȂ�܂��B
%   
% [DFDY,FAC,G] = NUMJAC(F,T,Y,FTY,THRESH,FAC,VECTORIZED,S,G) �́A
% �X�p�[�XJacobian �s�� DFDY �𐔒l�I�Ɍv�Z���܂��BS �́A0��1����\��
% ������łȂ��X�p�[�X�s��ł��BS(i,j) �̒���0 �̒l�́A�֐� F(T,Y) ��
% i �������A�x�N �g�� Y �� j �����Ɉˑ����Ă��Ȃ����Ƃ������܂�(���Ȃ킿�A
% DFDY(i,j)=0�ł�)�B��x�N�g�� G �́A���[�L���O�X�g���[�W�ł��B�ŏ��̃R�[
% ���ł́AG ��[]�ɐݒ肵�Ă��������B�R�[���̊ԁA�߂�l��ύX���܂���B
%   
% [DFDY,FAC,G,NFEVALS,NFCALLS] = NUMJAC(...) �́AdFdy���쐬����Ԃ�
% �v�Z�����l�̐�(NFEVALS)�Ɗ֐�F�̌Ăяo����(NFCALLS)���o�͂���
% ���BF ���x�N�g��������Ȃ��ꍇ�ANFCALLS ��NFEVALS �Ɠ������Ȃ�܂��B
%
% ODE����ϕ�����ꍇ�A�Δ����W���̋ߎ��ɑ΂��āANUMJAC �͓���
% �ɊJ������Ă��܂����A���̃A�v���P�[�V�����ɂ��g�����Ƃ��ł��܂��B���ɁA
% F(T,Y)�Ŗ߂����x�N�g���̒�����Y �̒����ƈقȂ�ꍇ�ADFDY �͒����`
% �ɂȂ�܂��B
%   
% �Q�l COLGROUP, ODE15S, ODE23S, ODE23T, ODE23TB, ODESET.

% NUMJAC �́A������������n Y' = F(T,Y) ��ϕ�����ꍇ�A�Γ��֐��̋ߎ�
% �̂��߂ɁA Salane �ɂ����Ƀ��o�X�g�ȃX�L�[�������s���܂��B����́A
% ODE �R�[�h������ T �ŋߎ� Y �������AT+H �ɐi�ޏꍇ�A�Ăяo����܂��B
% ODE �R�[�h�́AY �̌덷���΋��e�덷 ATOL = THRESH �����������Ȃ�
% �悤�ɐ��䂵�܂��B�O�̃X�e�b�v�ŁA�Γ��֐��̌v�Z�́A FAC �ɋL�^����
% �Ă��܂��B�X�p�[�X���R�r�A���́A�֐� F �ɑ΂���1�x�̌Ăяo���ŋߎ�
% �ł���ADFDY �̗�̃O���[�v�������邽�߂ɁACOLGROUP(S) ���g�p����
% �����I�Ɍv�Z����܂��BCOLGROUP �́A2�̃X�L�[��
% (first-fit and first-fit after reverse COLAMD ordering) 
% �����s���A���ǂ��O���[�s���O���o�͂��܂��B
%   
%   D.E. Salane, "Adaptive Routines for Forming Jacobians Numerically",
%   SAND86-1319, Sandia National Laboratories, 1986.
%   
%   T.F. Coleman, B.S. Garbow, and J.J. More, Software for estimating
%   sparse Jacobian matrices, ACM Trans. Math. Software, 11(1984)
%   329-345.
%   
%   L.F. Shampine and M.W. Reichelt, The MATLAB ODE Suite, SIAM Journal on
%   Scientific Computing, 18-1, 1997.

%   Mark W. Reichelt and Lawrence F. Shampine, 3-28-94
%   Copyright 1984-2002 The MathWorks, Inc. 
