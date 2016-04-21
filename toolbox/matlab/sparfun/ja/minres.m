% MINRES  �ŏ��c���@ 

% X = MINRES(A,B) �́A���`������ A*X = B �̍ŏ��m�����c���������߂܂��B
% N �s N ��̌W���s�� A �́A�Ώ̂ł��邱�Ƃ��K�v�ł����A����ł���K�v��
% ����܂���B�E�ӂ̗�x�N�g�� B �́A������ N �ł���K�v������܂��B
% A �� A'*X ���o�͂���֐��ł��B
%
% MINRES(A,B,TOL) �́A���@�̃g�������X���w��ł��܂��BTOL �� [] �̏ꍇ�́A
% MINRES �̓f�t�H���g��1e-6���g���܂��B
%
% MINRES(A,B,TOL,MAXIT) �́A�J��Ԃ��ő�񐔂�ݒ肵�܂��BMAXIT �� [] 
% �̏ꍇ�́AMINRES �̓f�t�H���g�� min(N,20) ���g���܂��B
%
% MINRES(A,B,TOL,MAXIT,M) �� MINRES(A,B,TOL,MAXIT,M1,M2) �́A�Ώ̐���
% �̑O����� M �܂��� M = M1*M2 ���g���A�V�X�e�� 
% inv(sqrt(M))*A*invv(sqrt(M))*Y = inv(sqrt(M))*B �� Y �ɂ��āA����
% �ǂ������܂��B�����ŁAX = inv(sqrt(M))*Y ���o�͂��܂��BM ��[] �̏ꍇ�́A
% �O������͓K�p����܂���BM �́AM'\X ���o�͂���֐��ł��B
%
% MINRES(A,B,TOL,MAXIT,M1,M2,X0) �́A��������l��ݒ肵�܂��BX0 �� [] 
% �̏ꍇ�́AMINRES �̓f�t�H���g�̂��ׂĂ��[���v�f���g���܂��B
%
% MINRES(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) �́A�p�����[�^
% P1,P2,...���֐� AFUN(X,P1,P2,...),M1FUN(X,P1,P2,...), M2FUN(X,P1,P2,...)
% �ɓn���܂��B
%
% [X,FLAG] = MINRES(A,B,TOL,MAXIT,M1,M2,X0) �́A�����Ɋւ����� FLAG 
% ���o�͂��܂��B
% 
%    0 MINRES �́AMAXIT �J��Ԃ��͈͓̔��Ŋ�]����g�������X TOL �Ɏ���
%      ���܂��B
%    1 MINRES �́AMAXIT ��J��Ԃ��܂������A�������܂���B
%    2 �O����� M �̏�����������
%    3 MINRES ���@�\���܂���(2��̘A������J��Ԃ��̌��ʂ�����)
%    4 MINRES �̊ԁA�v�Z�����X�J���ʂ�1���A�v�Z�𑱂���ɂ͑傫
%      �����邩�A�܂��͏�����
%    5 �O������q M ���Ώ̐���łȂ�
%
% [X,FLAG,RELRES] = MINRES(A,B,TOL,MAXIT,M1,M2,X0) �́A���Ύc�� 
% NORM(BA*X)/NORM(B) ���o�͂��܂��BFLAG ��0�̏ꍇ�́ARELRES <= TOL �ł��B
%
% [X,FLAG,RELRES,ITER] = MINRES(A,B,TOL,MAXIT,M1,M2,X0) �́AX ���v�Z
% ���ꂽ�Ƃ��̌J��Ԃ��񐔂��o�͂��܂��B 0 <= ITER <= MAXIT�B
%
% [X,FLAG,RELRES,ITER,RESVEC] = MINRES(A,B,TOL,MAXIT,M1,M2,X0) �́A
% �e�J��Ԃ��ŁANORM(B-A*X0) ���܂� MINRES �c���m�����̐���̃x�N�g����
% �o�͂��܂��B
%
% [X,FLAG,RELRES,ITER,RESVEC,RESVECCG] = MINRES(A,B,TOL,MAXIT,M1,M2,X0) 
% �́A�e�J��Ԃ��ł̋������z�c���m�����̃x�N�g�����o�͂��܂��B
%
% ���F
%   n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -2*on],-1:1,n,n);
%   b = sum(A,2); tol = 1e-10; maxit = 50; M1 = spdiags(4*on,0,n,n);
%   x = minres(A,b,tol,maxit,M1,[],[]);
% ���̍s��-�x�N�g���ϊ֐����g�p
%      function y = afun(x,n)
%      y = 4 * x;
%      y(2:n) = y(2:n) - 2 * x(1:n-1);
%      y(1:n-1) = y(1:n-1) - 2 * x(2:n);
%
% MINRES �ւ̓��͂Ƃ��ė��p���܂��B
%      x1 = minres(@afun,b,tol,maxit,M1,M2,[],[]);
%
% �Q�l�FBICG, BICGSTAB, CGS, GMRES, LSQR, PCG, QMR, SYMMLQ, @.


%   Penny Anderson, 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $ $Date: 2004/04/28 02:02:45 $
