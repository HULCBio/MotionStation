%FEEDBACK �́A2�� IDMODEL ���f�����t�B�[�h�o�b�N�ڑ����܂��B
%   Control Systems Toolbox ���K�v�ł��B
%
%   MOD = FEEDBACK(MOD1,MOD2) �́A���[�v�t�B�[�h�o�b�N�V�X�e���ɑ΂��āA
%   IDSS MOD ���v�Z���܂��B
%
%          u --->O---->[ MOD1 ]----+---> y
%                |                 |           y = MOD * u
%                +-----[ MOD2 ]<---+
%
%   ���̃t�B�[�h�o�b�N�����肳��A���ʂ̃V�X�e�� MOD �́Au �� y �Ƀ}�b�v
%   ���܂��B���̃t�B�[�h�o�b�N��K�p���邽�߂ɂ́A���̏����𗘗p���܂��B
%       MOD = FEEDBACK(MOD1,MOD2,+1).
%
%   MOD = FEEDBACK(MOD1,MOD2,FEEDIN,FEEDOUT,SIGN) �́A�X�ɔėp�I�ȃt�B�[
%   �h�o�b�N���ݐڑ����\�����܂��B
%
%                      +--------+
%          v --------->|        |--------> z
%                      |  MOD1  |
%          u --->O---->|        |----+---> y
%                |     +--------+    |
%                |                   |
%                +-----[  MOD2  ]<---+
%
%   �x�N�g�� FEEDIN �́AMOD1 �̓��̓x�N�g���̃C���f�b�N�X�ŁA���� u ��
%   �t�B�[�h�o�b�N���[�v�Ɋ܂܂�邱�Ƃ��w�肵�܂��B���l�ɁAFEEDOUT �́A
%   MOD1 �̏o�� y ���t�B�[�h�o�b�N�̂��߂ɗ��p����邱�Ƃ��w�肵�܂��B
%   SIGN = 1 �̏ꍇ�A���̃t�B�[�h�o�b�N���K�p����܂��BSIGN = -1 �̏ꍇ�A
%   �܂��́ASIGN ���ȗ����ꂽ�ꍇ�ɂ́A���̃t�B�[�h�o�b�N���K�p����܂��B
%   ���ׂĂ̏ꍇ�ɂ����āA���ʂ� LTI ���f�� MOD �́AMOD1 �Ɠ������͂Əo��
%   �������܂��B(�����͈ێ�����܂��B)
%
%   ����: FEEDBACK�́A�ϑ����̓`�����l���̂ݎ�舵���܂��B�m�C�Y���̓`����
%         �l���𑊌ݐڑ����邽�߂ɂ́A���炩���� NOISECNV �𗘗p���đ���
%         �`�����l���ɕϊ����Ă����K�v������܂��B
%
%   �����U���͎����܂��B
%
%   �Q�l:  APPEND, PARALLEL, SERIES



%   Copyright 1986-2001 The MathWorks, Inc.
