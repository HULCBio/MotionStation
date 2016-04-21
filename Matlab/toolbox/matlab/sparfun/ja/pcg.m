% PCG    �O������t�������X�Ζ@
%
% X = PCG(A,B) �́AX �Ɋւ�����`������ A*X = B �������܂��BN �s N ���
% �W���s�� A �͑Ώ̂�����ŁA�E�ӂ̗�x�N�g�� B �͒����� N �ł���K�v
% ������܂��BA �́AA'*X ���o�͂���֐��ł��B
%
% PCG(A,B,TOL) �́A���@�̃g�������X���w��ł��܂��BTOL �� [] �̏ꍇ�́A
% PCG �̓f�t�H���g��1e-6���g���܂��B
%
% PCG(A,B,TOL,MAXIT) �́A�J��Ԃ��ő�񐔂�ݒ肵�܂��BMAXIT ��[] ��
% �ꍇ�́APCG �̓f�t�H���g�� min(N,20)���g���܂��B
%
% PCG(A,B,TOL,MAXIT,M) �� PCG(A,B,TOL,MAXIT,M1,M2) �́A�Ώ̂������
% �O����� M �܂��� M = M1*M2 ���g���A�V�X�e�� inv(M)*A*X = inv(M)*B ��
% X �ɂ��Č����ǂ������܂��BM �� [] �̏ꍇ�́A�O������͓K�p����܂���B
% M�́AM'\X ���o�͂���֐��ł��B
%
% PCG(A,B,TOL,MAXIT,M1,M2,X0) �́A��������l���w�肵�܂��BX0 �� [] ��
% �ꍇ�́APCG �̓f�t�H���g�̂��ׂĂ��[���v�f���g���܂��B
%
% PCG(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) �́A�p�����[�^P1,P2,...
% ���֐� AFUN(X,P1,P2,...), M1FUN(X,P1,P2,...), M2FUN(X,P1,P2,...) ��
% �n���܂��B
%
% [X,FLAG] = PCG(A,B,TOL,MAXIT,M1,M2,X0) �́A�����Ɋւ����� FLAG ��
% �o�͂��܂��B
% 
%    0 PCG �́AMAXIT �J��Ԃ��͈͓̔��Ŋ�]����g�������X TOL ��
%      �������܂��B
%    1 PCG �́AMAXIT ��J��Ԃ��܂������A�������܂���B
%    2 �O����� M �̏�����������
%    3 PCG ���@�\���܂���(2��̘A������J��Ԃ��̌��ʂ�����)
%    4 PCG �̊ԁA�v�Z�����X�J���ʂ�1���A�v�Z�𑱂���ɂ͑傫
%      �����邩�A�܂��͏�����
%
% [X,FLAG,RELRES] = PCG(A,B,TOL,MAXIT,M1,M2,X0) �́A���Ύc�� 
% NORM(B-A*X)/NORM(B) ���o�͂��܂��BFLAG ��0�̏ꍇ�́ARELRES <= TOL �ł��B
%
% [X,FLAG,RELRES,ITER] = PCG(A,B,TOL,MAXIT,M1,M2,X0) �́AX ���v�Z���ꂽ
% �Ƃ��̌J��Ԃ��񐔂��o�͂��܂��B 0 <= ITER <= MAXIT�B
%
% [X,FLAG,RELRES,ITER,RESVEC] = PCG(A,B,TOL,MAXIT,M1,M2,X0) �́A�e�J��
% �Ԃ��ł̎c���m�����̃x�N�g�� NORM(B-A*X0) ���o�͂��܂��B
%
% ���F
%      A = gallery('wilk',21);  b = sum(A,2);
%      tol = 1e-12;  maxit = 15; M1 = diag([10:-1:1 1 1:10]);
%      x = pcg(A,b,tol,maxit,M1,[],[]);
% �܂��́A����1���C���s��ƃx�N�g���̐ς̊֐����g���܂��B
%      function y = afun(x,n)
%      y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'] .*x + ...
%      [x(2:n); 0];
% �����āA1���C���O������̌�މ�@�֐����g���܂��B
%      function y = mfun(r,n)
%      y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
% PCG �ւ̓��͂Ƃ��ė��p���܂��B
%      x1 = pcg(@afun,b,tol,maxit,@mfun,[],[],21);
%
% �Q�l�FBICG, BICGSTAB, CGS, GMRES, LSQR, MINRES, QMR, SYMMLQ, CHOLINC, @.


%   Penny Anderson, 1996.
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $ $Date: 2004/04/28 02:02:49 $
