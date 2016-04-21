% PMTM  Thomson ��Multitaper �@(MTM)���g���āA�p���[�X�y�N�g�����x���v�Z
% 
% Pxx = PMTM(X) �́A���U���ԐM�� X �� PSD ���A�x�N�g�� Pxx �ɏo�͂��܂��B
% Pxx �́A�P�ʎ��g���ɑ΂���p���[�̕��z�ł��B���g���́Arad/�T���v���P��
% �ŕ\�킵�Ă��܂��BPMTM �́A�f�t�H���g�� FFT �̒����A256���A�܂��� X ��
% �������傫��2�̃x�L�搔�Ƃ��đ傫���ق����g���܂��BFFT �̒����́APxx
% �̒��������肵�܂��B
%
% PMTM �́A�����M���ɑ΂��āA�Б� PSD ���A���f���M���ɑ΂��āA���� PSD 
% ���o�͂��܂��B�Б� PSD �́A���͐M���̂��ׂẴp���[���܂�ł��邱�Ƃ�
% ���ӂ��Ă��������B
%
% Pxx = PMTM(X,NW) �́A�f�[�^�E�B���h�E�Ƃ��Ďg�p���闣�U Slepian �����
% �΂��āA"���ԂƑш敝�̐�"�Ƃ��āANW ��ݒ肵�A��ʓI�ɂ́A2, 5/2, 3, 
% 7/2, 4�̂����ꂩ���g�p���܂��BPxx ���쐬����Ƃ��Ɏg�p���鐔��̐��́A
% 2*NW-1�ł��B���ݒ肷�邩�A�ȗ�����ƁANW �́A�f�t�H���g��4���g�p����
% ���B
% 
% Pxx = PMTM(X,NW,NFFT) �́A PSD ������v�Z���邽�߂� FFT �̒�����ݒ肵
% �܂��B�����ɑ΂��āANFFT �������̏ꍇ�A(NFFT/2+1)�ŁA��̏ꍇ�A(NFFT
% +1)/2 �ł��B���f���ł́APxx�́A��������� NFFT �ɂȂ�܂��B��̏ꍇ�A
% �f�t�H���g�́A256 ��X �̒������傫��2�̃x�L�搔�̒��ōŏ��̂��̂Ƃ�
% �Ԃő傫�����̂��g���܂��B
%
% [Pxx,W] = PMTM(...) �́APSD ���v�Z���鐳�K�����ꂽ�p���g������Ȃ�x�N
% �g�� W ���o�͂��܂��BW �̒P�ʂ́Arad/�T���v���ł��B�����M���ɑ΂��āAW
% �́ANFFT �������̏ꍇ[0,pi]�̋�ԂɍL����ANFFT ����̏ꍇ[0,pi)�̔�
% �͂ɂȂ�܂��B���f���M���̏ꍇ�AW �́A��ɁA[0.2*pi)�̋�Ԃł��B
%
% [Pxx,F] = PMTM(...,Fs) �́A�T���v�����O���g���� Hz �P�ʂŐݒ肵�AHz ��
% �Ƀp���[�X�y�N�g�����x���o�͂��܂��BF �́AHz �P�ʂ̎��g���x�N�g���ŁA
% �����Őݒ肳��Ă�����g���ŁAPSD ���v�Z���܂��B�����M���ɑ΂��āAF�́A
% NFFT �������̏ꍇ[0,Fs/2]�ŁA��̏ꍇ[0,Fs/2)�͈̔͂ɍL����܂��B��
% �f���M���ɑ΂��āAF�́A��ɁA[0,Fs)�͈̔͂ł��BFs����ɂ���ƁA�f�t�H
% ���g�̃T���v�����O���g��1 Hz ���g���܂��B
%
% [Pxx,F] = PMTM(...,Fs,method) �́A�X�̃X�y�N�g������Ƃ̑g�ݍ��킹��
% �΂��āAmethod �̐ݒ�ɏ]�����A���S���Y�����g�p���܂��B
% 
%  'adapt'  - Thomson 's adaptive non-linear combination(�K������`����)
%             (�f�t�H���g)
%  'unity'  - �P�ʏd�݂��g�������`����
%  'eigen'  - �ŗL�l���d�݂Ƃ�����`����
%
% [Pxx,Pxxc,F] = PMTM(...,Fs,method) �́APxx�@�ɑ΂��āA95%�̐M����� 
% Pxxc ���o�͂��܂��B
% 
% [Pxx,Pxxc,F] = PMTM(...,Fs,method,P) �́APxx �ɑ΂���P*100�̐M����Ԃ�
% �o�͂��܂��B�����ŁAP �́A0��1�̊Ԃ̃X�J���l�ł��B�M����Ԃ́A�ԓ��A
% �v���[�`���g���Čv�Z���܂��BPxxc(:,1) �͐M����Ԃ̉����APxxc(:,2) �͏�
% ���ł��B��Őݒ肷�邩�A�ȗ�����ƁAP �́A.95 �ɂȂ�܂��B
%
% [Pxx,Pxxc,F] = PMTM(X,E,V,NFFT,Fs,method,P) �́A E �̃f�[�^�e�[�p�ƏW
% ���x V ���� PSD ����A�M����ԁA���g���x�N�g�����v�Z���܂��B�s�� E ��
% �x�N�g�� V �̏ڍׂ́AHELP DPSS �ƃ^�C�v���Ă��������B
%
% [Pxx,Pxxc,F] = PMTM(X,DPSS_PARAMS,NFFT,Fs,method,P) �́A�f�[�^�e�[�p��
% �v�Z���邽�߂ɓ��͈�����DPSS(�ŏ��̈����������āA�ݒ菇�Ԃ͂��̂܂�)��
% �܂񂾃Z���z�� DPSS_PARAMS ���g���܂��B���Ƃ��΁APMTM(x,{3.5,'trace'},
% 512,1000) �́ANW = 3.5,NFFT = 512, Fs = 1000���g���ė��U�G����]�ȉ~��
% ����v�Z���A���̌v�Z�̂��߂�DPSS ���g�p������@��\�����܂��B���̃I�v
% �V�����ɂ��ẮAHELP DPSS �ƃ^�C�v���Ă��������B
%
% [...] = PMTM(...,'two-sided') �́A�����M�� X �̗��� PSD ���o�͂��܂��B
% ���̏ꍇ�APxx �́A���� NFFT ���g���AFs ���ݒ肳��Ă��Ȃ��ꍇ�A���
% [0,2*Pi)�ŁAFs ���ݒ肳��Ă���ꍇ�A[0,Fs)�Ōv�Z���܂��B����A������
% 'twosided' �́A�����M�� X �ɑ΂��āA������'onesided'(�f�t�H���g)�ƒu��
% �����邱�Ƃ��ł��܂��B  
%
% ��������͈����́AE �� V ���ݒ肳��Ȃ�����A���͈����̓�Ԗڈȍ~�̔C
% �ӂ̈ʒu�ɐݒ�ł��܂��BE �� V ���ݒ肳���ꍇ�́A�O�Ԗڈȍ~�̔C�ӂ�
% �ʒu�ɐݒ�ł��܂��B
%
% �o�͈�����ݒ肵�Ȃ� PMTM(...) �́A�J�����g�� Figure �E�C���h�E�ɁAPSD
% �Ƃ��̐M����Ԃ�\�����܂��B
%
% ���F
%     Fs = 1000;   t = 0:1/Fs:.3;  
%     x = cos(2*pi*t*200)+randn(size(t)); 
%                             % 200Hz �̃R�T�C���Ƀm�C�Y������������
%     pmtm(x,3.5,Fs);         % �f�t�H���g�� NFFT ���g�p
%
% �Q�l�F   PSDPLOT, DPSS, PWELCH, PMUSIC, PBURG, PYULEAR, PCOV, 
%          PMCOV, PEIG.



%   Copyright 1988-2002 The MathWorks, Inc.
