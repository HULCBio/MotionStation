% FIND_SYSTEM   �w�肵���p�����[�^�l������Simulink�V�X�e���̌���
%
% Systems = FIND_SYSTEM �́A�J���Ă��邷�ׂẴV�X�e�����������A���ׂẴV�X
% �e���A�T�u�V�X�e���A�u���b�N�̊K�w�̏��ԂɁA��΃p�X�����܂ރZ���z����o�͂�
%
% ���C�u���������N�ƃ}�X�N�u���b�N�́A�ʂ̃u���b�N�Ƃ��Ď�舵���A�f�t�H
% ���g�ł́A�����̉��w�̌����͍s���܂���B���L�Ɏ����I�v�V�����́A���̐U���
% ����ύX���邽�߂ɗ��p���邱�Ƃ��ł��܂��B
%
% Systems = FIND_SYSTEM('PARAMETER1',VALUE1,'PARAMETER2',VALUE2,...) �́A�J
% ���Ă��邷�ׂẴV�X�e�����������A�w�肵���p�����[�^���w�肵���l��������
% �ẴV�X�e���A�T�u�V�X�e���A�u���b�N�̊K�w�̏��ԂɁA��΃p�X�����܂ރZ���z��
% ���o�͂��܂��B�u���b�N���}���̂��ׂẴp�����[�^����������ɂ́A�p�����[�^��
% �Ƃ��āA'BlockDialogParams' ���g���Ă��������B
%
% ����:
% a) �p�����[�^���ɑ΂��đ啶���Ə���������ʂ��܂���B
% b) �l�̕�����́A�啶���Ə������̋�ʂ��s���܂��B
% c) �_�C�A���O�{�b�N�X�̗v�f�ɑ�������p�����[�^�́A������̒l�������܂��B
% d) ��ʂɌ��������u���b�N�p�����[�^�ɂ́A'BlockType', 'Name','Position'
% 'Parent'���܂܂�܂��B
%
% System=FIND_SYSTEM('CONSTRAINT1',CVALUE1,... ,'PARAMETER1',VALUE1, ...)
% �́AFIND_SYSTEM �̌������A�w�肵������/�l�̑g�A�w�肵���p�����[�^/�l�̑g�ɐ�
% �����܂��B���̕\�́A���p�\�Ȑ���/�l�̑g���L�q�������̂ł��B
%
%  SearchDepth    �[��H             �w�肵���[���Ɍ����𐧌����鐮���B
%
%  FindAll        ['on' | {'off'}]  FindAll�́A�����ɒ��߁A���C���A�[�q ���܂�
% �邽�߂ɂ́A'on'�ł���K�v������܂��B 'off'�ɐݒ肷��ƁA�u���b�N���}�ƃu���b
% �N�݂̂���������܂��BFindAll �� 'on'�̂Ƃ��AFIND_SYSTEM �̌��ʂ͏�Ƀn���h
% ������Ȃ�x�N�g���ł��B
%
% FollowLinks    ['on' | {'off'}]  ���C�u���������N�ɏ]�����ǂ������w��
%  LookUnderMasks             �قȂ�^�C�v�̃}�X�N���ꂽ�u���b�N ����������
% ���Ƃ̐���:                                      'none'         : �}�X�N
% ����Ă��Ȃ��u���b�N������                                     {'
% graphical'}   : ���[�N�X�y�[�X�ƃ_�C�A���O�������Ȃ��}�X�N������
% 'functional'   : �_�C�A���O�������Ȃ��}�X�N������
%                                      'all'             : ���ׂẴ}�X�N��
% �ꂽ�u���b�N������
%
%  CaseSensitive  [{'on'} | 'off']  ����������̃}�b�`���O�ŁA�啶���Ə�����
% �̋�ʂ��l�����邩�ǂ������w��
%
%  RegExp         ['on' | {'off'}]  ����������𐳋K�\���Ƃ��Ĉ������ǂ���
% ���w��B
%
% ���̐��K�\���́A����������ŔF������܂�:
% 	 ^        ������̐擪�Ƀ}�b�`
% 	 $        ������̖����Ƀ}�b�`
% 	 .	�C�ӂ̃L�����N�^�ƃ}�b�`
% 	�@\        ���̃L�����N�^�����p
% 	�@*        ���O��0�ȏ�̃L�����N�^�Ƀ}�b�`
% 	 +        ���O��1�ȏ�̃L�����N�^�Ƀ}�b�`
% 	 []       ���ʓ��̔C�ӂ̃L�����N�^�Ƀ}�b�`
% 	 \w       �P��[a-z_A-Z0-9]�Ƀ}�b�`
% 	 \W       �P��ȊO[^a-z_A-Z0-9]�Ƀ}�b�`
% 	 \d       ����[0-9]�Ƀ}�b�`
% 	 \D       �����ȊO[^0-9]�Ƀ}�b�`
% 	 \s       ��[ \t\r\n\f]�Ƀ}�b�`
% 	 \S       �󔒈ȊO[^ \t\r\n\f]�Ƀ}�b�`
% 	 \<WORD\> WORD�Ɋ��S�Ƀ}�b�`����P��
%
% FIND_SYSTEM('SearchDepth',DEPTH,'PARAMETER1',VALUE1,...) �́A�ŏ�ʃV�X�e
% ������w�肵��DEPTH�Ɍ����𐧌����܂��B�l0�́A�ŏ�ʃV�X�e���݂̂���������
% ���B�l 1�́A���ׂĂ̍ŏ�ʃV�X�e���Ɗe�V�X�e���̍ŏ�ʂ̃u���b�N����������
% ���B
%
% FIND_SYSTEM('SYS',...) �́A'SYS' ���V�X�e�����A�܂��́A�u���b�N�̃p�X���̂�
% ���A�w�肵���V�X�e�����猟�����J�n���܂��B
%
% FIND_SYSTEM(NAMES,...) �́ANAMES ���V�X�e�����܂��̓u���b�N�̃p�X�������
% ��Z���z��̂Ƃ��ANAMES�Ƀ��X�g���ꂽ�I�u�W�F�N�g���猟�����J�n���܂��B
%
% ���:
%
% find_system                          % �J���Ă��邷�ׂẴV�X�e������
% 			      % ���̒��̃u���b�N�����o��
%
% find_system('type','block_diagram')  % �J���Ă��邷�ׂẴu���b�N���}
% 			             % �����o��
%
% clutch
% find_system('clutch/Unlocked',...    % �T�u�V�X�e��clutch/Unlocked��
% 	     'SearchDepth',1,...      % (Goto �u���b�N���܂�Goto�u���b
% 'BlockType','Goto')     % �N��)����
%
% vdp
% gb = find_system('vdp',...     % vdp����Gain�u���b�N���������A
% 		   'BlockType','Gain') % ���ʂ�ϐ�'gb'�ɒu���A������
% find_system(gb,'Gain','1')                  �@�@% Gain�̒l��'1'�ł���u���b
% �N��				 �@�@�@% ����
%
% find_system('vdp',...               	 % vdp���Ńu���b�N�����L�����N�^
%  		'Regexp', 'on',...     % "x"�Ŏn�܂邷�ׂẴu���b�N��
% 	�@�@�@      'Name','^x')         % ����
%
% �Q�l : SET_PARAM, GET_PARAM, HASMASK, HASMASKDLG, HASMASKICON


% Copyright 1990-2002 The MathWorks, Inc.
