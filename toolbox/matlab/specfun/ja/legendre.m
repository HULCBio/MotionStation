% LEGENDRE   ����Legendre�֐�
% 
% P = LEGENDRE(N,X) �́AX �̊e�v�f�ɑ΂��ċ��߂���A�x�� N �Ŏ���
% m = 0�A1�A...�AN �̐���Legendre�֐����v�Z���܂��BN ��256�ȉ��̃X�J��
% �̐����ŁAX ��-1 < =  X < = 1 �̊Ԃ̎����l�łȂ���΂Ȃ�܂���B  
%
% X ���x�N�g���̏ꍇ�AP �� (N+1) �s L ��̍s��ł��B�����ŁAL = length(X)
% �ł��B�v�f P (m+1,i) �́AX(i) �ŋ��߂���x�� N �Ŏ��� m �̐���
% Legendre�֐��ɑΉ����܂��B
%
% ��ʓI�ɁA�o�͂����z��́AX ����1�傫�������������܂��B�e�v�f
% P(m+1,i,j,k,...) �́AX(i,j,k,...) �ŋ��߂���p�x N �Ŏ��� m �̐���
% Legendre�֐����܂݂܂��B
%
% �\�Ȑ��K���ALEGENDRE(N,X,normalize) ��3����܂��B
% �����ŁAnormalize �� 'unnorm', 'sch' 'norm' �̂����ꂩ�ł��B
%
% �f�t�H���g�̔񐳋K������Legendre�֐��́A�ȉ��̒ʂ�ł��B
% 
%     P(N,M;X) = (-1)^M * (1-X^2)^(M/2) * (d/dX)^M { P(N,X) },
%
% �����ŁAP(N,X) �͊p�x n ��Legendre�������ł��BP �̍ŏ��̍s�́AX �ŋ���
% ����Legendre�������ł��邱�Ƃɒ��ӂ��Ă�������(M == 0�̏ꍇ)�B
%
% SP = LEGENDRE(N,X,'sch') �́ASchmidt�����K������Legendre�֐�
% SP(N,M;X) ���v�Z���܂��B�����̊֐��́A���̂悤�ɁA(�񐳋K��)����
% Legendre�֐� P(N,M;X) �ƑΉ��t�����܂��B
%
%   SP(N,M;X) = P(N,X), M = 0
%             = (-1)^M * sqrt(2*(N-M)!/(N+M)!) * P(N,M;X), M > 0
%
% NP = LEGENDRE(N,X,'norm') �́A���S�ɐ��K�����ꂽ����Legendre�֐�
% NP(N,M;X) ���v�Z���܂��B�����̊֐��́A�ȉ��̂悤�ɐ��K������܂��B
%
%            /1
%           |
%           | [NP(N,M;X)]^2 dX = 1    ,
%           |
%           /-1
%
% �����āA�ȉ��ɂ��A�񐳋K������Legendre�֐� P(N,M;X) �Ɗ֘A�t������
% ���B
%               
%   NP(N,M;X) = (-1)^M * sqrt((N+1/2)*(N-M)!/(N+M)!) * P(N,M;X)
%
% ���: 
%  1. legendre(2�A0.0:0.1:0.2)�́A���̍s����o�͂��܂��B
% 
%            |    x = 0           x = 0.1         x = 0.2
%      ------|---------------------------------------------
%      m = 0 |   -0.5000         -0.4850         -0.4400
%      m = 1 |         0         -0.2985         -0.5879
%      m = 2 |    3.0000          2.9700          2.8800  
%
%   2. X = rand(2,4,5); N = 2; 
%      P = legendre(N,X); 
%
% �]���āAsize(P) ��3x2x4x5�ŁAP(:,1,2,3) �� legendre(N,X(1,2,3)) �Ɠ����ł��B

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:04:22 $
