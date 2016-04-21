% USEJAVA  �w�肵��Java�̋@�\��MATLAB�ŃT�|�[�g����Ă��邩�𔻕�
%
% USEJAVA(LEVEL) �́A�@�\���T�|�[�g����Ă���ꍇ�� 1 �ŁA���̏ꍇ��
% 0 �ł��B
%
% �T�|�[�g�ɂ́A���̃��x��������܂��B
%
%   ���x��     �Ӗ�
%   -----------------------------------------------------
%   'jvm'      Java Virtual Machine�����s��
%   'awt'      AWT�R���|�[�l���g�����p�\
%   'swing'    Swing�R���|�[�l���g�����p�\
%   'desktop'  MATLAB�C���^���N�e�B�u�f�X�N�g�b�v�����s��
%
% "AWT �R���|�[�l���g"�́AAbstract Window Toolkit�̒���Java��GUI�R��
% �|�[�l���g�ƍl���܂��B"Swing �R���|�[�l���g"�́AJava Foundation 
% Classes�̒���Java��lightweight GUI�R���|�[�l���g�ƍl���܂��B
%
% ���F
%
% Java Frame��\������M-�t�@�C�����L�q������A�f�B�X�v���C���ݒ�ł���
% �����A���邢��JVM�����p�ł��Ȃ��ꍇ�ɋ��͂ɂ������ꍇ�A���̂悤
% �ɂ��Ă��������B
%   
%   if usejava('awt')
%      myFrame = java.awt.Frame;
%   else
%      disp('Unable to open a Java Frame.');
%   end
%
% JVM�ɃA�N�Z�X�ł��Ȃ�MATLAB�Z�b�V�����̒��Ŏ��s���Ă���ꍇ�AJava
% �R�[�h���g����M-�t�@�C�����������݁A��������܂����s�������ꍇ�́A��
% �̃`�F�b�N��t���邱�Ƃ��ł��܂��B
%
%   if ~usejava('jvm')
%      error([mfilename ' requires Java to run.']);
%   end
%
% �Q�l�FJAVACHK


%   Copyright 1984-2002 The MathWorks, Inc.
