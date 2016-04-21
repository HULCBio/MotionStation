% BICGSTAB �@�o�����X�Έ��艻�@
%
% X = BICGSTAB(A,B) �́AX �Ɋւ�����`������ A*X = B �������܂��BN �s 
% N ��̌W���s�� A �͐����ŁA�E�ӂ̗�x�N�g�� B �͒����� N �ł���K�v
% ������܂��BA �́AA'*X ���o�͂���֐��ł��B
%
% BICGSTAB(A,B,TOL) �́A���@�̒��Ƀg�������X���w��ł��܂��BTOL �� []
% �̏ꍇ�́ABICGSTAB �̓f�t�H���g��1e-6���g���܂��B
%
% BICGSTAB(A,B,TOL,MAXIT) �́A�J��Ԃ��ő�񐔂�ݒ肵�܂��BMAXIT ��
% [] �̏ꍇ�́ABICGSTAB �̓f�t�H���g�� min(N,20)���g���܂��B
%
% BICGSTAB(A,B,TOL,MAXIT,M) �� BICGSTAB(A,B,TOL,MAXIT,M1,M2) �́A
% �O����� M �܂��� M = M1*M2 ���g���A�V�X�e�� inv(M)*A*X = inv(M)*B 
% �� X �ɂ��āA�����ǂ������܂��BM �� [] �̏ꍇ�́A�O������͓K�p����
% �܂���BM �́AM'\X ���o�͂���֐��ł��B
%
% BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) �́A��������l��ݒ肵�܂��BX0 �� 
% [] �̏ꍇ�́ABICGSTAB �̓f�t�H���g�̂��ׂĂ��[���v�f���g���܂��B
%
% BICGSTAB(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) �́A�p�����[�^ 
% P1,P2,... ���֐� AFUN(X,P1,P2,...), M1FUN(X,P1,P2,...), 
% M2FUN(X,P1,P2,...) �ɓn���܂��B
%
% [X,FLAG] = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) �́A�����Ɋւ����� 
% FLAG ���o�͂��܂��B
% 
%    0 BICGSTAB �́AMAXIT �J��Ԃ��͈͓̔��ŁA��]����g�������X TOL 
%      �Ɏ������܂��B
%    1 BICGSTAB �́AMAXIT ��J��Ԃ��܂������A�������܂���B
%    2 �O����� M �̏�����������
%    3 BICGSTAB ���@�\���܂���(2��̘A������J��Ԃ��̌��ʂ�����)
%    4 BICGSTAB �̊ԁA�v�Z�����X�J���ʂ�1���A�v�Z�𑱂���ɂ�
%      �傫�����邩�A�܂��͏�����
%
% [X,FLAG,RELRES] = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) �́A���Ύc�� 
% NORM(B-A*X)/NORM(B) ���o�͂��܂��BFLAG ��0�̏ꍇ�́ARELRES <= TOL �ł��B
%
% [X,FLAG,RELRES,ITER] = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) �́AX ���v�Z
% ���ꂽ�Ƃ��̌J��Ԃ��񐔂��o�͂��܂��B 0 <= ITER <= MAXIT�BITER �́A
% ���� +0.5 �ŁA�J��Ԃ���ʂ��āA�Б��̎����������܂��B
%
% [X,FLAG,RELRES,ITER,RESVEC] = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) �́A
% �e�J��Ԃ��ł̎c���m�����̃x�N�g�� NORM(B-A*X0) ���o�͂��܂��B
%
% ���F
%  A = gallery('wilk',21);  b = sum(A,2);
%  tol = 1e-12;  maxit = 15; M1 = diag([10:-1:1 1 1:10]);
%  x = bicgstab(A,b,tol,maxit,M1,[],[]);
% �܂��́A���̍s��ƃx�N�g���̐ς̊֐����g���܂��B
%  function y = afun(x,n)
%  y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'] .*x + [x(2:n); 0];
% �����āA�O������̌�މ�@�֐����g���܂��B
%   function y = mfun(r,n)
%   y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
%  BICGSTAB �ւ̓��͂��s���܂��B
%   x1 = bicgstab(@afun,b,tol,maxit,@mfun,[],[],21);
% afun �� mfun �̗����Ƃ� BICGSTAB �̒ǉ����� n = 21 ���󂯓���Ȃ����
% �Ȃ�Ȃ����Ƃɒ��ӂ��Ă��������B
%
% �Q�l�FBICG, CGS, GMRES, LSQR, MINRES, PCG, QMR, SYMMLQ, LUINC, @.


%   Penny Anderson, 1996.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:02:28 $
