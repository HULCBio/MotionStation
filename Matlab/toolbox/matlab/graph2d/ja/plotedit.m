% PLOTEDIT   �v���b�g�̕ҏW�ƒ��ߕt���̂��߂̃c�[��
% 
% PLOTEDIT ON �́A�J�����g��figure�ɑ΂��āA�v���b�g�G�f�B�b�g���[�h��
% �J�n���܂��B
% PLOTEDIT OFF �́A�J�����g��figure�ɑ΂��āA�v���b�g�G�f�B�b�g���[�h��
% �I�����܂��B
% PLOTEDIT �́A������ݒ肵�Ȃ��ƁA�J�����g��figure�ɑ΂��ăv���b�g
% �G�f�B�b�g���[�h��؂�ւ��܂��B
% 
% PLOTEDIT(FIG) �́Afigure FIG�ɑ΂��ăv���b�g�G�f�B�b�g���[�h��؂�
% �ւ��܂��B 
% PLOTEDIT(FIG,STATE) �́Afigure FIG�ɑ΂��� PLOTEDIT STATE ���w�肵
% �܂��B
% PLOTEDIT('STATE') �́A�J�����g��figure�ɑ΂��āAPLOTEDIT STATE ��
% �w�肵�܂��B
%
% STATE�́A���̕�����̒�����w�肵�܂��B
%    ON            - �v���b�g�G�f�B�b�g���[�h���J�n���܂��B
%    OFF           - �v���b�g�G�f�B�b�g���[�h���I�����܂��B
%    SHOWTOOLSMENU - �c�[�����j���[��\�����܂�(�f�t�H���g)�B
%    HIDETOOLSMENU - ���j���[�o�[����c�[�����j���[���������܂��B   
%
% PLOTEDIT �� ON �̂Ƃ��A�I�u�W�F�N�g���C��������ǉ�����ɂ́A�c�[��
% ���j���[���g���Ă��������B�܂��A�e�L�X�g�A���C���A���̂悤�Ȓ��߂�
% �ǉ�����ɂ́A���߂̃c�[���o�[�̃{�^����I�����Ă��������B������
% ���߂��ړ��܂��̓��T�C�Y����ɂ́A�I�u�W�F�N�g���N���b�N���Ă���
% �h���b�O���Ă��������B
% 
% �I�u�W�F�N�g�v���p�e�B��ύX����ɂ́A�I�u�W�F�N�g��ŉE�}�E�X�{�^��
% �N���b�N�܂��̓_�u���N���b�N���Ă��������B
% 
% �����̃I�u�W�F�N�g��I������ɂ́AShift�������ăN���b�N���s���Ă��������B
%
% �Q�l: PROPEDIT  

%   toolbox-plotedit �݊����ɑ΂�������C���^�t�F�[�X
%
%   plotedit(FIG,'hidetoolsmenu')
%      �́A�W���� figure 'Tools' ���j���[���\���ɂ��܂��B
%   plotedit(FIG,'showtoolsmenu')
%      �́A�W���� figure 'Tools' ���j���[��\�����܂��B
%   h = plotedit(FIG,'gethandles')
%      �́A��\���� plot editor �I�u�W�F�N�g�̃��X�g��Ԃ��܂��B����́A
%      GUIDE �̃I�u�W�F�N�g�u���E�U���珜�����K�v������܂��B
%   h = plotedit(FIG,'gettoolbuttons')
%      �́A�c�[���o�[�ɁAplot editing �ƒ��߂̃{�^���̃��X�g��
%      �Ԃ��܂��B UISUSPEND �� UIRESTORE �ɂ��g�p����܂��B
%   h = plotedit(FIG,'locktoolbarvisibility')
%      �́A�c�[���o�[�̃J�����g�̏�Ԃ��t���[�Y���܂��B
%   plotedit(FIG,'setsystemeditmenus')
%      �́Asystem Edit ���j���[���ĕۑ����܂��B
%   plotedit(FIG,'setploteditmenus')
%      �́Aplotedit Edit ���j���[���ĕۑ����܂��B
%
%   �����́AUISUSPEND/UIRESTORE �ɂ��g�p����܂��B
%   a = plotedit(FIG,'getenabletools')
%      �́Aplot editing �c�[���̗��p�\�ȏ�Ԃ�Ԃ��܂��B
%   plotedit(FIG,'setenabletools','off')
%      Tools ���j���[���� plot editing �c�[���A�c�[�����j���[�̏�Ԃ�
%      �X�V����R�[���o�b�N�A����сAToolbar �� plot editing �c�[����
%      ���p�ł��Ȃ���Ԃɂ��܂��B
%   plotedit(FIG,'setenabletools','on')
%      �́ATools ���j���[�Ƃ��̉��̃A�C�e���𗘗p�\�ɂ��A
%      Toolbar �� plot editing �{�^���𗘗p�\�ɂ��܂��B
%
%   figure �c�[���o�[���\���ɂ��邽�߂ɂ́Afigure 'ToolBar'
%   �v���p�e�B (hidden) �� 'none' �ɐݒ肵�܂��B
%      set(fig,'ToolBar','none');
%   
%   plotedit({'subfcn',...}) �́A�T�u�֐������s���A���͂̑����Ƃ���
%   �n���܂��B

%   Copyright 1984-2002 The MathWorks, Inc.