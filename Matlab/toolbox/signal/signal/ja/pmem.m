% PMEM   MEM(�ő�G���g���s�[�@)���g���āA�p���[�X�y�N�g�����x���v�Z
% Pxx = PMEM(X,ORDER,NFFT) �́AMEM �@���g���āA�M���x�N�g�� X �̃p���[�X
% �y�N�g�����x���v�Z���܂��BORDER �́AAR ���f���������̃��f�������ł��B
% NFFT �́AFFT �̒����ŁA���g���O���b�h�����肵�܂��BX ���f�[�^�s��̏�
% ���A�e��́A�قȂ�Z���T�܂��͎�������̑���l�ƍl���܂��BPxx �́ANFFT
% �������̏ꍇ�A����(NFFT/2+1)�A��̏ꍇ�A(NFFT+1)/2�ł��BX�����f����
% �ꍇ�A������ NFFT �ɂȂ�܂��BNFFT �̓I�v�V�����ŁA�f�t�H���g�l��256��
% ���B
%
% [Pxx,F] = PMEM(X,ORDER,NFFT,Fs) �́APSD ���v�Z�������g���x�N�g�����o
% �͂��܂��B�����ŁAFs �́A�T���v�����g���ł��BFs�̓f�t�H���g�� 2Hz�ł��B
%
% PMEM(X,ORDER,'corr'), PMEM(X,ORDER,NFFT,'corr'), PMEM(X,ORDER,NFFT,...
% Fs,'corr') �́A���֍s�� X ���g���܂��BX �́A�����s��ł��B
%
% [Pxx,F,A] = PMEM(X,ORDER,NFFT) �́APxx ���x�[�X�ɂ������f���W���̃x�N
% �g�� A ���o�͂��܂��B
%
% �o�͈�����ݒ肵�Ȃ��ꍇ�́APMEM �́A�g�p�\�ȃt�B�M���A�� PSD ���v��
% �b�g���܂��B
% 
% �f�t�H���g�l���g�p����ꍇ�́A��s���ݒ肵�Ă��������B���Ƃ��΁A��
% �̂悤�ɐݒ肵�܂��B
% 
%     PMEM(X,8,400,[],'corr').
%
% �Q�l�F   PBURG, PCOV, PMCOV, PMTM, PMUSIC, PWELCH, PYULEAR, LPC, PRONY

%   Copyright 1988-2001 The MathWorks, Inc.
