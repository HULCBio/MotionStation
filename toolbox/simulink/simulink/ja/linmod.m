% LINMOD   �A�������������(ODE)������`���f�����擾
% diff.
% equations (ODEs).
%
%  [A,B,C,D] = LINMOD('SYS') �́A��ԕϐ��Ɠ��͂��f�t�H���g�ɐݒ肳�ꂽ�Ƃ��A
% �u���b�N���}'SYS'�ɋL�q���ꂽ�A��������������̏�ԋ�Ԑ��`���f�����擾��
%
%  [A,B,C,D] = LINMOD('SYS',X,U) �́A��ԃx�N�g��X�Ɠ���U���w�肷�邱�Ƃ���
% ���܂��B���`���f���́A���̕��t�_�Ŏ擾����܂��B
%
%  [A,B,C,D] = LINMOD('SYS',X,U,PARA) �́A�p�����[�^�̃x�N�g����ݒ肷�邱��
% ���ł��܂��BPARA(1) �́A���`���f�����擾���邽�߂̐ۓ����x����ݒ肵�܂�
% ('v5'�I�v�V�����𗘗p���Ȃ�����R12 �ł͔p�~�����֐��ł��B���L�Q��)�B����
% �֐��ł���V�X�e���ɑ΂��āAPARA(2) �͐��`���f���������鎞��t�̒l���g��
% �Đݒ肳��܂�(�f�t�H���gt=0)�BPARA(3)=1 �Ɛݒ肷��ƁA���͂���o�͂ւ̃p�X
% �������Ȃ��u���b�N�Ɋ֘A����]���ȏ�Ԃ��폜���܂��B
%
%  [A,B,C,D]=DLINMOD('SYS',TS,X,U,'v5') �́AMATLAB 5.x �ŗp�ӂ���Ă���ۓ�
% ���x�[�X�ɂ����A���S���Y�����g�p���܂��B�J�����g�A���S���Y���́A�啔���̃u���b
% �N�ɑ΂��āA���m�Ȑ��`�����s���܂����A��萸�x�̍������̂��v������܂��B�V��
% ���A���S���Y���́ATransport Delay �� Quantizer�u���b�N�̂悤�ȁA������
% �܂ރu���b�N�ɑ΂��āA���ʂȎ�舵�����ł��܂��B���ڍׂȏ����舵����
% ���ẮA�����̃u���b�N�̃}�X�N�_�C�A���O���Q�Ƃ��Ă��������B
%
%  [A,B,C,D]=LINMOD('SYS',X,U,'v5',PARA,XPERT,UPERT)�́AMATLAB 5.x�̐ۓ����f
% ���A���S���Y�����g�p���܂��B XPERT��UPER���^�����Ȃ��ꍇ�́APARA(1)�́A��
% �����x�����ȉ��̂悤�ɐݒ肵�܂�: XPERT= PARA(1)3*PARA(1)*ABS(X)
% UPERT= PARA(1)3*PARA(1)*ABS(U) �f�t�H���g�̐ۓ����x���́APARA(1)=1e-5�ł��B
%  �x�N�g��XPERT��UPERT���^������ꍇ�́A�V�X�e���̏�ԂƓ��͂ɑ΂���ۓ�
%
% �Q�l : LINMODV5, LINMOD2, DLINMOD, TRIM


% Copyright 1990-2002 The MathWorks, Inc.
