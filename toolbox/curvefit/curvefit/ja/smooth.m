% SMOOTH  �f�[�^�̕�����
% Z = SMOOTH(Y) �́A�f�[�^ Y �̕��������s���܂��B
%
% Z = SMOOTH(Y,SPAN) �́A�g�p����_����ݒ肷�� SPAN ���g���āA�f�[�^ Y 
% �𕽊������āA���̌��ʂ�v�f�Ƃ��� Z ���o�͂��܂��B
%
% Z = SMOOTH(Y,SPAN,METHOD) �́A�w�肵�� METHOD ���g���āA�f�[�^ Y ��
% �������܂��B�f�t�H���g�̎�@�́A�ړ����ςł��B�g�p�\�ȕ��@�́A��
% �̂��̂ł��B
%
%      'moving'   - �ړ�����
%      'lowess'   - �Ǐ��I�ȏd�݂�K�p�����ŏ����(���`�ߎ�)
%      'loess'    - �Ǐ��I�ȏd�݂�K�p�����ŏ����(2���������ߎ�)
%      'sgolay'   - Savitzky-Golay
%      'rlowess'  - �Ǐ��I�ȏd�݂�K�p�����ŏ����̃��o�X�g��@
%                   (���`�ߎ�)
%      'rloess'   - �Ǐ��I�ȏd�݂�K�p�����ŏ����̃��o�X�g��@
%                   (2���������ߎ�)
%
% Z = SMOOTH(Y,METHOD) �́A�f�t�H���g�� SPAN �l5���g���܂��B
%
% Z = SMOOTH(Y,SPAN,'sgolay',DEGREE) �� Z = SMOOTH(Y,'sgolay',DEGREE) 
% �́ASavitzky-Golay �@�Ŏg���鑽�����̎�����ݒ肵�܂��B�f�t�H���g
% �� DEGREE ��2�ŁADEGREE �́ASPAN ��菬�����ݒ肷��K�v������܂��B
%
% Z = SMOOTH(X,Y,...) �́AX ���W���w�肵�܂��BX �����łȂ��ꍇ�AX ���W
% ��K�v�Ƃ����@�ł́AX = 1:N �����肵�Ă��܂��B�����ŁAN �́AY �̒�
% ���ł��B
%
% ���ӁF
%   1. X ����l���z���Ȃ��悤�ɐݒ肳��Ă���ꍇ�A�f�t�H���g�̎�@�́A
%     'lowess'�ł��B
%
%   2. �ړ����ς� Savitzky-Golay �@�ł́ASPAN �͊�ł���K�v������܂��B
%      SPAN �������ɂ���ƁA1������܂��B
%
%   3. SPAN ���AY �̒�����蒷���ꍇ�AY �̒����ɂȂ�悤�ɂ��܂��B
%
%   4. (���o�X�g) lowess �@�� (���o�X�g) loess �@�̏ꍇ�A�f�[�^�Z�b�g��
%       �̑����ɑ΂��銄���� SPAN ��ݒ肷�邱�Ƃ��ł��܂��BSPAN ��1��
%       ���̏ꍇ�A�S�����Ƃ��Ĉ����܂��B
%
% ���F
%
% Z = SMOOTH(Y) �́Aspan = 5, X=1:length(Y) ���g�����ړ����ς��g���܂��B
%
% Z = SMOOTH(Y,7) �́Aspan = 7, X=1:length(Y) ���g�����ړ����ς��g���܂��B 
%
% Z = SMOOTH(Y,'sgolay') �́ADEGREE=2, SPAN = 5, X = 1:length(Y) ���g����
% Savitzky-Golay �@���g���܂��B
%
% Z = SMOOTH(X,Y,'lowess') �́ASPAN = 5 ���g���� lowess ���g���܂��B
%
% Z = SMOOTH(X,Y,SPAN,'rloess') �́A���o�X�g loess �@���g���܂��B
%
% Z = SMOOTH(X,Y) �́AX ���A���Ԋu���z�����Ȃ��ꍇ�Aspan = 5 ���g���� 
% lowess �@���g���܂��B
%
% Z = SMOOTH(X,Y,8,'sgolay') �́Aspan = 7 (8 �́A�����Ȃ̂�1����������
% ��)���g���� Savitzky-Golay �@���g���܂��B
%
% Z = SMOOTH(X,Y,0.3,'loess') �́A�f�[�^�� 30% �� span �Ƃ��� loess �@��
% �g���܂��Bspan = ceil(0.3*length(Y))�B
%
% �Q�l   SPLINE

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
