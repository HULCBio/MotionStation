% ZPKDATA   ��-��-�Q�C���f�[�^�ւ̃N�C�b�N�A�N�Z�X
%
%
% [Z,P,K] = ZPKDATA(SYS) �́ALTI���f�� SYS �̊e I/O �`�����l�����ɗ�_�A�ɁA
% �Q�C�����o�͂��܂��B�Z���z�� Z, P �ƍs�� K �͏o�͂Ɠ����̍s�Ɠ��͂Ɠ�����
% ��������A���� (I,J) �v�f�́A���� J ����o�� I �܂ł̓`�B�֐��̗�_�A�ɁA�Q�C��
% ��\���܂��BSYS �́A�K�v�ȏꍇ�A�܂����߂ɋ�-��_-�Q�C���^�ɕϊ����܂�
%
% [Z,P,K,TS] = ZPKDATA(SYS) �́A�T���v������ TS ���o�͂��܂��B
% SYS �̂��̑��̃v���p�e�B�́AGET ��p���ĎQ�Ƃ��邩���ړI�ɍ\���̃��C�N�ɎQ
% �Ƃł��܂�(���Ƃ��΁ASYS.Ts)�B
%
% �P��� SISO ���f�� SYS �ɑ΂��āA���� [Z,P,K] = ZPKDATA(SYS,'v') �́A��_
% Z �Ƌ� P ���Z���z��ł͂Ȃ���x�N�g���Ƃ��ďo�͂��܂��B
%
% LTI���f���̔z�� SYS �ɑ΂��āAZ, P, K �� SYS �Ɠ����T�C�Y�̔z��ɂȂ�Am
% �Ԗڂ̃��f�� SYS(:,:,m) �� ZPK �\���́AZ(:,:,m), P(:,:,m), K(:,:,m)�ł��B
%
% �Q�l : ZPK, GET, TFDATA, SSDATA, LTIMODELS, LTIPROPS.


% Copyright 1986-2002 The MathWorks, Inc.
