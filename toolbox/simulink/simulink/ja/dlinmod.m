% DLINMOD   �A��ODE����ї��U�V�X�e��������`���f�����擾
%
% [A,B,C,D] = DLINMOD('SYS',TS) �́A��ԕϐ��Ɠ��͂��f�t�H���g�ɐݒ肳�ꂽ��
% ���ɁA�u���b�N���} 'SYS' �ɋL�q����Ă���A��/���U�����V�X�e����(�T���v��
% ����TS��)���U��ԋ�Ԑ��`���f�����擾���܂��B
%
% [A,B,C,D] = DLINMOD('SYS',TS,X,U) �́A��ԃx�N�g�� X �Ɠ��� U ���w�肷�邱
% �Ƃ��ł��܂��B���`���f���́A���̕��t�_�Ŏ擾����܂��B
%
% [A,B,C,D] = LINMOD('SYS',X,U,PARA) �́A�p�����[�^�̃x�N�g����ݒ肷�邱�Ƃ�
% �ł��܂��BPARA(1) �́A���`���f�����擾���邽�߂̐ۓ����x����ݒ肵�܂�('
% v5'�I�v�V�����𗘗p���Ȃ�����R12 �ł͔p�~�����֐��ł��B���L�Q��)�B���Ԋ�
% ���ł���V�X�e���ɑ΂��āAPARA(2) �͐��`���f���������鎞��t�̒l���g����
% �ݒ肳��܂�(�f�t�H���gt=0)�BPARA(3)=1 �Ɛݒ肷��ƁA���͂���o�͂ւ̃p�X��
% �����Ȃ��u���b�N�Ɋ֘A����]���ȏ�Ԃ��폜���܂��B
%
% [A,B,C,D]=DLINMOD('SYS',TS,X,U,'v5') �́AMATLAB 5.x �ŗp�ӂ���Ă���ۓ���
% �x�[�X�ɂ����A���S���Y�����g�p���܂��B�J�����g�A���S���Y���́A�啔���̃u���b
% �N�ɑ΂��āA���m�Ȑ��`�����s���܂����A��萸�x�̍������̂��v������܂��B�V��
% ���A���S���Y���́ATransport Delay �� Quantizer�u���b�N�̂悤�ȁA������
% �܂ރu���b�N�ɑ΂��āA���ʂȎ�舵�����ł��܂��B���ڍׂȏ����舵����
% ���ẮA�����̃u���b�N�̃}�X�N�_�C�A���O���Q�Ƃ��Ă��������B
%
% [A,B,C,D]=DLINMOD('SYS',TS,X,U,'v5','PARA,XPERT,UPERT) �́AMATLAB 5.x �ŗp
% �ӂ���Ă���ۓ����x�[�X�ɂ����A���S���Y�����g�p���܂��BXPERT?AUPER?a-^?|
% ?c?e?E?��?e?��?I?APARA(1)?I?A?U"(r)???x???d?E��o?I?a???E?Y'e?��?U?�E:
%  XPERT= PARA(1)3*PARA(1)*ABS(X) UPERT= PARA(1)3*PARA(1)*ABS(U) ?f?t?H??
% ?g?I?U"(r)???x???I?APARA(1)=1e-5?A?�E?B�x�N�g��XPERT?AUPERT?a-^?|?c?e?e?
% e?��?I?A?V?X?e???I?o'O?A"u-I?E'I?�E?e?U"(r)???x???A?��?A-p?��?c?e?U?�E?B
%
% �Q�l : DLINMODV5, LINMOD, LINMOD2, TRIM


% Copyright 1990-2002 The MathWorks, Inc.
