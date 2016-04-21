%PARALLEL �́A2�� LTI ���f���̕���ڑ������s���܂��B
%   Control Systems Toolbox ���K�v�ł��B
%
%                          +------+
%            w1 ---------->|      |----------> z1
%                          | MOD1 |
%                   u1 +-->|      |---+ y1
%                      |   +------+   |
%             u ------>+              O------> y
%                      |   +------+   |
%                   u2 +-->|      |---+ y2
%                          | MOD2 |
%            w2 ---------->|      |----------> z2
%                          +------+
%
%   MOD = PARALLEL(MOD1,MOD2,IN1,IN2,OUT1,OUT2)
%
%   2�� IDmodels MOD1 �� MOD2 ������ɐڑ�����AIN1 �� IN2 �Ŏw�肳�ꂽ
%   ���͂��ڑ�����AOUT1 �� OUT2 �Ŏw�肳�ꂽ�o�͂����Z����܂��B���ʂ�
%   LTI ���f�� MOD �́A[v1:u:v2] �� [z1:y:z2] �Ƀ}�b�v���܂��B�x�N�g��
%   IN1 �� IN2 �́A���ꂼ�� MOD1 �� MOD2 �̓��̓x�N�g���̃C���f�b�N�X��
%   �܂݁A�_�C�A�O�����ɂ�������̓`�����l�� u1 �� u2 ���w�肵�܂��B���l
%   �ɁA�x�N�g�� OUT1 �� OUT2 ��2�̃V�X�e���̏o�͂̃C���f�b�N�X�ł��B
%
%   ���ʂ̃��f���́A��� IDSS �I�u�W�F�N�g�ɂȂ�܂��B
%
%   IN1, IN2, OUT1, OUT2 �����ׂďȗ������ƁAMOD1 �� MOD2 �̕W���̕���
%   �ڑ������s����A���̌��ʂ��o�͂���܂��B
%          MOD = MOD2 + MOD1
%
%   ����: PARALLEL �́A�ϑ����̓`�����l���݂̂���舵���܂��B�m�C�Y����
%         �`�����l�����܂ޓ����ڑ������s���邽�߂ɂ́A���炩���� NOISECNV
%         �𗘗p���đ���`�����l���ɕϊ�����K�v������܂��B
%
%   �����U���́A�����܂��B
%   
%   �Q�l:  APPEND, SERIES, FEEDBACK, LTIMODELS



%   Copyright 1986-2001 The MathWorks, Inc.
