% JAVACHK   Java�T�|�[�g���x���̊m�F
%
% MSG = JAVACHK(LEVEL) �́AJava�T�|�[�g�̕K�v�ȃ��x�����g�p�\���ۂ���
% ���āA��{�I�ȃG���[���b�Z�[�W��߂��܂��B���̃��x���𖞂����ꍇ�́A
% ��s����o�͂��܂��B���̃T�|�[�g���x�������݂��܂��B
%
%   LEVEL      �Ӗ�
%   -----------------------------------------------------
%   'jvm'      Java Virtual Machine���N����
%   'awt'      AWT �v�f���g�p�\
%   'swing'    Swing �v�f���g�p�\
%   'desktop'  MATLAB�C���^���N�e�B�u�f�X�N�g�b�v���N����
%
% MSG = JAVACHK(LEVEL, COMPONENT) �́A�K�v��Java�T�|�[�g���x����
% �g�p�s�̏ꍇ�́A�^����ꂽ COMPONENT �ɃG���[���b�Z�[�W���o�͂�
% �܂��B �g�p�\�ȏꍇ�́A��s�񂪏o�͂���܂��B���̗����Q�Ƃ���
% ���������B
%
% ���F
% Java Frame��\������m-�t�@�C������������AFrame���\���ł��Ȃ��ꍇ
% �́A���̂悤�ɂ��Ă��������B:
%   
%   error(javachk('awt','myFile'));
%   myFrame = java.awt.Frame;
%   myFrame.setVisible(1);
%
% Frame���\���ł��Ȃ��ꍇ�́A�ǂݍ��݃G���[���o�͂���܂��B:
%   ??? myFile is not supported on this platform.
%
% �Q�l�FUSEJAVA

%   Copyright 1984-2002 The MathWorks, Inc.
