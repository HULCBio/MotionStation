% function P = vspect(x,y,m,noverlap,window)
%
% Signal Processing Toolbox��SPECTRUM�̂悤�Ƀ��f�������ꂽ�X�y�N�g����
% �̓��[�`���ł��BX(�ƃI�v�V������Y)�́A���Ԃ̒�`��̗��\�킷VARYING
% �s��ł��BM�_��fft���ANOVERLAP�_�̃I�[�o���b�v�Ƌ��Ɏg���܂��BWINDOW
% �́A�I�v�V�����̕�����ŁA�E�B���h�E���w�肵�܂�(�f�t�H���g��'hanning'
% �ł�)�B���݁ASignal Processing toolbox�ŃT�|�[�g����Ă���I�v�V�����́A
% 'hanning', 'hamming', 'boxcar', 'blackman', 'bartlett', 'triang'�ł��B%
% �o�͂��ꂽVARYING�s��P�́A��[Pxx Pyy Pxy Txy Cxy]�������܂��BPxx(Pyy)
% �́AX (Y)�̃p���[�X�y�N�g���ŁAPxy�̓N���X�X�y�N�g���ATxy�͓`�B�֐��A
% Cxy�́A�R�q�[�����X�ł��B�P��̓��͗�ɑ΂��ẮAPxx�݂̂��o�͂���܂��B
% �o�͂����Ɨ��ϐ��́A���W�A��/�b�P�ʂ̎��g���ł��B�M��Y(�܂��́A�P��
% �M���̏ꍇ�ɂ�X)�́A�M���x�N�g���ł��B�e�X�̏o�͂ɑ΂��āA�`�B�֐����v
% �Z����܂��B����́A�P���͑��o�͓`�B�֐��̐���ɑΉ����܂��BP�̊e�s�́A
% �K�؂�Y�̍s�ɑΉ����܂��B
%
% �Q�l: FFT, IFFT, SPECTRUM, VFFT, VIFFT.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
