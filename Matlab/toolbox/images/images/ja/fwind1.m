% FWIND1   1�����E�B���h�E�@���g���āA2������ FIR �t�B���^��݌v
%   FWIND1 �́A�E�B���h�E�@���g����2������ FIR �t�B���^��݌v���܂��B
%   FWIND1 �́A��]������g������ HD ���x�[�X�ɁA1�����̃E�B���h�E�̎d
%   �l���g���āA2������ FIR �t�B���^��݌v���܂��BFWIND1 �́A1������
%   �E�B���h�E�݂̂ɋ@�\���܂��BFWIND2 �́A2�����E�B���h�E���g���Ƃ���
%   �g�p���܂��B
%
%   H = FWIND1(HD,WIN) �́A���g������ HD ������2���� FIR �t�B���^���
%   �v���܂�(FWIND1 �͌v�Z�j���o�͂��AFILTER2 �Ƌ��Ɏg���^�����Ă���
%   ��)�BFWIND1 �́A1�����E�B���h�E WIN �ɂ��AHuang �@���g���ċߎ��I
%   �ɃT�C�N���b�N�őΏ̂�2�����E�B���h�E���쐬���܂��BSignal Process-
%   ing Toolbox �� BOXCAR,HAMMING,HANNING,BARTLETT,BLACKMAN,KAISER,CH-
%   EBWIN �Ȃǂ̃E�B���h�E���g���āAWIN ��ݒ肷�邱�Ƃ��ł��܂��Blen-
%   gth(WIN) �� N �̏ꍇ�AH �� N �s N ��ɂȂ�܂��B
%
%   HD �́A-1.0����1.0(���K�����ꂽ���g���ŁA1.0�̓T���v�����O���g����
%   �����A�܂��́A�΃��W�A��)�̊Ԃœ��Ԋu�ɕ��z����_�ɑ΂��āA��]��
%   ����g���������܂񂾍s��ł��B���x�̍������ʂ��o�͂����邽�߂ɂ́A
%   FREQSPACE ���o�͂�����g���_���g���āAHD ���쐬���Ă��������B
%
%   H = FWIND1(HD,WIN1,WIN2) �́A2��1�����E�B���h�E WIN1 �� WIN2 
%   ���A2�̕����ɁA�e�X���g���āA2�����E�B���h�E���쐬���܂��B
%   length(WIN1) �� N�Alength(WIN2) �� M �̏ꍇ�AH �� M �s N ��ɂȂ�
%   �܂��B
%
%   H = FWIND1(F1,F2,HD,...) �́Ax ���� y ���ɉ����āA�C�ӂ̎��g��
%   (F1 �� F2 �́A���K�����ꂽ���g��)�Ŋ�]������g������HD���g����
%   ���B�E�B���h�E�̒����́A��q�����悤�Ɍ��ʂ̃t�B���^�̑傫�����R��
%   �g���[�����܂��B
%
%   �N���X�T�|�[�g
% -------------
%   ���͍s�� HD �́Adouble �A�܂��́A�C�ӂ̐����N���X���T�|�[�g���Ă�
%   �܂��BFWIND1 �ւ̂��̑��̓��͂́A���ׂăN���X double �łȂ���΂�
%   ��܂���B���ׂĂ̏o�͂́A�N���X double �ł��B
%
% ���
% ----
%   FWIND1 ���g���āA0.1����0.5��ʉߑш�Ƃ���ߎ��I�ɃT�C�N���b�N��
%   �Ώ̂�2�����o���h�p�X�t�B���^��݌v���܂�(���g���́A���K������Ă�
%   �܂�)�B
%
%       [f1,f2] = freqspace(21,'meshgrid');
%       Hd = ones(21);
%       r = sqrt(f1.^2 + f2.^2);
%       Hd((r<0.1) | (r>0.5)) = 0;
%       h = fwind1(Hd,hamming(21));
%       freqz2(h)
%
% �Q�l : CONV2, FILTER2, FSAMP2, FREQSPACE, FTRANS2, FWIND2



%   Copyright 1993-2002 The MathWorks, Inc.  
