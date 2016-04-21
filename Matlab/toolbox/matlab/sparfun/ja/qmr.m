% QMR    ���ŏ��c���@
% 
% X = QMR(A,B) �́AX �Ɋւ�����`������ A*X = B �������܂��BN �s N ���
% �W���s�� A �͐����ŁA�E�ӂ̗�x�N�g�� B �� ������ N �ł���K�v������܂��B
% A �́AAFUN(X) ���AA*X �� AFUN(X,'transp') �� A'*X ���o�͂���悤�Ȋ֐�
% �ł��B
%
% QMR(A,B,TOL) �́A���@�̒��Ƀg�������X���w��ł��܂��BTOL �� [] �̏ꍇ
% �́AQMR �̓f�t�H���g��1e-6���g���܂��B
%
% QMR(A,B,TOL,MAXIT) �́A�J��Ԃ��ő�񐔂�ݒ肵�܂��BMAXIT �� [] ��
% �ꍇ�́AQMR �̓f�t�H���g�� min(N,20)���g���܂��B
%
% QMR(A,B,TOL,MAXIT,M) �� QMR(A,B,TOL,MAXIT,M1,M2) �́A�O����� M �܂���
% M = M1*M2 ���g���A�V�X�e�� inv(M1)*A*inv(M2)*Y = inv(M1)*B �� Y ��
% ���āA�����ǂ������܂��BM �� [] �̏ꍇ�́A�O������͓K�p����܂���B
% M �́AMFUN(X) �� M\X ���o�͂��AMFUN(X,'transp') �� M'\X ���o�͂���
% �悤�Ȋ֐� MFUN �ł��B
%
% QMR(A,B,TOL,MAXIT,M1,M2,X0) �́A��������l��ݒ肵�܂��BX0 �� [] ��
% �ꍇ�́AQMR �̓f�t�H���g�̂��ׂĂ��[���v�f���g���܂��B
%
% QMR(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) �́A�֐� AFUN �Ƀp��
% ���[�^ P1,P2,...��n���܂��B�����ŁAAFUN �́A AFUN(X,P1,P2,...) �� 
% AFUN(X,P1,P2,...,'transp') �Ƃ��Ďg�p���A�O������֐� M1FUN �� M2FUN 
% �Ɠ��l�ł��B
%
% [X,FLAG] = QMR(A,B,TOL,MAXIT,M1,M2,X0) �́A�����Ɋւ����� FLAG ��
% �o�͂��܂��B
% 
%    0 QMR �́AMAXIT �J��Ԃ��͈͓̔��Ŋ�]����g�������X TOL ��
%      �������܂��B
%    1 QMR �́AMAXIT ��J��Ԃ��܂������A�������܂���B
%    2 �O����� M �̏�����������
%    3 QMR ���@�\���܂���(2��̘A������J��Ԃ��̌��ʂ�����)
%    4 QMR �̊ԁA�v�Z�����X�J���ʂ�2���A�v�Z�𑱂���ɂ͑傫
%      �����邩�A�܂��͏�����
%
% [X,FLAG,RELRES] = QMR(A,B,TOL,MAXIT,M1,M2,X0) �́A���Ύc�� 
% NORM(B-A*X)/NORM(B) ���o�͂��܂��BFLAG ��0�̏ꍇ�́ARELRES <= TOL �ł��B
%
% [X,FLAG,RELRES,ITER] = QMR(A,B,TOL,MAXIT,M1,M2,X0) �́AX ���v�Z���ꂽ
% �Ƃ��̌J��Ԃ��񐔂��o�͂��܂��B 0 <= ITER <= MAXIT.
%
% [X,FLAG,RELRES,ITER,RESVEC] = QMR(A,B,TOL,MAXIT,M1,M2,X0) �́A�e�J��
% �Ԃ��ł̎c���m�����̃x�N�g�� NORM(B-A*X0) ���o�͂��܂��B
%
% ���F
%   n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
%   b = sum(A,2); tol = 1e-8; maxit = 15;
%   M1 = spdiags([on/(-2) on],-1:0,n,n); 
%   M2 = spdiags([4*on -on],0:1,n,n);
%   x = qmr(A,b,tol,maxit,M1,M2,[]);
% �s��-�x�N�g���ς̊֐����g�p
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
% QMR �ւ̓��͂Ƃ��ė��p���܂��B
%      x1 = bicg(@afun,b,tol,maxit,M1,M2,[],n);
% 
% �Q�l�FBICG, BICGSTAB, CGS, GMRES, LSQR, MINRES, PCG, SYMMLQ, LUINC, @.


%   Penny Anderson, 1996.
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:02:50 $
