% PSD �́A�p���[�X�y�N�g�����x�̐�����s���܂��B
% Pxx = PSD(X,NFFT,Fs,WINDOW) �́AWelch�̕��ω��A�C���s���I�h�O�����@��
% �g���āA���U���ԐM���x�N�g�� X �̃p���[�X�y�N�g�����x�����߂܂��B
% 
% X �́A�I�[�o���b�v�̕����ɕ����A���̊e�X�ŁA�֐� DETREND �� FLAG �Ő�
% �肵�����@���g���āA�g�����h�̏������s���A���̌��ʂ� WINDOW �p�����[�^
% ���g���ăE�C���h�E������s���A������ NFFT �ɂȂ�悤�Ƀ[����t�����܂��B
% �e�����ł̒��� NFFT ��DFT �̌��ʂ̑傫���̓��̕��ς��g���āAPxx ����
% �����܂��BPxx �́ANFFT �������̏ꍇ�ANFFT/2+1 �ŁANFFT ����̏ꍇ�A
% (NFFT+1)/2 �ɂȂ�A�܂��A�M�� X �����f���̏ꍇ�ANFFT �ɂȂ�܂��BWIN-
% DOW �ɃX�J���l���ݒ肳��Ă���ꍇ�A���̒�����Hanning �E�B���h�E���g��
% ��܂��BFs �́A�X�y�N�g������ɉe�����Ȃ��T���v�����O���g���ŁA�v���b
% �g�ł́@X-���̃X�P�[�����O�Ɏg�p���܂��B
%
% [Pxx,F] = PSD(X,NFFT,Fs,WINDOW,NOVERLAP) �́APSD ���v�Z������g���x�N
% �g���� Pxx �Ɠ����傫���ŏo�͂��܂��B�����ŁAX �̕����́ANOVERLAP ��
% �T���v�����I�[�o���b�v���Ă��܂��B
%
% [Pxx, Pxxc, F] = PSD(X,NFFT,Fs,WINDOW,NOVERLAP,P) �́APxx �ɑ΂��� 
% P*100 %�̐M����Ԃ��o�͂��܂��B�����ŁAP �́A0����1�̊Ԃ̃X�J���l�ł��B
%
% PSD(X,...,DFLAG) �́AX �ɃE�B���h�E��O�����ēK�p�������ʂɑ΂��āA�g
% �����h�������@���w�肷��DFLAG ���A'linear', 'mean', 'none' �̂����ꂩ
% ��ݒ�ł��܂��BDFLAG �́A�����̒��ŔC�ӂ̈ʒu(X �̕����ȊO)�ɐݒ�ł�
% �܂��B���Ƃ��΁APSD(X,'mean') �ł��B
% 
% �o�͈�����ݒ肵�Ȃ� PSD �́A�J�����g�� Figure �E�C���h�E�� PSD ���v��
% �b�g���AP ���ݒ肳��Ă���ꍇ�́A�M����Ԃ��\�����܂��B
%
% �p�����[�^�΂���f�t�H���g�l�́ANFFT = 256 (�܂��� LENGTH(X) �Ɣ�ׂ�
% �������ق�)�ANOVERLAP = 0, WINDOW = HANNING(NFFT), Fs = 2, P = .95, 
% DFLAG = 'none' �ł��B�f�t�H���g�p�����[�^���g�p����ɂ́A��s���ݒ�
% ���邩�A�ȗ����Ă��������B���Ƃ��΁APSD(X,[],10000) �ł��B
%
% ���ӁF
% Welch �@�́A�T���v�����O���g��(1/Fs)�ŃX�P�[�����O����悤�ɂȂ��Ă���
% ���B�ڍׂ́A�֐� PWELCH ���Q�Ƃ��Ă��������B
%
% �Q�l�F   PWELCH, CSD, COHERE, TFE.
%          ETFE, SPA, ARX(System Identification Toolbox)

%   Copyright 1988-2001 The MathWorks, Inc.
