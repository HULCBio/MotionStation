% TFE �́A���͂Əo�͂���`�B�֐��𐄒肵�܂��B
%
% Txy = TFE(X,Y,NFFT,Fs,WINDOW) �́AWelch �̕��ω��s���I�h�O�����@���g��
% �āA����X �Əo�� Y �����V�X�e���̓`�B�֐��𐄒肵�܂��B���͈��� X ��
% Y �́A�I�[�o���b�v���������ɕ�������A�g�����h����������܂��B�����āA
% WINDOW �p�����[�^�ɂ���āA�E�C���h�E���K�p����A���� NFFT �ɖ����Ȃ�
% �����ɂ̓[�����t������܂��BX �̕����̒��� NFFT �� DFT �̑傫����2���
% ���ς��āA�p���[�X�y�N�g�����x Pxx �����肳��܂��BX �� Y �̕����̒���
% NFFT �� DFT �̐ς𕽋ς��āAX �� Y �̃N���X�X�y�N�g�����x Pxy �𐄒肵
% �܂��BTxy �́AX �� Y �̃N���X�X�y�N�g�� Pxy �� X �̃p���[�X�y�N�g�� Pxx
% �̔�ŕ\����܂��B���Ȃ킿�ANFFT �������̏ꍇ�A����(NFFT/2 +1)�̗�x�N
% �g���ANFFT ����̏ꍇ�A����(NFFT +1)/2�̗�x�N�g���ɂȂ�AX �܂��� Y
% �����f���̏ꍇ�́ANFFT �ɂȂ�܂��BWINDOW �ɃX�J�����w�肵�Ă���ꍇ�A
% �w�肵��������Hanning �E�B���h�E���K�p����܂��BFs �̓T���v�����O���g
% ���ŁA����ɂ͉e������܂��񂪁A�v���b�g�̃X�P�[�����O�Ɏg���܂��B�@
% 
% [Txy,F] = TFE(X,Y,NFFT,Fs,WINDOW,NOVERLAP) �́A�`�B�֐�����l���Z�o��
% �� Txy �Ɠ����T�C�Y�̎��g���̃x�N�g�� F ���o�͂��܂��B�܂��ANOVERLAP 
% �T���v�����ŁA�������� X,Y ���d�ˍ��킹�܂��B
%
% TFE(X,Y,...,DFLAG) �́AX �� Y �̃E�C���h�E��O�����ēK�p���������ɓK�p
% ����g�����h�������@��ݒ肵�܂��B�����ŁA�g�p�\�ȕ��@�́A'linear', 
% 'mean', 'none' �ł��BDFLAG �́AX �� Y �̈ʒu�������āA���͈�����C�ӂ�
% �ʒu�ɐݒ�ł��܂����A�ł��邾���A�Ō�A���Ƃ��΁ATFE(X,Y,'mean') �̂�
% ���Ɏg�p�ł��܂��B�o�͈�����ݒ肵�Ȃ��ŁA�֐� TFE ���g�p����ƁA�J��
% ���g�� Figure �E�C���h�E�ɓ`�B�֐����v���b�g���܂��B
% 
% �f�t�H���g�̃p�����[�^�̒l�́A���̂悤�ɐݒ肳��Ă��܂��BNFFT = 256
% (�܂��́ALENGTH(X)�̏������l)�ANOVERLAP = 0, WINDOW = HANNING(NFFT), 
% Fs = 2, P = .95, DFLAG = 'none' �ݒ�p�����[�^�ɋ�s��[]���g���āA�f�t
% �H���g�l��ݒ肷�邱�Ƃ��ł��܂��B���Ƃ��΁ATFE(X,Y,[],10000) �ł��B
%
% �Q�l�F   PSD, CSD, COHERE
%          ETFE, SPA, ARX(Identification Toolbox)



%   Copyright 1988-2002 The MathWorks, Inc.
