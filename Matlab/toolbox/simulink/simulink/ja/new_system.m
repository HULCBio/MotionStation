% NEW_SYSTEM   �V�K�̋��Simulink�V�X�e�����쐬
%
% NEW_SYSTEM('SYS') �́A�w�肵�����O�ŐV�K�̋�̃V�X�e�����쐬���܂��B
%
% �I�v�V�����̑��������g���āA�V�X�e���^�C�v���w�肵�܂��B
% NEW_SYSTEM('SYS','Library') �́A�V�K�̋�̃��C�u�������쐬���܂��B
% NEW_SYSTEM('SYS','Model') �́A�V�K�̋�̃V�X�e�����쐬���܂��B
%
% �I�v�V�����̑�O�������g���āA���̓��e���V�K���f���ɃR�s�[�����T�u�V�X�e
% �����w�肵�܂��B���̑�O�����́A��������'Model'�ł���Ƃ��ɂ̂ݗ��p�\��
% ���BNEW_SYSTEM('SYS','MODEL','FULL_PATH_TO_SUBSYSTEM')�́A�T�u�V�X�e������
% �u���b�N�����V�K���f�����쐬���܂��B
%
% NEW_SYSTEM �́A�V�X�e���E�B���h�E�܂��̓��C�u�����E�B���h�E���J���܂���B
%
% ���:
%
% new_system('mysys')
%
% �́A'mysys'�Ƃ������O�̐V�K�̃V�X�e�����쐬���܂����A�J���܂���B
%
% new_system('mysys','Library')
%
% �́A'mysys'�Ƃ������O�̐V�K�̃��C�u�������쐬���܂����A�J���܂���B
%
% load_system('f14')
% new_system('mysys','Model','f14/Controller')
%
% �́A'mysys'�Ƃ������O�̐V�K�̃��C�u�������쐬���܂����A�J���܂���B
% ����́A'f14'�f�����f����'Controller'�Ƃ������O�̃T�u�V�X�e���ɓ����u���b
% �N�������܂��B
%
% �Q�l : OPEN_SYSTEM, CLOSE_SYSTEM, SAVE_SYSTEM.


% Copyright 1990-2002 The MathWorks, Inc.
