% PYULEAR   Yule-Walker �@���g���āA�p���[�X�y�N�g�����x(PSD)���v�Z
% Pxx = PYULEAR(X,ORDER) �́A���U���ԐM���x�N�g�� X �� PSD �� Pxx �ɏo��
% ���܂��BPxx �́A�P�ʎ��g���ɑ΂���p���[�̕��z���������̂ł��B���g���́A
% rad/�T���v���Ŏ����܂��BORDER �́APSD ���쐬���邽�߂Ɏg�p���鎩�ȉ�A
% (AR)���f���̎����ł��BPYULEAR �́A�f�t�H���g��256�� FFT ���g���āAPxx 
% �̒��������肵�܂��B
%
% PYULEAR �́A�����M���̏ꍇ�A�f�t�H���g�ŁA�Б� PSD �ŁA���f���M���̏�
% ���A���� PSD �ɂȂ�܂��B�Б� PSD �́A���͐M���̂��ׂẴp���[���܂��
% ���邱�Ƃɒ��ӂ��Ă��������B
%
% Pxx = PYULEAR(X,ORDER,NFFT) �́A PSD ������v�Z���邽�߂� FFT �̒�����
% �ݒ肵�܂��B�����ɑ΂��āANFFT �������̏ꍇ�A(NFFT/2+1)�ŁA��̏ꍇ
% (NFFT+1)/2 �ł��B���f���ł́APxx�́A��������� NFFT �ɂȂ�܂��B��̏�
% ���A�f�t�H���g��256�ł��B
%
% [Pxx,W] = PYULEAR(...) �́APSD ���v�Z���鐳�K�����ꂽ�p���g������Ȃ�
% �x�N�g�� W ���o�͂��܂��BW �̒P�ʂ́Arad/�T���v���ł��B�����M���ɑ΂�
% �āAW �́ANFFT �������̏ꍇ[0,pi]�̋�ԂɍL����ANFFT ����̏ꍇ[0,
% pi)�͈̔͂ɂȂ�܂��B���f���M���̏ꍇ�AW �́A��ɁA[0.2*pi)�̋�Ԃł��B
%
% [Pxx,F] = PYULEAR(...,Fs) �́A�T���v�����O���g���� Hz �P�ʂŐݒ肵�AHz
% ���Ƀp���[�X�y�N�g�����x���o�͂��܂��BF �́AHz �P�ʂ̎��g���x�N�g���ŁA
% �����Őݒ肳��Ă�����g���ŁAPSD ���v�Z���܂��B�����M���ɑ΂��āAF�́A
% NFFT �������̏ꍇ[0,Fs/2]�ŁA��̏ꍇ[0,Fs/2)�͈̔͂ɍL����܂��B��
% �f���M���ɑ΂��āAF�́A��ɁA[0,Fs)�͈̔͂ł��BFs����ɂ���ƁA�f�t�H
% ���g�̃T���v�����O���g��1 Hz ���g���܂��B 
%
% [Pxx,W] = PYULEAR(...,'twosided') �́A[0,2*pi) ��Ԃł� PSD ���v�Z����
% ���B�����āA [Pxx,F] = PYULEAR(...,Fs,'twosided') �́A[0,Fs) ��Ԃł� 
% PSD ���v�Z���܂��B'onesided' �́A�I�v�V�����Őݒ�ł��܂����AX ������
% �̂Ƃ��ɂ̂ݓK�p�ł��邱�Ƃɒ��ӂ��Ă��������B������ 'twosided' �܂���
% 'onesided' �́A���͈����̒��� ORDER �̌�̔C�ӂ̈ʒu�ɐݒ�ł��܂��B
%
% �o�͈�����ݒ肵�Ȃ� PYULEAR(...) �́A�J�����g�� Figure �E�C���h�E�ɒP
% �ʎ��g���ɑ΂��� PSD �̑傫���� dB �P�ʂŃv���b�g���܂��B
%
% ���F
%      randn('state',1);
%      x = randn(100,1);
%      y = filter(1,[1 1/2 1/3 1/4 1/5],x);
%      pyulear(y,4,[],1000);       % NFFT �̃f�t�H���g�l 256 ���g�p
%
% �Q�l�F   PBRUG, PCOV, PMCOV, PMTM, PMUSIC, PWELCH, PERIODOGRAM, 
%          PEIG, ARYULE, PRONY, PSDPLOT.



%   Copyright 1988-2002 The MathWorks, Inc.
