% CGS    �����X�Γ��@
%
% X = CGS(A,B) �́AX �Ɋւ�����`������ A*X = B �������܂��BN �s N ��
% �̌W���s�� A �͐����ŁA�E�ӂ̗�x�N�g�� B �͒����� N �ł���K�v��
% ����܂��BA �́AA'*X ���o�͂���֐��ł��B
%
% CGS(A,B,TOL) �́A���@�̃g�������X���w��ł��܂��BTOL �� [] �̏ꍇ�́A
% CGS �̓f�t�H���g��1e-6���g���܂��B
%
% CGS(A,B,TOL,MAXIT) �́A�J��Ԃ��ő�񐔂�ݒ肵�܂��BMAXIT �� [] ��
% �ꍇ�́ACGS �̓f�t�H���g�� min(N,20)���g���܂��B
%
% CGS(A,B,TOL,MAXIT,M) �� CGS(A,B,TOL,MAXIT,M1,M2) �́A�O����� M�A
% �܂��� M = M1*M2 ���g���A�V�X�e�� inv(M)*A*X = inv(M)*B �� X �ɂ���
% �����ǂ������܂��BM �� [] �̏ꍇ�́A�O������͓K�p����܂���BM �́A
% M'\X ���o�͂���֐��ł��B
%
% CGS(A,B,TOL,MAXIT,M1,M2,X0) �́A��������l��ݒ肵�܂��BX0 �� [] ��
% �ꍇ�́ACGS �̓f�t�H���g�̂��ׂĂ��[���v�f���g���܂��B
%
% CGS(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) �́A�p�����[�^ P1,P2,...
% ���֐� AFUN(X,P1,P2,...), M1FUN(X,P1,P2,...), M2FUN(X,P1,P2,...) ��
% �n���܂��B
%
% [X,FLAG] = CGS(A,B,TOL,MAXIT,M1,M2,X0) �́A�����Ɋւ����� FLAG ��
% �o�͂��܂��B
% 
%    0 CGS �́AMAXIT �J��Ԃ��͈͓̔��ŁA��]����g�������X TOL ��
%      �������܂��B
%    1 CGS �́AMAXIT ��J��Ԃ��܂������A�������܂���B
%    2 �O����� M �̏�����������
%    3 CGS ���@�\���܂���(2��̘A������J��Ԃ��̌��ʂ�����)
%    4 CGS �̊ԁA�v�Z�����X�J���ʂ�1���v�Z�𑱂���ɂ͑傫
%      �����邩�A�܂��͏�����
%
% FLAG ��0�łȂ��ꍇ�́A�o�͂����� X �́A�J��Ԃ��S�̂ɓn���Čv�Z�����
% �ŏ��̃m�����c���ɂȂ�܂��BFLAG �o�͂��w�肳���ꍇ�́A���b�Z�[�W��
% ����܂���B
% 
% [X,FLAG,RELRES] = CGS(A,B,TOL,MAXIT,M1,M2,X0) �́A���Ύc�� 
% NORM(B-A*X)/NORM(B) ���o�͂��܂��BFLAG ��0�̏ꍇ�́ARELRES <= TOL �ł��B
%
% [X,FLAG,RELRES,ITER] = CGS(A,B,TOL,MAXIT,M1,M2,X0) �́AX ���v�Z
% ���ꂽ�Ƃ��̌J��Ԃ��񐔂��o�͂��܂��B 0 <= ITER <= MAXIT�B
%
% [X,FLAG,RELRES,ITER,RESVEC] = CGS(A,B,TOL,MAXIT,M1,M2,X0) �́A�e�J��
% �Ԃ��ł̎c���m�����̃x�N�g�� NORM(B-A*X0) ���o�͂��܂��B.
%
% ���F
%  A = gallery('wilk',21);  b = sum(A,2);
%  tol = 1e-12;  maxit = 15; M1 = diag([10:-1:1 1 1:10]);
%  x = bicgstab(A,b,tol,maxit,M1,[],[]);
% �܂��́A���̍s��ƃx�N�g���̐ς̊֐����g���܂��B
%  function y = afun(x,n)
%  y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'] .*x + [x(2:n); 0];
% �����āA�O������̌�މ�@�֐����g���܂��B
%  function y = mfun(r,n)
%  y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
% CGS �ւ̓��͂��s���܂��B
%  x1 = bicgstab(@afun,b,tol,maxit,@mfun,[],[],21);
% afun �� mfun �� CGS �̒ǉ����� n = 21 ���󂯓���Ȃ���΂Ȃ�܂���B
%
% �Q�l�FBICG, BICGSTAB, GMRES, LSQR, MINRES, PCG, QMR, SYMMLQ, LUINC, @.


%   Penny Anderson, 1996.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:02:29 $
