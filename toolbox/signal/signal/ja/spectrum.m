% SPECTRUM   1�܂���2�̃f�[�^��̃p���[�X�y�N�g������ 
% P = SPECTRUM(X,NFFT,NOVERLAP,WIND) �́AWelch �̕��ω�������g����͖@
% ���g���āA�M���̃x�N�g�� X �̃p���[�X�y�N�g�����x���v�Z���܂��B�M�� X 
% �́A�I�[�o���b�v�����������܂�ŕ�������A�X�̕����́A�g�����h������
% ���AWINDOW �p�����[�^�ɂ��E�C���h�E��K�p���A������ NFFT �ȉ��̏ꍇ�A
% �[����t�����܂��B�e�����̒��� NFFT �� DFT �̑傫���̓�悵�����̂���
% �ω�����APxx ���쐬���܂��BP �́AP = {Pxx  Pxxc] �̌^��2��̍s��ł��B
% 2��ڂ� Pxxc �́A95%�̐M����Ԃ��������̂ł��BP �̍s���́ANFFT ������
% �̏ꍇ�ANFFT/2+1�ŁA��̏ꍇ�A(NFFT+1)/2 �ł��B�܂��A�M�� X �����f��
% �̏ꍇ�́ANFFT �ɂȂ�܂��BWINDOW ���X�J���̏ꍇ�A���̒����� Hanning 
% �E�C���h�E���g���܂��B
%
% [P,F] = SPECTRUM(X,NFFT,NOVERLAP,WINDOW,Fs) �́A�T���v�����O���g�� Fs 
% ���g���āAPSD �𐄒肵��Pxx �Ɠ��������̎��g���x�N�g�����o�͂��܂��B
% PLOT(F,P(:,1)) �́A�^�̎��g���ɑ΂���p���[�X�y�N�g��������v���b�g��
% �܂��B
%
% [P, F] = SPECTRUM(X,NFFT,NOVERLAP,WINDOW,Fs,Pr) �́APr ��0����1�̊Ԃ�
% �X�J���l�Őݒ肷��ƁAPSD�ɑ΂��āA�f�t�H���g��95%�̐M����Ԃł͂Ȃ��A
% Pr*100 %�̐M����Ԃ��o�͂��܂��B
%
% �o�͈�����ݒ肵�Ȃ��ŁASPECTRUM(X) �݂̂��g�p����ƁA�J�����g�� Fig-
% ure �E�C���h�E�� PSD ��M����ԂƋ��Ƀv���b�g���܂��B
%
% �f�t�H���g�l�́ANFFT �́A256��A �̒����̓��A�Z���l�AWINDOW = HANNING
% (NFFT)�ANOVERLAP = 0�AFs = 2�APr = 0.95 �ł��B�f�t�H���g�l���g�p�����
% ���́A�g�p�������f�t�H���g�ݒ�l�ȍ~�̃p�����[�^���ȗ����邩�A��s���
% �g�p���܂��B���Ƃ��΁ASPECTRUM(X,[],128) �ł��B
%
% P = SPECTRUM(X,Y) �́A2�̐��� X �� Y �̃X�y�N�g����͂��s���܂��B
% SPECTRUM �́A���̗v�f������8�񂩂�Ȃ�z����o�͂��܂��B
% 
%   P = [Pxx Pyy Pxy Txy Cxy Pxxc Pyyc Pxyc]
% 
% �����ŁA
%   Pxx  = X-�x�N�g���̃p���[�X�y�N�g�����x
%   Pyy  = Y-�x�N�g���̃p���[�X�y�N�g�����x
%   Pxy  = �N���X�X�y�N�g�����x
%   Txy  = X ���� Y = Pxy./Pxx �ւ̕��f�`�B�֐�
%   Cxy  = X �� Y = (abs(Pxy).^2)./(Pxx.*Pyy) �Ƃ̊Ԃ̃R�q�[�����X�֐�
%   Pxxc,Pyyc,Pxyc = �M���͈�
% 
% ���ׂĂ̓��͂Əo�͂̃I�v�V�����́A�P���͂̏ꍇ�ƑS���������̂ł��B
% 
% �o�͈�����ݒ肵�Ȃ��ŁASPECTRUM(X,Y)�݂̂ł̎g�p�́A�v���b�g���Ƀ|�[
% �Y��ݒ肵�Ȃ���A�A���I�ɁAPxx, Pyy, abs(Txy), angle(Txy), Cxy ���v��
% �b�g���܂��B
%
% SPECTRUM(X,...,DFLAG) �́AX �ɃE�B���h�E��O�����ēK�p�������ʂɑ΂��āA
% �g�����h�������@���w�肷��ADFLAG ���A'linear', 'mean', 'none' �̂���
% �ꂩ����ݒ�ł��܂��BDFLAG �́A�����̒��ŔC�ӂ̈ʒu(X �̕����ȊO)�ɐ�
% ��ł��܂��B���Ƃ��΁ASPECTRUM(X,'none') �ł��B
%
% �Q�l�F   PSD, CSD, TFE, COHERE, SPECGRAM, SPECPLOT, DETREND, 
%          PMTM, PMUSIC. 
%          ETFE, SPA, ARX(Identification Toolbox)

%   Copyright 1988-2001 The MathWorks, Inc.
