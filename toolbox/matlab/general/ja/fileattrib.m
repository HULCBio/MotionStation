% FILEATTRIB   �t�@�C���ƃf�B���N�g���̑����̎擾�܂��͐ݒ�
%
% [SUCCESS,MESSAGE,MESSAGEID] = FILEATTRIB(FILE,MODE,USERS,MODIFIER) 
% �́ADOS �ɑ΂��� ATTRIB�AUNIX �� LINUX �ɑ΂��� CHMOD �Ɠ��l�� FILE 
% �̑�����ݒ肵�܂��B�󔒂ɂ���Ē�`�����l�X�ȑ����́A��x�Ɏw��
% ���邱�Ƃ��ł��܂��BFILE �́A�t�@�C���A�܂��̓f�B���N�g�����w���A
% ��΃p�X���A�܂��̓J�����g�f�B���N�g���̑��΃p�X�����܂݂܂��B
%
% [SUCCESS,MESSAGE,MESSAGEID] = FILEATTRIB �́AMESSAGE �̃t�B�[���h
% ��`�ɏ]���āA�J�����g�f�B���N�g�����g�̑����Ɋւ���t�B�[���h��
% �擾���܂��B�p�����[�^�̏o�͂ƁA���� 1 ���Q�Ƃ��Ă��������B
%
% ���̓p�����[�^:
%     FILE: �t�@�C���܂��̓f�B���N�g���Ƃ��Ē�`����� 1�~n �̕�����
%           �ł��B���� 2 ���Q�Ƃ��Ă��������B
%     MODE: �t�@�C���܂��̓f�B���N�g���̃��[�h�Ƃ��Ē�`�����X�y�[�X
%           �ŋ�؂�ꂽ������ł��B���� 3 ���Q�Ƃ��Ă��������B
%           'a' : �A�[�J�C�u (Windows/DOS �̂�)
%           'h' : �B���t�@�C�� (Windows/DOS �̂�)
%           's' : �V�X�e���t�@�C�� (Windows/DOS �̂�)
%           'w' : �������݉�
%           'x' : ���s�� (UNIX �̂�)
%           '+' �܂��� '-' �̂����ꂩ���A�����̏����A�܂��͐ݒ�̂��߂�
%           �e�t�@�C���̃��[�h�̑O�ɉ����Ȃ���΂Ȃ�܂���B
%     USERS: �ǂ̃��[�U�������̐ݒ�̉e�����󂯂邩���`����X�y�[�X��
%            ��؂�ꂽ������ł��B(UNIX �̂�)
%           'a' : ���ׂẴ��[�U
%           'g' : ���[�U�O���[�v
%           'o' : ���̃��[�U
%           'u' : �J�����g�̃��[�U
%           �f�t�H���g�̑����́AUNIX �� umask �Ɉˑ����܂��B
%     MODIFIER: FILEATTRIB �̋������C������L�����N�^�̃X�J���ł��B
%           's' : �f�B���N�g���T�u�c���[���̃f�B���N�g���ƃt�@�C����
%                 �ċA�I�ɑ��삵�܂��B���� 4 ���Q�Ƃ��Ă��������B
%                 �f�t�H���g - MODIFIER ���Ȃ����A��̕�����ł��B
% �o�̓p�����[�^:
%     SUCCESS:  FILEATTRIB �̌��ʂƂ��Ē�`����� logical �̃X�J���ł��B
%                 1 ... FILEATTRIB �̎��s�ɐ���
%                 0 ... �G���[������
%     MESSAGE: �\���̔z��; ������v������ꍇ�A�ȉ��̃t�B�[���h�̍���
%              �t�@�C����������`����܂��B(���� 5 ���Q�Ƃ��Ă�������)
%
%                           Name: �t�@�C���܂��̓f�B���N�g���̖��O��
%                                 �܂ޕ�����x�N�g��
%                        archive: 0 �܂��� 1 �܂��� NaN 
%                         system: 0 �܂��� 1 �܂��� NaN 
%                         hidden: 0 �܂��� 1 �܂��� NaN 
%                      directory: 0 �܂��� 1 �܂��� NaN 
%                      OwnerRead: 0 �܂��� 1 �܂��� NaN 
%                     OwnerWrite: 0 �܂��� 1 �܂��� NaN 
%                   OwnerExecute: 0 �܂��� 1 �܂��� NaN 
%                      GroupRead: 0 �܂��� 1 �܂��� NaN 
%                     GroupWrite: 0 �܂��� 1 �܂��� NaN 
%                   GroupExecute: 0 �܂��� 1 �܂��� NaN 
%                      OtherRead: 0 �܂��� 1 �܂��� NaN 
%                     OtherWrite: 0 �܂��� 1 �܂��� NaN 
%                   OtherExecute: 0 �܂��� 1 �܂��� NaN 
%
%     MESSAGE: �G���[�A�܂��̓��[�j���O���b�Z�[�W���`���镶����ł��B
%              ��̕����� : FILEATTRIB �̎��s�ɐ����B
%              ���b�Z�[�W : �K�؂ȃG���[�܂��̓��[�j���O���b�Z�[�W�B
%     MESSAGEID: �G���[�A�܂��̓��[�j���O�̎��ʎq���`���镶����ł��B
%              ��̕����� : FILEATTRIB �̎��s�ɐ����B
%              ���b�Z�[�W id: �G���[�܂��̓��[�j���O���b�Z�[�W�̎��ʎq�B
%              (ERROR, LASTERR, WARNING, LASTWARN ���Q�Ƃ��Ă�������)
%
% ���:
%
% fileattrib mydir\*  �́A'mydir' �̑����Ɠ��e���ċA�I�ɕ\�����܂��B
%
% fileattrib myfile -w -s  �́A'�ǂݎ���p'������ݒ肵�A'myfile' ��
% '�V�X�e���t�@�C��'�̑����𖳌��ɂ��܂��B
%
% fileattrib 'mydir' -x  �́A'mydir' ��'���s�\'�̑����𖳌��ɂ��܂��B
%
% fileattrib mydir '-w -h'  �́A'mydir' �̉B�������𖳌��ɂ��A'�ǂݎ��
% ��p'�ɐݒ肵�܂��B
%
% fileattrib mydir -w a s  �́A���ׂẴ��[�U�ɑ΂��āA�T�u�f�B���N�g��
% �c���[�Ɠ��l��'�������݉\'�ȑ����𖳌��ɂ��܂��B
%
% fileattrib mydir +w '' s  �́A�T�u�f�B���N�g���c���[�Ɠ��l�ɁA'mydir'
% ���������݉\�ɐݒ肵�܂��B
%
% fileattrib myfile '+w +x' 'o g'  �́A�O���[�v�Ɠ��l�ɁA���̃��[�U��
% �΂��āA'myfile' ��'�������݉\'��'���s�\'�ȑ�����ݒ肵�܂��B
%
% [SUCCESS,MESSAGE,MESSAGEID] = fileattrib('mydir\*'); �́A���������ꍇ�A
% SUCCESS ���ɐ������1�ƁA'mydir' �̑����ƁA�\���̔z�� MESSAGE ����
% �T�u�f�B���N�g���c���[��Ԃ��܂��B���[�j���O���o���ꍇ�AMESSAGE �́A
% ���[�j���O���܂݁AMESSAGEID �́A���[�j���O���b�Z�[�W���ʎq���܂݂܂��B
% ���s�����ꍇ�ASUCCESS �́A�������0���܂܂�AMESSAGE �̓G���[���b
% �Z�[�W���܂܂�AMESSAGEID �̓G���[���b�Z�[�W���ʎq���܂܂�܂��B
%
% [SUCCESS,MESSAGE,MESSAGEID] = fileattrib('myfile','+w +x','o g') �́A
% �O���[�v�Ɠ��l�ɑ��̃��[�U�ɑ΂��āA'myfile' �̑����ɁA'�������݉\'
% ��'���s�\'��ݒ肵�܂��B
%
%
% ���� 1: FILEATTRIB ���o�͈����Ȃ��ŃR�[������AFILEATTRIB ���s����
%         �G���[�����������ꍇ�A�G���[���b�Z�[�W���\������܂��B
% ���� 2: UNC �p�X���T�|�[�g����܂��B�p�X�̕�������̖��O�̍Ō��
%         �g���q�Ƃ��āA�܂��͖��O�̍Ō�ɐڔ����Ƃ��Ẵ��C���h�J�[�h *
%         ���T�|�[�g����܂��B
% ���� 3: �I�y���[�V�����V�X�e���̓��ʂȑ����̏C����K�p���܂��B;
%         ����䂦�A�w�肳�ꂽ�����ȏC���́A�G���[���b�Z�[�W�Ƃ���
%         �Ԃ���܂��B
% ���� 4: Windows 2000 �ȍ~�ł� ATTRIB �̃X�C�b�` /s /d �͓����ł��B
%         MODIFIER �� 's' �́AWindows 2000 �ȑO�̃v���b�g�t�H�[���ł�
%         �T�|�[�g����Ă��܂���BWindows 2000 �ȑO�̃v���b�g�t�H�[��
%         ���  MODIFIER �� 's' ���w�肷��ƁA���[�j���O�̌����ɂȂ�
%         �܂��B
% ���� 5: �����̃t�B�[���h�l�́Alogical �̃^�C�v�ł��B������ NaN ��
%         �����ꂽ���̂́A���L�̃I�y���[�e�B���O�V�X�e���ɑ΂��Ē�`
%         ����܂���B
%
%
% �Q�l : CD, COPYFILE, DELETE, DIR, MKDIR, MOVEFILE, RMDIR.



%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc. 
