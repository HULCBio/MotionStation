% PERIODOGRAM �́A�s���I�h�O�����@���g���āA�p���[�X�y�N�g�����x(PSD)��
% �v�Z���܂��B
% 
% Pxx = PERIODOGRAM(X) �́A�x�N�g�� X �Őݒ肳���M���� PSD ������x�N
% �g�� Pxx �ɏo�͂��܂��B�f�t�H���g�ł́AX �Ɠ���������BOXCAR�E�C���h�E
% ���K�p����܂��BPSD ����́A����256���A�܂��́AX�̒������傫��2�̃x
% �L��ŋ��߂��钷���̑傫������ FFT ���v�Z���܂��B
%
% Pxx �́A�P�ʎ��g���ɑ΂���p���[�̕��z�ł��B�����M���ɑ΂��āAPERIOD-
% GRAM �́A�Б� PSD ���f�t�H���g�Ƃ��ďo�͂��܂��B���f���M���̏ꍇ�A����
% PSD ���o�͂��܂��B�Б� PSD �́A���͐M���̂��ׂẴp���[���܂�ł��邱
% �Ƃɒ��ӂ��Ă��������B
%
% Pxx = PERIODOGRAM(X,WINDOW) �́AX �ɓK�p����E�C���h�E��ݒ肵�܂��B
% WINDOW �́AX �Ɠ��������̃x�N�g���ł��BWINDOW �ɔ��^�ȊO�̃E�C���h�E��
% �g�p�������ꍇ�A���ʋ��܂�s���I�h�O�����͕ύX����܂��BWINDOW �ɋ�s
% ���ݒ肷��ƁA�f�t�H���g�̃E�C���h�E���g�p����܂��B
% 
% [Pxx,W] = PERIODOGRAM(X,WINDOW,NFFT) �́APSD ���v�Z���邽�߂Ɏg�p���� 
% FFT �̓_���ł��B�����ɑ΂��āANFFT �������̏ꍇ�A(NFFT/2+1)�ŁA���
% �ꍇ�A(NFFT+1)/2 �ł��B���f���ł́APxx�́A��������� NFFT �ɂȂ�܂��B
% ��̏ꍇ�A�f�t�H���g�́A256 �ł��B
%
% W �́APSD ���v�Z����鐳�K�����ꂽ���g����ݒ肷����̂ł��BW �́Arad
% /�T���v���P�ʂł��B�����M���ɑ΂��āAW �́ANFFT �������̏ꍇ[0,pi]�̋�
% �ԂɍL����ANFFT ����̏ꍇ[0,pi)�͈̔͂ɂȂ�܂��B���f���M���̏ꍇ�A
% W �́A��ɁA[0.2*pi)�̋�Ԃł��B
%
% [Pxx,F] = PERIODOGRAM(X,WINDOW,NFFT,Fs) �́A�����I�Ȏ��g��(Hz)�֐��Ƃ�
% �Čv�Z���ꂽ PSD ���o�͂��܂��BFs �́AHz �P�ʂŕ\�����T���v�����O���g
% ���ŁA�f�t�H���g�ł�1 Hz�ł��B
%
% F �́AHz �P�ʂŕ\���� PSD ���v�Z������g����v�f�Ƃ���x�N�g���ł��B��
% ���M���ɑ΂��āAF�́ANFFT �������̏ꍇ[0,Fs/2]�ŁA��̏ꍇ[0,Fs/2)��
% �͈͂ɍL����܂��B���f���M���ɑ΂��āAF�́A��ɁA[0,Fs)�͈̔͂ł��B
%
% [...] = PERIODOGRAM(...,'twosided') �́A�����M�� X �̗��� PSD ���o�͂�
% �܂��B���̏ꍇ�APxx �́A���� NFFT�ŁAFs ���ݒ肳��Ă��Ȃ��ꍇ�A��� 
% [0,2*pi)�Ōv�Z����AFs ���ݒ肳��Ă���ꍇ�A���[0,Fs)�ɂȂ�܂��B��
% ���A������'twosided'�́A�����M�� X �ɑ΂��镶���� 'onesided'�ƒu������
% ��܂��B����́A�f�t�H���g�̋����Ɠ����ɂȂ�܂��B������ 'twosided' ��
% ���� 'onesided'�́AWINDOW�����̌�̔C�ӂ̈ʒu�Őݒ�ł��܂��B
%
% �o�͈�����ݒ肵�Ȃ� PERIODOGRAM(...) �́A�J�����g�� Figure �E�C���h�E
% �ɒP�ʎ��g���ɑ΂��� PSD ��dB�P�ʂŃv���b�g�\�����܂��B���ꂪ�A�f�t�H
% ���g�ł��B
%
% ���F
%    Fs = 1000;   t = 0:1/Fs:.3;
%    x = cos(2*pi*t*200)+randn(size(t)); % 200Hz �̃R�T�C���g�Ƀm�C�Y��
%                                        % ����������
%    periodogram(x,[],'twosided',512,Fs);% �f�t�H���g�E�C���h�E���g�p
% 
% �Q�l�F   PWELCH, PBURG, PCOV, PYULEAR, PMTM, PMUSIC, PMCOV, 
%          PEIG, PSDPLOT.



%   Copyright 1988-2002 The MathWorks, Inc.
