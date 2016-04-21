%LSCOV ���m�̋����U���g�����ŏ�����@
% X = LSCOV(A,B) �́A���`�������n A*X = B �ɑ΂���ʏ�̍ŏ�����
% ���o�͂��܂��B���Ȃ킿�AX �́A���덷 (B - A*X)'*(B - A*X)�̘a��
% �ŏ��ɂ���AN�~1 �x�N�g���ł��B�����ŁAA �́AM�~N, B �́AM�~1 �ł��B
% B �́AM�~K �s��ɂ��Ȃ�ALSCOV �́AB �̊e��ɑ΂�������o�͂��܂��B
% rank(A) < N �̏ꍇ�ALSCOV �́A"basic solution" �𓾂邽�߂ɁAX �� 
% �v�f�̉\�ȍő吔���[���ƒu���܂��B
%
% X = LSCOV(A,B,W) �́AW �𐳂̎����̏d�݂����x�N�g���̒��� M �Ƃ��āA
% ���`�V�X�e�� A*X = B �ɑ΂���d�ݕt���̍ŏ��������o�͂��܂��B���Ȃ킿�A
% X �́A(B - A*X)'*diag(W)*(B - A*X) ���ŏ��ɂ��܂��BW �́A�ʏ��
% �J�E���g �܂��� inverse variances �̂����ꂩ���܂݂܂��B
%
% X = LSCOV(A,B,V)�́AM�~M ���Ώ̐���l�s�� V �ɂ��āA
% V �ɔ�Ⴗ�鋤���U�s��������`�n A*X = B �ɑ΂����ʉ��ŏ�������
% �o�͂��܂��B���Ȃ킿�AX �́A(B - A*X)'*inv(V)*(B - A*X) ���ŏ������܂��B
%
% ����ʂɁAV �́A������ɂȂ邱�Ƃ��\�ł���ALSCOV �́A
% ����̂���ŏ������̉��ł���AX ���o�͂��܂��B
%
%      minimize E'*E subject to A*X + T*E = B
%        E,X
%
% �����ŁAT*T' = V �ł��BV ��������ł���ꍇ�A���̖��́AB ���AA �� V
% �Ɩ����̂Ȃ�(���Ȃ킿�A[A T] �̗�̋�Ԃɂ���)�ꍇ�Ɍ���A���������܂��B
% �����łȂ��ꍇ�ALSCOV �́A�G���[���o�͂��܂��B
%
% �f�t�H���g�ł́ALSCOV �́AV �� Cholesky �������v�Z���A���ۂ́A
% ����ʏ�̍ŏ����ɕϊ����邽�߂ɁA���̗v�f��ϊ����܂��B
% �������ALSCOV �� V ��������ł���ƌ��肷��ꍇ�AV �̕ϊ��������A
% ���𕪉��A���S���Y�����g�p���܂��B
%
% X = LSCOV(A,B,V,ALG) �ɂ��AV ���s��̏ꍇ�AX �̌v�Z�Ɏg�p�����
% �A���S���Y���𖾎����đI�����邱�Ƃ��ł��܂��B
% LSCOV(A,B,V,'chol') �́AV �� Cholesky �������g�p���܂��B
% LSCOV(A,B,V,'orth') �́A���𕪉����g�p���A V ��ill-conditioned �܂���
% �񐳑��̏ꍇ�ɂ��K���ł����A�v�Z�ʂ���葽���Ȃ�܂��B
%
% [X,STDX] = LSCOV(...) �́AX �� ����W���덷���o�͂��܂��B
% A �������N�����̏ꍇ�ASTDX �́AX �̃[���̗v�f�ɑΉ�����v�f�Ƀ[����
% �܂݂܂��B
%
% [X,STDX,MSE] = LSCOV(...) �́A���ϓ��덷���o�͂��܂��B
%
% [X,STDX,MSE,S] = LSCOV(...) �́AX �̐��苤���U�s����o�͂��܂��B
% A �������N�����̏ꍇ�AS �́AX �� �[���̗v�f�ɑΉ�����s�Ɨ��
% �[�����܂݂܂��B
% LSCOV �́A�E�ӂ���������Ƃ�(���Ȃ킿�Asize(B,2) > 1)�ɃR�[�������ꍇ�A
% S ���o�͂ł��܂���B
%
% A �� V ���t�������N�̏ꍇ�A�����̗ʂɂ��Ă̕W���`�́A���̂悤��
% �Ȃ�܂��B
%
%      X = inv(A'*inv(V)*A)*A'*inv(V)*B
%      MSE = B'*(inv(V) - inv(V)*A*inv(A'*inv(V)*A)*A'*inv(V))*B./(M-N)
%      S = inv(A'*inv(V)*A)*MSE
%      STDX = sqrt(diag(S))
%
% �������ALSCOV �́A��荂���ł�����Ȏ�@���g�p���A�����N������
% �ꍇ�ɂ��K�p���邱�Ƃ��ł��܂��B
%
% LSCOV �́AB �̋����U�s�񂪃X�P�[�����q�܂ł̂݁A���m�ł���Ɖ��肵�܂��B
% MSE �́A���m�̃X�P�[�����q�̐���ł���ALSCOV �́A�K�؂ɁA�o�� S �� 
% STDX ���X�P�[�����܂��B�������AV �� B �̋����U�s��ł��邱�Ƃ����m��
% �ꍇ�A���̃X�P�[�����O�͕K�v����܂���B���̏ꍇ�A�K�؂Ȑ�������邽��
% �ɂ́AS �� STDX �����ꂼ��A1/MSE �� sqrt(1/MSE) �ɂ�胊�X�P�[������
% �K�v������܂��B
%
% �Q�l SLASH, LSQNONNEG, QR.

%   �Q�l����:
%      [1] Paige, C.C. (1979) "Computer Solution and Perturbation
%          Analysis of Generalized Linear Leat Squares Problems",
%          Mathematics of Computation 33(145):171-183.
%      [2] Golub, G.H. and Van Loan, C.F. (1996) Matrix Computations,
%          3rd ed., Johns Hopkins University Press.
%      [2] Goodall, C.R. (1993) "Computation using the QR Decomposition",
%          in Computational Statistics, Vol. 9 of Handbook of Statistics,
%          edited by C.R. Rao, North-Holland, pp. 492-494.
%      [4] Strang, G. (1986) Introduction to Applied Mathematics,
%          Wellesley-Cambridge Press, pp. 398-399.

%   Copyright 1984-2003 The MathWorks, Inc.
