% CSD 2�̐M���̑��݃X�y�N�g�����x(CSD)�̐���
%
% Pxy = CSD(X,Y,NFFT,Fs,WINDOW)�́AWelch�̕��ω��s���I�h�O�����@��p���āA
% �M���x�N�g��X��Y�̃N���X�X�y�N�g�����x�𐄒肵�܂��B����X��Y�̓I�[�o��
% �b�v�����Z�N�V�����ɕ�������A�e�X�̃Z�N�V�����ɂ��āA�g�����h������
% ����܂��B�����āAWINDOW�p�����[�^�ɂ���āA�E�C���h�E���K�p����A����
% NFFT�ɖ����Ȃ������ɂ̓[�����t������܂��BX��Y�̃Z�N�V�����ŁA����NFFT
% ��DFT�̐ς𕽋ω����āA�N���X�X�y�N�g�����x Pxy�����肳��܂��B�����ŁA
% Pxy�́ANFFT�������̏ꍇ�A����(NFFT/2 +1)�̗�x�N�g���AN����̏ꍇ�A
% ����(NFFT +1)/2�̗�x�N�g���ƂȂ�܂��BX�܂���Y�̂ǂ��炩�����f���̏�
% �������l�ł��BWINDOW�ɃX�J�����w�肷��΁A�w�肵��������Hann�E�B���h�E
% ���K�p����܂��BFs�̓T���v�����O���g���ŁA�N���X�X�y�N�g���ɂ͉e������
% �܂��񂪁A�v���b�g�̃X�P�[�����O�Ɏg���܂��B
%
% [Pxy,F] = CSD(X,Y,NFFT,Fs,WINDOW,NOVERLAP)�́ACSD��]������Pxy�Ɠ����T
% �C�Y�̎��g���x�N�g��F���o�͂��܂��B�܂��ANOVERLAP�T���v���ŁA��������
% X,Y���d�ˍ��킹�܂��B
%
% [Pxy, Pxyc, F] = CSD(X,Y,NFFT,Fs,WINDOW,NOVERLAP,P)�́APxy��P*100�p�[
% �Z���g�̐M����Ԃ̐���l���܂񂾃x�N�g��Pxyc���o�͂��܂��B�����ŁAP��0
% ��1�̊Ԃ̐��̃X�J���ł��B
%
% CSD(X,Y,...,DFLAG)�́AX,Y�̃v���E�B���h�E�Z�N�V�����Ƃ��āA�g�����h��
% ���I�v�V������ݒ肷�邱�Ƃ��ł��܂��B�����ŁADFLAG�ɂ́A'linear', 
% 'mean' , 'none'�̂����ꂩ�̕������ݒ�ł��܂��B 
% 
% ����DFLAG�́A���͈����̃��X�g�̍Ō�ɕt���Ȃ���΂Ȃ�܂���B 
%
% ���F  CSD(X,Y,'mean')
% 
% CSD�́A�o�͈�����ݒ肵�Ȃ��ƁA�p�����[�^ P �ɂ���Đݒ肳�ꂽ�M�����
% �ŁACSD���J�����g��Figure�E�B���h�E�Ƀv���b�g���܂��B
%
% �f�t�H���g�̃p�����[�^�̒l�́A���̂悤�ɐݒ肳��Ă��܂��BNFFT = 256
% (�܂��́ALENGTH(X)�̏������l)�ANOVERLAP = 0�AWINDOW = HANNING(NFFT)�A
% Fs = 2�AP = .95�ADFLAG = 'none'�A�ݒ�p�����[�^�ɋ�s��[]���g���āA�f
% �t�H���g�l��ݒ肷�邱�Ƃ��ł��܂��B
% 
% ���F  CSD(X,Y,[],10000).
% 
% �Q�l�F   PSD, COHERE, TFE
%          ETFE, SPA, ARX(System Identification Toolbox)



%   Copyright 1988-2002 The MathWorks, Inc.
