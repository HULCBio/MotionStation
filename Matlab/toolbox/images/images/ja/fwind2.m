% FWIND2   2�����E�B���h�E�@���g����2���� FIR �t�B���^��݌v
%   FWIND2 �́A�E�B���h�E�@���g���āA2������ FIR �t�B���^���쐬����
%   ���BFWIND2 �́A2�����E�B���h�E�d�l���g���āA��]������g������ HD 
%   ���x�[�X��2���� FIR �t�B���^��݌v���܂��BFWIND2 �́A2�����E�B���h
%   �E���g���܂��B����AFWIND1 �́A1�����E�B���h�E���g���܂��B
%
%   H = FWIND2(HD,WIN) �́A��]������g������ HD �̋t�t�[���G�ϊ����s
%   ���A����ɃE�B���h�E WIN ����Z���āA2������ FIR �t�B���^ H ���쐬
%   ���܂��BHD �́A�������W�n�œ��Ԋu�ɕ��z�����_�ŁA��]������g����
%   �����܂ލs��ł��BFWIND2 �́A�v�Z�j�Ƃ��� H ���o�͂��܂��B����́A
%   FILTER2 �Ŏg���^�ɂȂ��Ă��܂��BWIN �̑傫���́A���ʂ̃t�B���^�̑�
%   �������R���g���[�����܂��BWIN �� M �s N ��ł���ꍇ�AH ���A�܂� 
%   M �s N ��ƂȂ�܂��B
%
%   ���x�̍������ʂ��o�͂����邽�߂ɂ́AFREQSPACE ���o�͂�����g���_��
%   �g���āAHD ���쐬���Ă��������B
%
%   H = FWIND2(F1,F2,HD,WIN) �́Ax ���� y ���ɉ����ĔC�ӂ̎��g��(F1 ��
%   F2) �Ŋ�]������g������ HD ��ݒ肷�邱�Ƃ��ł��܂��B���g���x�N�g
%   �� F1 �� F2 �́A-1.0����1.0�͈̔͂ɓ���A1.0�̓T���v�����O���g����
%   �����A�܂��� �΃��W�A���ɑΉ����܂��B
%
%   �N���X�T�|�[�g
% -------------
%   ���͍s�� HD �́Adouble �A�܂��́A�C�ӂ̐����N���X���T�|�[�g���Ă�
%   �܂��BFWIND2 �ւ̂��ׂĂ̓��͂́Adouble �łȂ���΂Ȃ�܂���B�o��
%   �́A���ׂăN���X double �ɂȂ�܂��B
%
%   ���
%   ----
%   FWIND2 ���g���āA0.1����0.5�̊Ԃ�ʉߑш�Ƃ���ߎ��I�ɃT�C�N���b
%   �N�őΏ̂�2�����o���h�p�X�t�B���^��݌v���܂�(���g���͐��K�������
%   ���܂�)�B
%
%       [f1,f2] = freqspace(21,'meshgrid');
%       Hd = ones(21);
%       r = sqrt(f1.^2 + f2.^2);
%       Hd((r<0.1) | (r>0.5)) = 0;
%       win = fspecial('gaussian',21,2);
%       win = win ./ max(win(:));  % �E�B���h�E�̍ő�l���P�ɂ���B
%       h = fwind2(Hd,win);
%       freqz2(h)
%
%   �Q�l : CONV2, FILTER2, FSAMP2, FREQSPACE, FTRANS2, FWIND1



%   Copyright 1993-2002 The MathWorks, Inc.  
