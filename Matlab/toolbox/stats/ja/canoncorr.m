% CANONCORR   �������֕���
%
% [A,B] = CANONCORR(X,Y) �́AN�~P1 �� N�~P2 �̃f�[�^�s�� X �� Y �ɑ΂���
% �W�{�����W�����v�Z���܂��BX �� Y �́A�قȂ�ϐ�(��)�̐��������Ƃ�
% �ł��܂����A�ϑ�(�s)���͓����łȂ���΂Ȃ�܂���BA �� B �́AP1�~D �� 
% P2�~D �s��ŁAD = min(rank(X),rank(Y)) �ł��BA �� B ��j�Ԗڂ̗�́A
% ���ꂼ�ꐳ���W��(���Ȃ킿 X �� Y �ɑ΂���j�Ԗڂ̐����ϐ����\�z����
% �ϐ��̐��`����)���܂݂܂��BA �� B �̗�́ACOV(U) ����� COV(V)(�ȉ�
% ���Q��)���P�ʍs��ɂȂ�悤�X�P�[�����O����Ă��܂��BX �܂��� Y ��
% �t�������N�ȉ��̏ꍇ�ACANONCORR �͌x����^���AX �܂��� Y �̓Ɨ��łȂ�
% ��ɑΉ����� A �܂��� B �̍s�ɗ��Ԃ��܂��B
%
% [A,B,R] = CANONCORR(X,Y) �́A�W�{�������֌W�����܂� 1�~D �̃x�N�g�� 
% R ��Ԃ��܂��BR ��j�Ԗڂ̗v�f�́AU �� V (�ȉ����Q��)��j�Ԗڂ̗�̊�
% �̑��ւł��B
%
% [A,B,R,U,V] = CANONCORR(X,Y) �́AN�~D �̍s�� U �� V �ɁA�X�R�A�Ƃ���
% ���m���鐳���ϐ���Ԃ��܂��BU �� V �͈ȉ��̂悤�Ɍv�Z����܂��B
%
%      U = (X - repmat(mean(X),N,1))*A �����
%      V = (Y - repmat(mean(Y),N,1))*B.
%
% [A,B,R,U,V,STATS] = CANONCORR(X,Y) �́AK = 0:(D-1) �ɑ΂��āA(K+1)
% �Ԗڂ��� D�Ԗڂ̑��֌W���͂��ׂė�ł���Ƃ��� D�̋A������ H0_K ��
% �ւ�������܂񂾍\���̂��o�͂��܂��BSTATS �́AK �̒l�ɑΉ�����v�f
% �������ꂼ�� 1�~D �̃x�N�g���ƂȂ�ȉ���8�̃t�B�[���h���܂݂܂��B:
%
%      Wilks:    �E�C���N�X(Wilks)��lambda (�ޓx��) ���v��
%      chisq:    Lawley�̏C���ł��g����H0_K �ɑ΂���Bartlett�̋ߎ���
%                �J�C��擝�v��
%      pChisq:   CHISQ �ɑ΂���right-tail�L�Ӑ���
%      F:        H0_K �ɑ΂���Rao�̋ߎ���F���v��
%      pF:       F�ɑ΂���right-tail�L�Ӑ���
%      df1:      F���v�ʂɑ΂��鎩�R�x�̕��q�Ɠ��l�̃J�C��擝�v�ʂ�
%                �΂��鎩�R�x
%      df2:      F���v�ʂɑ΂��鎩�R�x�̕���
%
% ���:
%
%      load carbig;
%      X = [Displacement Horsepower Weight Acceleration MPG];
%      nans = sum(isnan(X),2) > 0;
%      [A B r U V] = canoncorr(X(~nans,1:3), X(~nans,4:5));
%
%      plot(U(:,1),V(:,1),'.');
%      xlabel('0.0025*Disp + 0.020*HP - 0.000025*Wgt');
%      ylabel('-0.17*Accel + -0.092*MPG')
%
% �Q�l: PRINCOMP, MANOVA1.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/12/18 20:05:06 $

