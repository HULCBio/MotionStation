% IDSS/BODE �́AIDSS ���f���� Bode ���g���������v�Z���܂��B
%
% BODE(SYS) �́ALTI ���f�� SYS(TF, ZPK, SS, FRD �̂����ꂩ)�� Bode ���}��
% �`���܂��B���g�������W�Ɠ_���́A�����I�ɑI������܂��B
%
% BODE(SYS,{WMIN,WMAX}) �́AWMIN �� WMAX �̊Ԃ̎��g��(rad/sec �P��)�ɑ΂�
% �āABode ���}��`���܂��B
%
% BODE(SYS,W) �́ABode �������v�Z�������g���_��v�f�Ƃ���x�N�g�� W ��
% �ݒ肵�܂��B�ΐ��I�ɓ��Ԋu�̎��g���x�N�g�����쐬����ɂ́ALOGSPACE ���Q
% �Ƃ��Ă��������B
%
% BODE(SYS,SD) �́A�v�Z���� BODE ���}�ɁA�W���΍��� SD �{�Ŏ������M����
% �Ԃ�\�����܂��B�����ŁASD �͐��̃X�J���ł��B
%
% BODE(SYS1,SYS2,...,W,SD) �́A�P��v���b�g��ɕ����� LTI ���f�� SYS1,
% SYS2,...�� Bode �������v���b�g���܂��B���g���x�N�g�� W �́A�I�v�V������
% ���B�܂��A���̂悤�ɂ��āA�e�V�X�e���ɃJ���[�A���C���X�^�C���A�}�[�J
% ��ݒ肷�邱�Ƃ��ł��܂��B
% 
%      bode(sys1,'r',sys2,'y--',sys3,'gx').
%
% [MAG,PHASE] = BODE(SYS,W) �� [MAG,PHASE,W] = BODE(SYS) �́A�Q�C��������
% �x�P�ʂ̈ʑ��������o�͂��܂��B�����ŁA�X�N���[����Ƀv���b�g�\���͂���
% �܂���BSYS �� NY �o�́ANU ���͂̏ꍇ�AMAG �� PHASE �́A�T�C�Y [NY NU 
% LENGTH(W)] �̔z��ɂȂ�܂��BMAG(:,:,k) �� PHASE(:,:,k) �́A���g�� W(k)
% �ł̉��������肵�܂��B�f�V�x���P�ʂŃQ�C�������肷��ɂ́AMAGDB = 20*
% log10(MAG) �Ɠ��͂��܂��B
%
% �T���v������ Ts �������U���ԃ��f���ɑ΂��āABODE �́A�P�ʉ~�������g��
% ���ɓ��e���邽�߂ɁA�ϊ� Z = exp(j*W*Ts) ���g���܂��B���g�������́ANy-
% quist ���g�� pi/Ts ���Ⴂ���̂ɂ��Ă̂݃v���b�g���܂��B�����āATs 
% ���ݒ肳��Ă��Ȃ��ꍇ�ɁA�f�t�H���g�l1(�b)���g���܂��B
%
% �Q�l�F NICHOLS, NYQUIST, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.

% $Revision: 1.2 $ $Date: 2001/03/01 22:54:42 $
%   Copyright 1986-2001 The MathWorks, Inc.
