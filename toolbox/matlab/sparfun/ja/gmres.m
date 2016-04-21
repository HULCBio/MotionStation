% GMRES  ��ʉ��ŏ��c���@
%
% X = GMRES(A,B) �́AX �Ɋւ�����`������ A*X =B �������܂��BN �s N ��
% �̌W���s�� A �͐����ŁA�E�ӂ̗�x�N�g�� B �͒����� N �ł���K�v������
% �܂��BA �́AA*X ���o�͂���֐��ł�����\��������܂��B����́A
% MIN(N,10) ���J��Ԃ��񐔂̍ő�\�񐔂Ƃ��āA�ăX�^�[�g���Ȃ����@���g��
% �Ă��܂��B
%
% MRES(A,B,RESTART) �́ARESTART ��̌J��Ԃ����ɕ��@���ăX�^�[�g����
% ���BRESTART �� N �܂��� [] �̏ꍇ�́AGMRES �́A��L�̂悤�ɍăX�^�[�g
% ���s���܂���B
%
% GMRES(A,B,RESTART,TOL) �́A���@�̃g�������X��ݒ肵�܂��BTOL �� [] ��
% �ꍇ�́A�f�t�H���g��1e-6 ���g���܂��B
%
% GMRES(A,B,RESTART,TOL,MAXIT) �́A�J��Ԃ��̍ő�񐔂��w�肵�܂��B
% ���ӁF�J��Ԃ��̑��񐔂́ARESTART*MAXIT �ł��BMAXIT �� [] �̏ꍇ�́A
% GMRES �̓f�t�H���g�� MIN(N/RESTART,10) ���g���܂��BRESTART �� N��
% ���� [] �̏ꍇ�́A�J��Ԃ��̑��񐔂� MAXIT �ɂȂ�܂��B
%
% GMRES(A,B,RESTART,TOL,MAXIT,M) �� 
% GMRES(A,B,RESTART,TOL,MAXIT,M1,M2) ��
% �O����� M �܂��� M = M1*M2 ���g���AX �ɂ��� inv(M)*A*X = inv(M)*B
% �������I�ɉ����܂��BM �� [] �̏ꍇ�́A�O������͓K�p����܂���BM �� 
% M\X ���o�͂���֐��ł��B
%
% GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) �́A����������w�肵�܂��BX0 
% �� [] �̏ꍇ�́A�f�t�H���g�̂��ׂĂ��[���v�f�̃x�N�g�����g���܂��B
%
% GMRES(AFUN,B,RESTART,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) �́A�֐�
% �Ƀp�����[�^��n���܂��BAFUN(X,...P1,P2,...), M1FUN(X,P1,P2,...), 
% M2FUN(X,P1,P2,...).
% 
% [X,FLAG] = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) �́A�����Ɋւ���
% ��� FLAG ���o�͂��܂��B
% 
%    0 GMRES �́AMAXIT �J��Ԃ��͈͓̔��Ŋ�]����g�������X TOL �Ɏ���
%      ���܂��B
%    1 GMRES �́AMAXIT ��J��Ԃ��܂������A�������܂���B
%    2 �O����� M �̏�����������
%    3 GMRES ���@�\���܂���(2��̘A������J��Ԃ��̌��ʂ�����)
%
% [X,FLAG,RELRES] = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) �́A����
% �c�� NORM(B-A*X)/NORM(B) ���o�͂��܂��BFLAG  ��0�̏ꍇ�́A
% RELRES <= TOL �ł��B�O����M1,M2���g���ƁA�c����NORM(M2\(M1\(B-A*X)))
% �ł��B
%
% [X,FLAG,RELRES,ITER] = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) �́AX 
% ���v�Z���ꂽ�Ƃ��̌J��Ԃ��񐔂��o�͂��܂��B0 <= ITER(1) <= MAXIT �� 
% 0 <= ITER(2) <= RESTART �ł��B
%
% [X,FLAG,RELRES,ITER,RESVEC] = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) 
% �� NORM(B-A*X0) ���܂ފe�J��Ԃ��ł̎c���m�����̃x�N�g�����o�͂���
% ���B�O����M1,M2���g���ƁA�c���� NORM(M2\(M1\(B-A*X)))�ł��B
%
% ���F
%      A = gallery('wilk',21);  b = sum(A,2);
%      tol = 1e-12;  maxit = 15; M1 = diag([10:-1:1 1 1:10]);
%      x = gmres(A,b,10,tol,maxit,M1,[],[]);
% �܂��́A���̍s��ƃx�N�g���̐ς̊֐����g���܂��B
%      function y = afun(x,n)
%      y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'] .*x...
%          + [x(2:n); 0];
% �����āA�O������̌�މ�@�֐����g���܂��B
%      function y = mfun(r,n)
%      y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
% GMRES �ւ̓��͂Ƃ��ė��p���܂��B
%      x1 = gmres(@afun,b,10,tol,maxit,@mfun,[],[],21);
%
% �Q�l�FBICG, BICGSTAB, CGS, LSQR, MINRES, PCG, QMR, SYMMLQ, LUINC, @.

