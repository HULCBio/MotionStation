%POLYFIT �������ߎ�
% POLYFIT(X,Y,N) �́A�f�[�^ P(X(I))~ = Y(I) ���ŏ����I�ɋߎ�����N����
% ������ P(X) �̌W�����Z�o���܂��B
%
% [P,S] = POLYFIT(X,Y,N) �́A����덷�܂��͗\���𓾂邽�߂� POLYVAL ��
% �g���������̌W�� P �ƍ\���� S ���o�͂��܂��B
% P �́A�������̌W�����ׂ��̍~���A���Ȃ킿�A
% P(1)*X^N + P(2)*X^(N-1) +...+ P(N)*X + P(N+1) ���܂ށA���� N+1 �̍s
% �x�N�g���ł��B�f�[�^ Y �̌덷�����̕��U�����Ɨ��ȕW���덷�̏ꍇ�́A
% POLYVAL �́A���Ȃ��Ƃ��\����50% ���܂ތ덷�͈͂��o�͂��܂��B 
%
% �\���� S �́AVandermonde�s��(R) �� Cholesky�����A���R�x(df)�A�c���̃m����
% (normr)���t�B�[���h�ɂ����Ă��܂��B  
%
% [P,S,MU] = POLYFIT(X,Y,N) �́AXHAT = (X-MU(1))/MU(2) �̑������̌W����
% ���߂܂��B�����ŁAMU(1) = mean(X) ����  MU(2) = std(X) �ł��B���̃Z���^
% �����O�ƃX�P�[�����O�̕ϊ��ɂ��A�������Ƌߎ��A���S���Y���̗����̐��l
% �v���p�e�B�����ǂ��܂��B
%
% X ���d�����Ă��邩�A���邢�͏d���ɋ߂��_�ł��邩�A���邢��X �̓Z���^
% �����O��X�P�[�����O���K�v�ȏꍇ�́AN �� >= length(X) �̏ꍇ�ɂ́A
% ���[�j���O���b�Z�[�W���\������܂��B
%
% ���� x,y �̃T�|�[�g�N���X
%      float: double, single
%
% �Q�l POLY, POLYVAL, ROOTS.

%   Copyright 1984-2004 The MathWorks, Inc.
