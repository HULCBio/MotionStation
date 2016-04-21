%  HELP Command Window �Ƀw���v�e�L�X�g��\��
% 
% HELP���g�ł́A���ׂĂ̎�v�ȃw���v�g�s�b�N��\�����܂��B��v�Ȋe�g�s�b
% �N�́AMATLABPATH ��̃f�B���N�g�����ɑ������܂��B
%     
% HELP / �́A���ׂẲ��Z�q�Ɠ���L�����N�^�̊T�v�ꗗ��\�����܂��B
%     
% HELP FUN �́A�֐� FUN �̃V���^�b�N�X�̐�����\�����܂��B
% FUN �� MATLAB �p�X�̕����f�B���N�g���ɂ���ꍇ�AHELP �́A�p�X��Ɍ�����A
% �ŏ��� FUN �̏���\�����A����(�I�[�o�[���[�h���ꂽ) FUN �ɂ��ẮA
% PATHNAME/FUN �܂��� CLASSNAME/METHODNAME ��\�����܂��B 
%     
% HELP PATHNAME/FUN �́APATHNAME/FUN �̃w���v��\�����܂��B�I�[�o�[���[�h
% ���ꂽ�֐��ɑ΂��āA�w���v��\�����邽�߂ɂ́A���̃V���^�b�N�X���g�p����
% ���������B
%
% HELP DIR �́AMATLAB �f�B���N�g�� DIR �ɁA�e�֐��̊ȒP�ȊT�v��\�����܂��B
% DIR �́A���Ε����p�X���ɂ��邱�Ƃ��ł��܂�( HELP PARTIALPATH ���Q�� )�B
% DIR ���R�[������֐��ł́A�f�B���N�g���̂��ׂĂ̊֐��ꗗ��\������
% ���߂� HELP DIR/ ���g�p���Ă��������B
%     
% HELP CLASSNAME.METHODNAME �́A���S�ɏ����̍����N���X CLASSNAME �̃��\�b�h
% METHODNAME �̃w���v��\�����܂��BMETHODNAME �ɑ΂��� CLASSNAME �����肷��
% ���߂ɂ́ACLASS(OBJ) ���g�p���Ă��������B�����ŁAMETHODNAME �́A�I�u�W�F�N�g
% OBJ�@�Ɠ����N���X�ł��B
%
% HELP CLASSNAME �́A���S�ɏ����̍����N���X CLASSNAME �̃w���v��\�����܂��B
%
% T = HELP('TOPIC') �́ATOPIC �̃w���v�e�L�X�g���A�e�s�� /n �ŋ�؂�ꂽ
% ������Ƃ��ďo�͂��܂��BTOPIC �́AHELP �Ŏg�p�ł�������ł��B
%     
% ����:
% 1. �w���v�e�L�X�g���X�N���[����ŃX�N���[������ꍇ�́AMORE ON�Ɠ��͂���
% �ƁA�X�N���[������HELP���~���܂��B
% 2. �w���v�V���^�b�N�X�ł́A�֐����́A�������邽�߂ɑ啶���ŕ\�킳���
% ���܂��B���ۂɂ́A�֐�������ɏ������œ��͂��Ă��������B�啶���Ə�����
% �ŕ\������� Java �֐� (���Ƃ��΁A javaObject)�́A�\���̂悤�ɑ啶����
% �������̗�����p���ē��͂��Ă��������B
% 3. �w���v�u���E�U�̊֐��̃w���v��\�����邽�߂ɂ́ADOC FUN ���g�p����
% ���������B����́A�O���t�B�b�N�X����Ȃǂ́A�t���I�ȏ���񋟂��܂��B
% 4. ���[�U���g�� M-�t�@�C���̃w���v���쐬���邽�߂̏ڍׂ́ADOC HELP ��
% �g�p���Ă��������B
% 5. �w���v�u���E�U�̃I�����C���h�L�������g�ɃA�N�Z�X���邽�߂ɂ́AHELPBROWSER 
% ���g�p���Ă��������BTOPIC �܂��� ���̌�ɂ��ďڍׂ��������邽�߂ɂ́A
% �w���v�u���E�U�C���f�b�N�X�A�܂��́ASearch �^�u���g�p���Ă��������B
%
% ���:
%   help close - CLOSE �֐��̃w���v��\��
%   help database/close - Database Toolbox ��CLOSE �֐��̃w���v��\��
%   help database/ - Database Toolbox �̂��ׂĂ̊֐��̈ꗗ�\��
%   help database - DATABASE �֐��̃w���v��\��
%   help general - �f�B���N�g�� MATLAB/GENERAL �̂��ׂĂ̊֐��̈ꗗ�\��
%   help mkdir - MATLAB MKDIR �֐��̃w���v��\��
%   help internet.ftp - INTERNET.FTP �̃R���X�g���N�^�AINTERNET.FTP.FTP 
%                       �̕\��
%   help internet.ftp.mkdir �́AINTERNET.FTP �N���X�� MKDIR ���\�b�h��
%   �w���v��\�����܂��B
%   t = help('close') - CLOSE �֐��̃w���v���擾���At �ɕ�����Ƃ��ĕۑ�
%  
% �Q�l DOC, DOCSEARCH, HELPBROWSER, HELPWIN, LOOKFOR, MATLABPATH,
%      MORE, PARTIALPATH, WHICH, WHOS, CLASS.


%   Copyright 1984-2004 The MathWorks, Inc.
