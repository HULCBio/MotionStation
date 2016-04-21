% PWELCH Welch �@���g���āA�p���[�X�y�N�g�����x���v�Z
% Pxx = PWELCH(X) �́AWelch �̕��ω��A�C���s���I�h�O�����@���g���āA���U
% ���ԐM���x�N�g�� X �̃p���[�X�y�N�g�����x(PSD)�̐�����o�͂��܂��B�f�t
% �H���g�ŁAX ��50�p�[�Z���g�̃I�[�o���b�v������8�̃O���[�v�ɕ������A
% �e�O���[�v�� Hamming �E�C���h�E��K�p���A8�̃O���[�v�̏C���s���I�h�O
% �������v�Z���A���ω����܂��B
%
% X �̒������A50%�̃I�[�o���b�v������8�̃O���[�v�ɐ��m�ɕ����ł��Ȃ���
% ���AX �́A�K�؂ɕ�������܂��B
%
% Pxx �́A�P�ʎ��g���ɑ΂��镪�z�ł��B�f�t�H���g�ł́APWELCH �́A�����M
% ���ł͕Б� PSD �ŁA���f���M���ł͗��� PSD �ł��B�Б� PSD �́A���͐M��
% �̂��ׂẴp���[���܂�ł��邱�Ƃɒ��ӂ��Ă��������B
%
% Pxx = PWELCH(X,WINDOW) �́AX ��WINDOW �̒����ɓ����������ŃI�[�o���b�v
% ���镔���ɕ������AWINDOW �ɐݒ肵���x�N�g���Ŋe�������E�C���h�E������
% �܂��B�����ŁAWINDOW �́A�x�N�g���Őݒ肵�Ă��܂��BWINDOW ����̐���
% �̏ꍇ�AX �͂��̐����l�ɓ����������̕����ɕ�������A���������� Hamming
%  �E�C���h�E���g�p����܂��BX �̒������A50%�̃I�[�o���b�v���s���Ȃ��琮
% ���{�ɐ��m�ɂȂ��Ă��Ȃ��ꍇ�A�K�؂� X �𕪊����܂��BWINDOW ���ȗ�����
% �邩�A�܂��͋�̏ꍇ�A�f�t�H���g�E�C���h�E���AX ��8�ɕ�������������
% �g���܂��B
%
% Pxx = PWELCH(X,WINDOW,NOVERLAP) �́ANOVERLAP �T���v���������I�[�o���b
% �v�����������܂ނ悤�ɕ������܂��BNOVERLAP �́AWINDOW �������̏ꍇ�A
% WINDOW ���������������Z�����̂ɂȂ�܂��BNOVERLAP ���ȗ����ꂽ��A��
% �Őݒ肳���ꍇ�A�f�t�H���g�l�́A50�̃I�[�o���b�v���g���܂��B
%
% [Pxx,W] = PWELCH(X,WINDOW,NOVERLAP,NFFT) �́A PSD ������v�Z���邽�߂�
% FFT �̒�����ݒ肵�܂��B�����ɑ΂��āANFFT �������̏ꍇ�A(NFFT/2+1)�A
% ��̏ꍇ�A(NFFT+1)/2 �ł��B���f���ł́APxx�́A��������� NFFT �ɂȂ�
% �܂��B��̏ꍇ�A�f�t�H���g�́A256 ��X ���e�X�ɕ��������������傫��2
% �̃x�L�搔�̒��ōŏ��̂��̂Ƃ̂ǂ��炩�ő傫�����̂��g���܂��B
%
% PSD ���v�Z���鐳�K�����ꂽ���g������Ȃ�x�N�g�� W ���o�͂��܂��BW ��
% �P�ʂ́Arad/sec�ł��B�����M���ɑ΂��āAW �́ANFFT �������̏ꍇ[0,pi]��
% ��ԂɍL����ANFFT ����̏ꍇ[0,pi)�͈̔͂ɂȂ�܂��B���f���M���̏�
% ���AW �́A��ɁA[0.2*pi)�̋�Ԃł��B
%
% [Pxx,F] = PWELCH(X,WINDOW,NOVERLAP,NFFT,Fs) �́A�����I�ȈӖ��������g
% ��(Hz)�̊֐��Ƃ��� PSD ���v�Z���܂��BFs �́AHz �P�ʂŐݒ肵���T���v��
% ���O���g���ł��BFs ����̏ꍇ�A�f�t�H���g��1 Hz �ɂȂ�܂��B
%
% F �́AHz �P�ʂ̎��g���x�N�g���ŁA�����Őݒ肳��Ă�����g���ŁAPSD ��
% �v�Z���܂��B�����M���ɑ΂��āAF�́ANFFT �������̏ꍇ[0,Fs/2]�ŁA���
% �ꍇ[0,Fs/2)�͈̔͂ɍL����܂��B���f���M���ɑ΂��āAF�́A��ɁA[0,Fs)
% �͈̔͂ł��B
%
% [...] = PWELCH(...,'twosided') �́A�����M�� X �̗��� PSD ���o�͂��܂��B
% ���̏ꍇ�APxx �́A���� NFFT �������AFs ���ݒ肳��Ă��Ȃ��ꍇ�A[0,2*Pi)
% �͈̔́AFs ���ݒ肳��Ă���ꍇ�A[0,Fs) �͈̔͂ł��B�܂��A������ 'tw-
% osided' �́A�����M�� X �ł̃f�t�H���g�ݒ�� 'onesided' ��u�������܂��B
% ������ 'twosided' �܂��́A'onesided' �́A���͈����� NOVERLAP �̌�̔C
% �ӂ̈ʒu�ɐݒ肷�邱�Ƃ��ł��܂��B
%
% �o�͈�����ݒ肵�Ȃ� PWELCH(...) �́A�J�����g�� Figure �E�C���h�E�ɒP
% �ʎ��g���ɑ΂��� PSD �̑傫���� dB �P�ʂŃv���b�g���܂��B
%
% ���F
%      Fs = 1000;   t = 0:1/Fs:.296;
%      x = cos(2*pi*t*200)+randn(size(t));  
%                        % 200Hz �̃R�T�C���g�Ƀm�C�Y�����Z
%      pwelch(x,[],[],[],Fs,'twosided');    
%                        % �E�C���h�E�A�I�[�o���b�v�ʁA
%                        % NFFT �̒l�̓f�t�H���g���g�p 
% 
% �Q�l�F   PERIODOGRAM, PCOV, PMCOV, PBURG, PYULEAR, PEIG, PMTM, 
%          PMUSIC, PSDPLOT



%   Copyright 1988-2002 The MathWorks, Inc.
