%MODRED �́A���f����᎟�������܂��B
%   Control Systems Toolbox ���K�v�ł��B
%
%   RMOD = MODRED(MOD,ELIM)
%   RMOD = MODRED(MOD,ELIM,'mdc')
%
%   �x�N�g�� ELIM �Ŏw�肳�ꂽ��Ԃ��폜���邱�Ƃɂ��A��ԋ�ԃ��f��
%   (IDSS, IDGREY �I�u�W�F�N�g) MOD �̏�Ԑ������炵�܂��B��ԃx�N�g���́A
%   ��Ԃ��c�� X1 �ƁA��Ԃ��폜���� X2 �ŕ�������܂��B
%
%       A = |A11  A12|      B = |B1|    C = |C1 C2|
%           |A21  A22|          |B2|
%       .
%       x = Ax + Bu,   y = Cx + Du  (�܂��́A�Ή����闣�U���Ԍn)
%
%   X2 �̔��W���̓[���ɐݒ肳��A���ʂ̕������� X1 �Ɋւ��鎮�ł��B���ʂ�
%   �V�X�e���́ALENGTH(ELIM) �������Ȃ���Ԑ��������AELIM ��Ԃ̉�����
%   �����ɍ����ɐݒ肷�邱�Ƃɑ������܂��B�I���W�i�����f���ƒ᎟�������f��
%   �́ADC �Q�C������v���܂��B�܂�A����ԉ�������v���܂��B
%
%   RMOD = MODRED(MOD,ELIM,'del') �́A��� X2 ��P���ɍ폜���܂��B�T�^�I�ɁA
%   ���g���̈�ŗǂ��ߎ������������܂����ADC �Q�C���̈�v�͕⏞����܂�
%   ��B
%
%   MOD �� BALREAL �ŕ��t������A�O���~�A���� M �̏����ȑΊp�v�f������
%   �ꍇ�AMODRED �𗘗p���čŌ�� M �̏�Ԃ��폜���邱�ƂŁA���f����᎟
%   �������邱�Ƃ��ł��܂��B
%
%   �Q�l:  BALREAL, IDSS



%   Copyright 1986-2001 The MathWorks, Inc.
