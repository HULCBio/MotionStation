% NYQUIST   LTI ���f����Nyquist ���g���������v�Z
%
%
% NYQUIST(SYS) �́ALTI ���f��(TF, ZPK, SS �܂��� FRD �̂����ꂩ�ō쐬���ꂽ)
% SYS �� Nyquist ���}���v���b�g���܂��B���g���ш�Ɠ_���͎����I�ɑI�������
% ���B���U���Ԃ̎��g���ɂ��Ă̒��ӎ����̏ڍׂ́ABODE �����Ă��������B
%
% NYQUIST(SYS,{WMIN,WMAX}) �́AWMIN ���� WMAX �܂ł̎��g����(���W�A��/�b��)
% �ɑ΂��āANyquist ���}���v���b�g���܂��B
%
% NYQUIST(SYS,W) �́A���[�U�����W�A��/�b�Ŏw�肵�����g���x�N�g�� W �𗘗p���āA
% ���̓_�� Nyquist ���}���v�Z����܂��B�ΐ��X�P�[���ł̎��g���x�N�g�����쐬��
% �邽�߂ɂ́ALOGSPACE ���Q�Ƃ��Ă��������B
%
% NYQUIST(SYS1,SYS2,...,W) �́A������ LTI ���f�� SYS1,SYS2,... ��1��
% �v���b�g�ɂ��܂��B���g���x�N�g�� W �́A�I�v�V�����ł��B
% ���̂悤�ɁA�J���[�A���C���X�^�C���A�}�[�J��ݒ肷�邱�Ƃ��ł��܂��B
%   nyquist(sys1,'r',sys2,'y--',sys3,'gx').
%
% [RE,IM] = NYQUIST(SYS,W) �� [RE,IM,W] = NYQUIST(SYS) �́A���g�������̎���
% RE �Ƌ��� IM ���o�͂�(�v�Z���s������g���̃x�N�g�� W ��ݒ肵�Ă��Ȃ��ꍇ�A
% ������܂߂܂�)�B��ʂɂ̓v���b�g�͕\������܂���BSYS �� NY �o�͂�NU ����
% �����ꍇ�ARE ��IM �́A�T�C�Y [NY NU LENGTH(W)] �̔z��ɂȂ�܂��B �����ŁA
% ���g�� W(k) �ł̉����� RE(:,:,k)+j*IM(:,:,k) �ł��B
%
% �Q�l : BODE, NICHOLS, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
