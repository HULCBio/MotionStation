%SUM �v�f�̘a
% S = SUM(X) �́A�x�N�g�� X �̗v�f�̘a���o�͂��܂��B
% X���x�N�g���̏ꍇ�AS �́A�e��̘a����Ȃ�s�x�N�g���ł��B
% X��N�����z��̏ꍇ�ASUM(X) �́A�ŏ��� 1 �łȂ������ő��삵�܂��B
%   
% SUM(X) �͍ŏ���1�łȂ������Řa���v�Z���܂��B 

% X �����������_�A�܂�A�{���x�܂��͒P���x�̏ꍇ�A���̃N���X
% �̂܂ܑ������킳��܂��B���Ȃ킿�AS �́AX �Ɠ����N���X�ɂȂ�܂��B
% X �����������_���łȂ��ꍇ�AS �́A�{���x�ő������킳��AS �͔{���x
% �̃N���X�������܂��B
%
% S = SUM(X,DIM) �́A����DIM�̘a�����߂܂��B
%
% S = SUM(X,'double') �� S = SUM(X,DIM,'double') �́A�{���x��
% �a�����߂܂��BS �́AX ���P���x�ł����Ă��A�{���x�N���X��
% �����܂��B
%
% S = SUM(X,'native') �� S = SUM(X,DIM,'native') �́A�I���W�i����
% �N���X�̂܂ܘa�����߁AS �́AX �Ɠ����N���X�������܂��B
%
% ���:
%   X = [0 1 2
%             3 4 5]
%
% �̏ꍇ�Asum(X,1)��[3 5 7] �ŁAsum(X,2)�� [3
%                                          12];�ł��B
%
% X = int8(1:20) �̏ꍇ�Asum(X) �́A�{���x �Řa�����߁A
% ���ʂ́Adouble(210) �ł��B����Asum(X,'native') �́Aint8 ��
% �a�����߂܂����A�I�[�o�[�t���[���Aint8(127) �܂ŖO�a���܂��B
%
% �Q�l PROD, CUMSUM, DIFF, ACCUMARRAY, ISFLOAT.

%   Copyright 1984-2002 The MathWorks, Inc. 


