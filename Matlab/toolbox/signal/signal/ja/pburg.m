% PBURG    Burg �@���g���āA�p���[�X�y�N�g�����x(PSD)���v�Z
% Pxx = PBURG(X,ORDER) �́A���U���ԐM���x�N�g�� X �� PSD ���A�x�N�g�� 
% Pxx �ɏo�͂��܂��BPxx �́A�P�ʎ��g���ɑ΂���p���[�̕��z�������Ă��܂��B
% ���g���́Arad/sec�P�ʂŕ\������܂��BORDER �́APSD ���v�Z���邽�߂Ɏg
% �p���鎩�ȉ�A(AR)���f���̎����ł��BPBURG �́A�f�t�H���g��256�̒����� 
% FFT ���g���A������x�[�X�� Pxx�̒��������肵�܂��B
%
% �f�t�H���g�ł́APBURG �́A���M���ɑ΂��ĕБ� PSD ���A���f���ɑ΂��ė�
% ��PSD ���v�Z�o�͂��܂��B�Б� PSD �́A���͐M���̂��ׂẴp���[���܂��
% ���邱�Ƃɒ��ӂ��Ă��������B
%
% Pxx = PBURG(X,ORDER,NFFT) �́APSD ���v�Z����Ƃ��Ɏg�p����FFT �̒�����
% �ݒ肵�܂��B�����ɑ΂��āANFFT �������̏ꍇ�A(NFFT/2+1)�ŁA��̏ꍇ�A
% (NFFT+1)/2 �ł��B���f���ł́APxx�́A��������� NFFT �ɂȂ�܂��B��̏�
% ���A�f�t�H���g�́A256 �ł��B
%
% [Pxx,W] = PBURG(...) �́APSD ���v�Z���鐳�K�����ꂽ�p���g������Ȃ�x
% �N�g�� W ���o�͂��܂��BW �̒P�ʂ́Arad/sec�ł��B�����M���ɑ΂��āAW �́A
% NFFT �������̏ꍇ[0,pi]�̋�ԂɍL����ANFFT ����̏ꍇ[0,pi)�͈̔͂�
% �Ȃ�܂��B���f���M���̏ꍇ�AW �́A��ɁA[0.2*pi)�̋�Ԃł��B
%
% [Pxx,F] = PBURG(...,Fs) �́A�T���v�����O���g��Fs�� Hz �P�ʂŐݒ肵�AHz
% ���Ƀp���[�X�y�N�g�����x���o�͂��܂��BF �́AHz �P�ʂ̎��g���x�N�g����
% �����Őݒ肳��Ă�����g���_�ŁAPSD ���v�Z���܂��B�����M���ɑ΂��āAF
% �́ANFFT �������̏ꍇ[0,Fs/2]�ŁA��̏ꍇ[0,Fs/2)�͈̔͂ɍL����܂��B
% ���f���M���ɑ΂��āAF�́A��ɁA[0,Fs)�͈̔͂ł��BFs����ɂ���ƁA�f�t
% �H���g�̃T���v�����O���g��1 Hz ���g���܂��B
%
% [Pxx,W] = PBURG(...,'twosided') �́A���[0,2*pi)�ŁAPSD ���o�͂��܂��B
% �܂��A[Pxx,F] = PBURG(...,Fs,'twosided') �́A���[0,Fs)�ŁAPSD ���v�Z
% ���܂��B'onesided'(�Б�)�́A�I�v�V�����Ƃ��Đݒ�ł��܂����A������ X 
% �ɑ΂��Ă̂ݎg�p�ł�����̂ł��B������ 'twosided' �܂��� 'onesided' �́A
% ���͈��� ORDER �̌�̔C�ӂ̈ʒu�ɐݒ肷�邱�Ƃ��ł��܂��B
%
% �o�͈�����ݒ肵�Ȃ� PBURG(...) �́A�J�����g�� Figure �E�C���h�E�ɒP��
% ���g���ɕt���AdB �P�ʂł� PSD ���v���b�g���܂��B
%
% ���F
%      randn('state',1); x = randn(100,1); 
%      y = filter(1,[1 1/2 1/3 1/4 1/5],x); % 4���� AR �t�B���^
%      pburg(y,4,[],1000);   % �f�t�H���g�� NFFT �� 256 ���g�p
%
% �Q�l�F   PCOV, PMCOV, PYULEAR, PMTM, PMUSIC, PEIG, PWELCH, 
%          PERIODOGRAM, ARBURG, PRONY, PSDPLOT.
% 
%% 210 %%%%%%%%%%%%%%%



%   Copyright 1988-2002 The MathWorks, Inc.
