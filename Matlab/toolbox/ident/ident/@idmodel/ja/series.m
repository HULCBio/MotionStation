%SERIES �́A2��IDMODEL�̒���ڑ������s���܂��B
%   Control Systems Toolbox ���K�v�ł��B
%
%                                  +------+
%                           v2 --->|      |
%                  +------+        | MOD2 |-----> y2
%                  |      |------->|      |
%         u1 ----->|      |y1   u2 +------+
%                  | MOD1 |
%                  |      |---> z1
%                  +------+
%
%   MOD = SERIES(MOD1,MOD2,OUTPUTS1,INPUTS2)
%
%   2�� IDMODELS MOD1 �� MOD2 �𒼗�ɐڑ����AOUTPUTS1 �Ŏw�肳�ꂽ MOD1
%   �̏o�͂��AINPUTS2 �Ŏw�肳�ꂽ MOD2 �̓��͂ɐڑ�����܂��B�x�N�g��
%   OUTPUTS1 �� INPUTS2 �́A���ꂼ�� MOD1 �� MOD2 �̏o�͂Ɠ��͂̃C���f�b
%   �N�X�ł��B���ʂ� IDMODEL MOD �́AIDSS �I�u�W�F�N�g�ŁAu1 �� y2 �Ƀ}�b
%   �v���܂��B
%
%   OUTPUTS1 �� INPUS2 ���ȗ������ƁAMOD1 �� MOD2 ���J�X�P�[�h�ɐڑ���
%   ��A���̃V�X�e�����o�͂��܂��B
%                     MOD = MOD2 * MOD1 .
%
%   ����: SERIES �́A�ϑ����̓`�����l���݂̂���舵���܂��B�m�C�Y���̓`��
%         ���l���������ɑ��ݐڑ����邽�߂ɂ́A���炩���� NOISECNV �𗘗p
%         ���đ���`�����l���ɕϊ����Ă����K�v������܂��B
%
%   �����U���́A�����܂��B
%
%   �Q�l:  APPEND, PARALLEL, FEEDBACK



%   Copyright 1986-2001 The MathWorks, Inc.
