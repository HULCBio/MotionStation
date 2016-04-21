% BICG   �o�����X�Ζ@
%
% X = BICG(A,B) �́AX �Ɋւ�����`������ A*X = B �������܂��BN �s N ��
% �̌W���s�� A �͐����ŁA�E�ӂ̗�x�N�g�� B �� ������ N �ł���K�v��
% ����܂��BA �́AAFUN(X) �� A*X ���o�͂��A AFUN(X,'transp') �� A'*X ��
% �o�͂���悤�Ȋ֐��ł��B
%
% BICG(A,B,TOL) �́A���@�̒��Ƀg�������X���w��ł��܂��BTOL �� [] ��
% �ꍇ�́ABICG �� �f�t�H���g��1e-6���g���܂��B
%
% BICG(A,B,TOL,MAXIT) �́A�J��Ԃ��ő�񐔂�ݒ肵�܂��BMAXIT ��[]��
% �ꍇ�́ABICG �̓f�t�H���g�� min(N,20)���g���܂��B
%
% BICG(A,B,TOL,MAXIT,M) �� BICG(A,B,TOL,MAXIT,M1,M2) �́A�O����� M�A
% �܂��� M = M1*M2 ���g���A�V�X�e�� inv(M)*A*X = inv(M)*B �� X �ɂ��āA
% �����ǂ������܂��BM �� [] �̏ꍇ�́A�O������͓K�p����܂���B
% M �́AMFUN(X) �� M\X ���o�͂��AMFUN(X,'transp') �� M'\X ���o�͂���
% �悤�Ȋ֐� MFUN �ł��B
%
% BICG(A,B,TOL,MAXIT,M1,M2,X0) �́A��������l��ݒ肵�܂��BX0 �� [] ��
% �ꍇ�́A�ABICG �̓f�t�H���g�̂��ׂĂ��[���v�f���g���܂��B
%
% BICG(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) �́A�֐� AFUN �Ƀp��
% ���[�^ P1,P2,...��n���܂��B�����ŁAAFUN �́AAFUN(X,P1,P2,...) ��
% AFUN(X,P1,P2,...,'transp') �Ƃ��Ďg�p���A�O������֐� M1FUN �� M2FUN 
% �Ɠ��l�ł��B
%
% [X,FLAG] = BICG(A,B,TOL,MAXIT,M1,M2,X0) �́A�����Ɋւ����� FLAG 
% ���o�͂��܂��B
% 
%    0 BICG �́AMAXIT �J��Ԃ��͈͓̔��Ŋ�]����g�������X TOL �Ɏ�����
%      �܂��B
%    1 BICG �́AMAXIT ��J��Ԃ��܂������A�������܂���B
%    2 �O����� M �̏�����������
%    3 BICG ���@�\���܂���(2��̘A������J��Ԃ��̌��ʂ�����)
%    4 BICG �̊ԁA�v�Z�����X�J���ʂ�1���A�v�Z�𑱂���ɂ�
%      �傫�����邩�A�܂��͏�����
%
% [X,FLAG,RELRES] = BICG(A,B,TOL,MAXIT,M1,M2,X0) �́A���Ύc�� 
% NORM(B-A*X)/NORM(B) ���o�͂��܂��BFLAG ��0�̏ꍇ�́ARELRES <= TOL �ł��B
%
% [X,FLAG,RELRES,ITER] = BICG(A,B,TOL,MAXIT,M1,M2,X0) �́AX ���v�Z��
% �ꂽ�Ƃ��̌J��Ԃ��񐔂��o�͂��܂��B 0 <= ITER <= MAXIT.
%
% [X,FLAG,RELRES,ITER,RESVEC] = BICG(A,B,TOL,MAXIT,M1,M2,X0) �́A
% �e�J��Ԃ��ł̎c���m�����̃x�N�g�� NORM(B-A*X0) ���o�͂��܂��B
%
% ���F
%   n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
%   b = sum(A,2); tol = 1e-8; maxit = 15;
%   M1 = spdiags([on/(-2) on],-1:0,n,n); M2 = spdiags([4*on -on],0:1,n,n);
%   x = bicg(A,b,tol,maxit,M1,M2,[]);
%   �s��-�x�N�g���ς̊֐����g�p
%   if (nargin > 2) & strcmp(transp_flag,'transp')
%       y = 4 * x;
%       y(1:n-1) = y(1:n-1) - 2 * x(2:n);
%       y(2:n) = y(2:n) - x(1:n-1);
%   else
%       y = 4 * x;
%       y(2:n) = y(2:n) - 2 * x(1:n-1);
%       y(1:n-1) = y(1:n-1) - x(2:n);
%   end
%
%   BICG �ւ̓��͂Ƃ��ė��p���܂��B
%      x1 = bicg(@afun,b,tol,maxit,M1,M2,[],n);
%
% �Q�l�FBICGSTAB, CGS, GMRES, LSQR, MINRES, PCG, QMR, SYMMLQ, LUINC, @.


%   Penny Anderson, 1996.
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:02:27 $
