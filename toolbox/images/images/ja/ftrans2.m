% FTRANS2   ���g���ϊ����g���āA2������ FIR �t�B���^��݌v
%
% H = FTRANS2(B,T) �́A�ϊ��s��T���g���āA1������ FIR �t�B���^ B �ɑΉ�
% ����2������ FIR �t�B���^H���쐬���܂�(FTRANS2 �́A�v�Z�j�Ƃ��� H ���o
% �͂��܂��B����́AFILTER2 �ł̎g�p�ɓK�؂Ȍ^�����Ă��܂�)�BB ��1������
% ��̒���(typeI)�� FIR �t�B���^�ŁASignal Processing Toolbox �� FIR1,
% FIR2,REMEZ �ɂ��쐬�������̂ł��B�ϊ��s�� T �́A�g�p������g���ϊ�
% ���`����W�����܂݂܂��BT �� M �s N ��ŁAB ������ Q �̏ꍇ�AH �̑�
% �����́A((M-1)*(Q-1)/2+1)�s((N-1)*(Q-1)/2+1)��ɂȂ�܂��B
% 
% H = FTRANS2(B) �́AMcClellan �ϊ��s��T���g�p���܂��B
% 
% T = [1  2  1;
%      2 -4  2;
%      1  2  1]/8
% 
% ����ɂ��A�ߎ��I�ɃT�C�N���b�N�őΏ̂ȃt�B���^���쐬���܂��B
% 
% �N���X�T�|�[�g
% -------------
% ���ׂĂ̓��͂Əo�͂́A�N���X double �ł��B
%
% ���
% -------
% FTRANS2 ���g���āA0.1����0.6�̊ԂŒʉߑш�����ߎ��I�ɃT�C�N���b�N��
% �Ώ̂�2�����o���h�p�X�t�B���^��݌v���܂��傤�i���g���́A���K�������
% ���܂��j�B
% 
%       b = remez(10,[0 0.05 0.15 0.55 0.65 1],[0 0 1 1 0 0]);
%       h = ftrans2(b);
%       freqz2(h)
%
% �Q�l�FCONV2, FILTER2, FSAMP2, FWIND1, FWIND2.



%   Copyright 1993-2002 The MathWorks, Inc.  
