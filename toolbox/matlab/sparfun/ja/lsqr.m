% LSQR    ���K�������ł̋������z�@�̎���
%
% X = LSQR(A,B) �́AA�������̂Ȃ��ꍇ�́AX �Ɋւ�����`������ A*X = B ��
% �����܂��B�����łȂ��ꍇ�́Anorm(B-A*X) ���ŏ��ɂ���ŏ����� X ��
% ���߂悤�Ƃ��܂��BM �s N ��̌W���s�� A �͐����ŁA�E�ӂ̗�x�N�g�� B 
% �́A������ M �ł���K�v������܂��BA �́AAFUN(X) �� A*X ���o�͂��A 
% AFUN(X,'transp') �� A'*X ���o�͂���悤�Ȋ֐� AFUN �ł��B
%
% LSQR(A,B,TOL) �́A���@�̃g�������X���w��ł��܂��BTOL �� [] �̏ꍇ�́A
% LSQR �́A�f�t�H���g��1e-6���g���܂��B
%
% LSQR(A,B,TOL,MAXIT) �́A�J��Ԃ��ő�񐔂�ݒ肵�܂��BMAXIT �� []��
% �ꍇ�ALSQR �� �f�t�H���g�� min([M,N,20]) ���g���܂��B
%
% LSQR(A,B,TOL,MAXIT,M) �� LSQR(A,B,TOL,MAXIT,M1,M2) �́AN �s N ���
% �O����� M �܂��� M = M1*M2 ���g���A�V�X�e�� A*inv(M)*Y = B �� Y ��
% ���Č����ǂ������܂��B�����ŁAX = inv(M2)*Y �ł��BM �� [] �̏ꍇ�́A
% �O������͓K�p����܂���BM �́AMFUN(X) �� M\X ���o�͂��AMFUN(X,'transp') 
% �� M'\X ���o�͂���悤�Ȋ֐� MFUN �ł��B
%
% LSQR(A,B,TOL,MAXIT,M1,M2,X0) �́A��������l���w�肵�܂��BX0 �� [] ��
% �ꍇ�́ALSQR �� �f�t�H���g�̂��ׂĂ��[���v�f���g���܂��B
%
% LSQR(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) �́A�֐� AFUN �Ƀp��
% ���[�^ P1,P2,...��n���܂��B�����ŁAAFUN �́A AFUN(X,P1,P2,...) �� 
% AFUN(X,P1,P2,...,'transp') �Ƃ��Ďg�p���A�O������֐� M1FUN �� M2FUN 
% �Ɠ��l�ł��B
%
% [X,FLAG] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) �́A�����Ɋւ����� FLAG ��
% �o�͂��܂��B
% 
%    0 LSQR �́AMAXIT �J��Ԃ��͈͓̔��Ŋ�]����g�������X TOL ��
%      �������܂��B
%    1 LSQR �́AMAXIT ��J��Ԃ��܂������A�������܂���B
%    2 �O����� M �̏�����������
%    3 LSQR ���@�\���܂���(2��̘A������J��Ԃ��̌��ʂ�����)
%    4 LSQR �̊ԁA�v�Z�����X�J���ʂ�1���A�v�Z�𑱂���ɂ͑傫
%      �����邩�A�܂��͏�����
%
% [X,FLAG,RELRES] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) �́A���Ύc�� 
% NORM(B-A*X)/NORM(B) ���o�͂��܂��BFLAG ��0�̏ꍇ�́ARELRES <= TOL �ł��B
%
% [X,FLAG,RELRES,ITER] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) �́AX ���v�Z����
% ���Ƃ��̌J��Ԃ��񐔂��o�͂��܂��B 0 <= ITER <= MAXIT.
%
% [X,FLAG,RELRES,ITER,RESVEC] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) �́A�e�J��
% �Ԃ��ł̎c���m�����̃x�N�g�� NORM(B-A*X0) ���o�͂��܂��B
%
% [X,FLAG,RELRES,ITER,RESVEC,LSVEC] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) 
% �́A�e�J��Ԃ��ł̍ŏ���搄��̃x�N�g�����o�͂��܂��B
% NORM((A*inv(M))'*(B-A*X))/NORM(A*inv(M),'fro'). NORM(A*inv(M),'fro') ��
% ����́A�e�J��Ԃ��ɂ��ĕω����A���ǂ���邱�Ƃɒ��ӂ��Ă��������B
%
% ���F
%   n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
%   b = sum(A,2); tol = 1e-8; maxit = 15;
%   M1 = spdiags([on/(-2) on],-1:0,n,n); M2 = spdiags([4*on -on],0:1,n,n);
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
% LSQR �ւ̓��͂Ƃ��ė��p���܂��B
%      x1 = lsqr(@afun,b,tol,maxit,M1,M2,[],n);
%
% �Q�l�FBICG, BICGSTAB, CGS, GMRES, MINRES, PCG, QMR, SYMMLQ, @.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $ $Date: 2004/04/28 02:02:43 $
