% NICHOLS   LTI ���f���� Nichols ���g���������v�Z
%
%
% NICHOLS(SYS) �́ALTI ���f�� SYS(TF, ZPK, SS �܂��� FRD �����ꂩ�ō쐬
% ���ꂽ)��Nichols ���}��`���܂��B���g���ш�Ɠ_���͎����I�ɑI������܂��B
% ���U���Ԃ̎��g���ɂ��Ă̒��ӎ����̏ڍׂ́ABODE �����Ă��������B
%
% NICHOLS(SYS,{WMIN,WMAX}) �́AWMIN ���� WMAX �܂ł̎��g���ш�(���W�A��/�b��)
% �ɑ΂��� Nichols ���}��`���܂��B
%
% NICHOLS(SYS,W) �́A���[�U�����W�A��/�b�Ŏw�肵�����g���x�N�g�� W �𗘗p���āA
% ���̓_�� Nichols ���}���v�Z����܂��B�ΐ��X�P�[���ł̎��g���x�N�g�����쐬
% ���邽�߂ɂ́ALOGSPACE ���Q�Ƃ��Ă��������B
%
% NICHOLS(SYS1,SYS2,...,W) �́A������ LTI ���f�� SYS1,SYS2,... �� Nichols
% ���}��1�̃v���b�g�ɂ��܂��B���g���x�N�g�� W �́A�I�v�V�����ł��B
% ���̂悤�ɃJ���[�A���C���X�^�C���A�}�[�J���e�V�X�e�����Ɏw�肷�邱�Ƃ�
% �ł��܂��B 
%   nichols(sys1,'r',sys2,'y--',sys3,'gx')
%
% [MAG,PHASE] = BODE(SYS,W) �� [MAG,PHASE,W] = BODE(SYS) �́A�Q�C���Ɠx�P��
% �ł̈ʑ��̉���(�v�Z�����s������g���̃x�N�g�� W ��ݒ肵�Ă��Ȃ��ꍇ�A����
% ���܂߂�)���o�͂��܂��B��ʂɂ̓v���b�g�͕\������܂���BSYS ��NY �o�͂�
% NU ���͂����ꍇ�AMAG �� PHASE �̓T�C�Y [NY NU LENGTH(W)]�̔z��ŁA�����ŁA
% MAG(:,:,k) �� PHASE(:,:,k) �́A���g�� W(k) �ł̉��������߂܂��B
%
% �Q�l : BODE, NYQUIST, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
