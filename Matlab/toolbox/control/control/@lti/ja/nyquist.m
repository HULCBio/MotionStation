% NYQUIST   LTI���f����Nyquist���g������
%
% NYQUIST(SYS) �́ALTI���f��(TF, ZPK, SS �܂��� FRD �̂����ꂩ�ō쐬��
% �ꂽ) SYS ��Nyquist���}���v���b�g���܂��B���g���ш�Ɠ_���́A�����I��
% �I������܂��B���U���Ԃ̎��g���ɂ��Ă̒��ӎ����̏ڍׂ́ABODE ������
% ���������B
%
% NYQUIST(SYS,{WMIN,WMAX}) �́AWMIN ���� WMAX �܂ł̎��g����(���W�A��/�b
% ��)�ɑ΂��āANyquist ���}���v���b�g���܂��B
%
% NYQUIST(SYS,W) �́A���[�U�����W�A��/�b�Ŏw�肵�����g���x�N�g�� W ��
% ���p���āA���̓_�� Nyquist ���}���v�Z����܂��B�ΐ��X�P�[���̎��g��
% �x�N�g�����쐬����ɂ́ALOGSPACE �����Ă��������B 
%
% NYQUIST(SYS1,SYS2,...,W) �́A������LTI���f�� SYS1,SYS2,... ��1��
% �v���b�g�ɂ��܂��B���g���x�N�g�� W �́A�I�v�V�����ł��B���̂悤�ɁA
% �J���[�A���C���X�^�C���A�}�[�J��ݒ肷�邱�Ƃ��ł��܂��B
%
%   nyquist(sys1,'r',sys2,'y--',sys3,'gx').
%
% [RE,IM] = NYQUIST(SYS,W) �� [RE,IM,W] = NYQUIST(SYS) �́A���g��������
% ���� RE �Ƌ��� IM ���o�͂�(�v�Z���s������g���̃x�N�g�� W ��ݒ肵��
% ���Ȃ��ꍇ�A������܂߂�)�A��ʂɃv���b�g�͕`���܂���BSYS �� NY �o�� 
% �� NU ���͂����ꍇ�ARE ��IM �́A�T�C�Y [NY NU LENGTH(W)] �̔z���
% �Ȃ�܂��B�����ŁA���g�� W(k) �ł̉����� RE(:,:,k)+j*IM(:,:,k) �ł��B
%
% �Q�l : BODE, NICHOLS, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.


%   Authors: P. Gahinet 6-21-96
%   Revised: A. DiVergilio, 6-16-00
%   Copyright 1986-2002 The MathWorks, Inc. 
