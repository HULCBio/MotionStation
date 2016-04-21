% BODE   LTI���f���� Bode ���}���v�Z�A�쐬
%
% BODE(SYS) �́ALTI���f�� SYS(TF�AZPK�ASS�A�܂��́AFRD �̂����ꂩ�ō쐬
% ���ꂽ)�� Bode ���}��`���܂��B���g���ш�≞�����v�Z����_���͎����I
% �ɑI������܂��B
%
% BODE(SYS,{WMIN,WMAX}) �́AWMIN ���� WMAX �܂ł̎��g���ш�(���W�A��/�b
% ��)�ɑ΂��āABode ���}��`���܂��B
%
% BODE(SYS,W) �́A���[�U�����W�A��/�b�Ŏw�肵�����g���x�N�g�� W �𗘗p��
% �āA���̓_�� Bode ���}���v�Z����܂��B�ΐ��X�P�[���ł̎��g���x�N�g����
% �쐬�ɂ��ẮALOGSPACE ���Q�Ƃ��Ă��������B
%
% BODE(SYS1,SYS2,...,W) �́A������ LTI �V�X�e�� SYS1,SYS2,... �� Bode 
% ���}��1�̃v���b�g�ɂ��܂��B���g���x�N�g�� W �́A�I�v�V�����ł��B����
% �悤�ɁA�J���[�A���C���X�^�C���A�}�[�J���e�V�X�e�����Ɏw�肷�邱�Ƃ�
% �ł��܂��B
% 
%   bode(sys1,'r',sys2,'y--',sys3,'gx')
%
% [MAG,PHASE] = BODE(SYS,W) �� [MAG,PHASE,W] = BODE(SYS) �́A�Q�C���Ɠx
% �P�ʂł̈ʑ��̉���(�v�Z�����s������g���̃x�N�g�� W ��ݒ肵�Ă��Ȃ���
% ���A������܂߂�)���o�͂��܂��B���̏ꍇ�A��ʂɃv���b�g�͏o�͂��܂���B
% SYS ���ANU ���� NY �o�͂̏ꍇ�AMAG �� PHASE �́A�T�C�Y [NY NU LENGTH(W)]
% �̔z��ł��B�����ŁAMAG(:,:,k) �� PHASE(:,:,k) �́A���g�� W(k) �ł�
% �����ł��B�Q�C���� dB �œ���ɂ́AMAGDB = 20*log10(MAG) �Ɠ��͂���
% ���������B
%
% �T���v������ Ts �̗��U���ԃ��f���ɑ΂��āABODE �͒P�ʉ~�������g������
% �Ɏʑ����邽�߂ɕϊ� Z = exp(j*W*Ts) �𗘗p���܂��B���g�������́ANyq-
% uist ���g�� pi/Tz ��菬�������g����ł̂݃v���b�g����ATs ���ȗ�����
% �����ɂ́A�f�t�H���g�l�Ƃ���1(�b)�����肳��܂��B
%
% �Q�l : BODEMAG, NICHOLS, NYQUIST, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.


%   Authors: P. Gahinet  8-14-96
%   Revised: A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
