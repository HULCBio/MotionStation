% COHERE 2�̐M���Ԃ̃R�q�[�����X�֐��̐���
%
% Cxy = COHERE(X,Y,NFFT,Fs,WINDOW)�́AWelch�̕��ω��s���I�h�O�����@���g
% ���āAN �̐M���x�N�g��X��Y�̊Ԃ̃R�q�[�����X�����߂܂��B�R�q�[�����X�́A
% 0����1�̊Ԃ̒l�ŕ\�������g���̊֐��ŁA�e���g���œ���X��Y�Ƃ̊֌W�̓x
% �����������̂ł��B����X��Y�̓I�[�o���b�v�����Z�N�V�����ɕ�������A�g��
% ���h����������܂��B�����āAWINDOW�p�����[�^�ɂ���āA�E�C���h�E���K�p
% ����A����NFFT�ɖ����Ȃ������ɂ̓[�����t������܂��B�Z�N�V����X�ƃZ�N
% �V����Y�Œ���NFFT��DFT�̌��ʂ̑傫���̓��𕽋ς��āAX,Y�̊e�p���[�X
% �y�N�g�����x Pxx�����Pyy�����肳��܂��B����NFFT��DFT�������̂̐ς�
% �ω����āA�Z�N�V���� X,Y�ɑ΂���N���X�X�y�N�g�����x Pxy�����肳��܂��B
% �R�q�[�����XCxy�́A���̂悤�ɕ\����܂��B
%
%    Cxy = (abs(Pxy).^2)./(Pxx.*Pyy)
%
% �o��Cxy�́ANFFT�������̏ꍇ�A����(NFFT/2 +1)�̗�x�N�g���ANFFT�����
% �ꍇ�A����(NFFT +1)/2�̗�x�N�g���ƂȂ�܂��BX�܂���Y�����f���̏ꍇ��
% ���l�ł��BWINDOW�ɃX�J�����w�肷��΁A�w�肵��������Hann�E�B���h�E���K
% �p����܂��BFs�̓T���v�����O���g���ŁA�N���X�X�y�N�g���ɂ͉e������܂�
% �񂪁A�v���b�g�̃X�P�[�����O�Ɏg���܂��B�@�@
%
% [Cxy,F] = COHERE(X,Y,NFFT,Fs,WINDOW,NOVERLAP)�́A�R�q�[�����X���Z�o��
% ��Cxy�Ɠ����T�C�Y�̎��g���̃x�N�g��F���o�͂��܂��B�܂��ANOVERLAP�T���v
% ���ŁA��������X,Y���d�ˍ��킹�܂��B
%
% COHERE(X,Y,...,DFLAG)�́AX,Y�̃v���E�B���h�E�Z�N�V�����Ƃ��āA�g�����h
% �����I�v�V������ݒ肷�邱�Ƃ��ł��܂��B�����ŁADFLAG�ɂ́A'linear', 
% 'mean' , 'none' �̂����ꂩ���g�p�ł��܂��B����DFLAG�́A���͈����̃��X
% �g�̍Ō�ɕt���Ȃ���΂Ȃ�܂���B���Ƃ��΁ACOHERE(X,Y,'mean') �ł��B
%
% COHERE�́A�o�͈�����ݒ肵�Ȃ��ƁA���g���ɑ΂���R�q�[�����X����l���J
% �����g��Figure�E�B���h�E�Ƀv���b�g���܂��B
%
% �f�t�H���g�̃p�����[�^�̒l�́A���̂悤�ɐݒ肳��Ă��܂��BNFFT = 256
% (�܂��́ALENGTH(X)�̏������l)�ANOVERLAP = 0, WINDOW = HANN(NFFT), Fs =
% 2, P = .95, DFLAG = 'none' �ݒ�p�����[�^�ɋ�s��[]���g���āA�f�t�H��
% �g�l��ݒ肷�邱�Ƃ��ł��܂��B
% 
% ���F  COHERE(X,Y,[],10000).
%
% �Q�l�F   PSD, CSD, TFE.
%          ETFE, SPA, ARX (Identification Toolbox)



%   Copyright 1988-2002 The MathWorks, Inc.
