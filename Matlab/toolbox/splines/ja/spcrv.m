% SPCRV   ��l�ȋ敪�ɂ��X�v���C���Ȑ�
%
% CURVE = SPCRV(X) �́A����(d,n)�̔z�� X ����A[K/2 .. n-K/2] �͈̔͂� 
% t �ɑ΂���X�v���C��
%
%      t |-->  sum  B(t-K/2;j,...,j+k)*X(j)  
%               j
%
% �̘A���I�Ȓl CURVE(:,i) �̓K�؂ȗ�𐶐����邽�߂ɁA���_�̐ߓ_�̑}����
% �J��Ԃ��s���܂��B
% d>1 �̏ꍇ�A�e CURVE(:,i) �́A�X�v���C���Ȑ���̓_�ł��B
% �}���̏����́A�ߓ_�� MAXPNT �ȏ�ɂȂ�ƏI�����܂��B
% K �̃f�t�H���g��4�ŁAMAXPNT �̃f�t�H���g��100�ł��B
%
% CURVE = SPCRV(X,K) �́A���� K ���w�肵�܂��B
%   
% CURVE = SPCRV(X,K,MAXPNT) �́A�o�͂����_�̐��ɑ΂��āA���� MAXPNT ��
% �w�肵�܂��B
%
% ���:
%
%     k=3; c = spcrv([1 0;0 1;-1 0;0 -1; 1 0].',k); plot(c(1,:),c(2,:))
%
% �́A�ߎ������~��3/4���v���b�g���Ak=4 �̂Ƃ��͋ߎ������~�̔����݂̂�
% �v���b�g���܂��B
%
% �Q�l : CSCVN, SPCRVDEM, SPALLDEM.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
