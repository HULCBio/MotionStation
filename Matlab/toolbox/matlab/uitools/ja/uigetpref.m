% UIGETPREF (����)�ݒ���T�|�[�g��������_�C�A���O�{�b�N�X
%
% VALUE=UIGETPREF(GROUP, PREF, TITLE, QUESTION, PREF_CHOICES) �́A
% PREF_CHOICES �̒��ɁA�����̑I������_�C���O�{�b�N�X���g���ă��[�U����
% �̓��͂ɂ��A�܂��́A���ʐݒ�f�[�^�x�[�X�̒��ɃX�g�A����Ă������
% �̓�����߂����邩�̂ǂ��炩�ɂ��A1�̕�������o�͂��܂��B�f�t�H���g
% �́A�قȂ�v�b�V���{�^����I���̂��тɃ_�C�A���O�{�b�N�X���\������A
% �`�F�b�N�{�b�N�X���g���āA�߂�l��ݒ�ɃX�g�A����ׂ������R���g���[��
% ���A��̏����Ɏ����I�ɍė��p���邩���R���g���[�����܂��B�v�b�V���{�^��
% ��1��I������O�Ƀ`�F�b�N�{�^�����N���b�N����ƁA�v�b�V���{�^����
% �I���́A�ݒ�ɃX�g�A����ďo�͂���܂��BUIGETPREF �ւ̘A���I�ȃR�[���́A
% �ŐV�̑I�����ݒ�̒��ɃX�g�A����Ă��邩�𒲂ׁA�_�C�A���O��\������
% ���ŁA�����ɂ��̑I����߂��܂��B���[�U���v�b�V���{�^����I������O��
% �`�F�b�N�{�b�N�X���N���b�N���Ă��Ȃ��ꍇ�AUIGETPREF �ւ̘A���I�ȃR�[����
% �����ݒ�̒��ɃX�g�A����Ă�����ʂ̒l���_�C�A���O�{�b�N�X��\�����܂��B
%
% GROUP �� PREF �́A�ݒ���`���܂��B�ݒ肪���݂��Ȃ��ꍇ�́AUIGETPREF 
% �͂�����쐬���܂��B
%
% TITLE �́A�_�C�A���O��titlebar �̒��ɕ\�����镶������`���܂��B
%
% QUESTION �́A�_�C�A���O�̒��ɕ\�������L�q�I�Ȍ��ŁA�����z��A�܂�
% �͕����̃Z���z��̂����ꂩ�Ƃ��Ē�`���܂��B����ɂ́A���[�U������
% ������܂�ł���K�v������A���ꂩ�̑I����C���p�N�g�����S�ɗ�������
% �قǏڍׂɋL�q����K�v������܂��BUIGETPREF �́A�����z��̍s�̊ԁA
% �����̃Z���z��̗v�f�ԁA�܂��́A�����x�N�g���̒���'|'�A�V�������C��
% �L�����N�^�̊Ԃɉ��s�����܂��B
%
% PREF_CHOICES �́A������A������̃Z���z��A�܂��́A��������؂�'|'��
% �����ꂩ�ŁA�v�b�V���{�^����ɕ\������镶�����w�肵�܂��B�e������́A
% �ʁX�̃v�b�V���{�^���̒��ɕ\������܂��B�I�����ꂽ�v�b�V���{�^����
% ��̕����񂪖߂���܂��B
% �`�F�b�N�{�b�N�X���N���b�N�����ƁA��������A�D�揇�ʐݒ�ɃX�g�A
% ����܂��B�`�F�b�N�{�b�N�X���N���b�N����Ă��Ȃ��ꍇ�A���ʂȒl���ݒ�
% �ɃX�g�A����܂��B
%
% PREF_CHOICES �́A�����̐ݒ�l���v�b�V���{�^����ɕ\������Ă��镶����
% �ƈقȂ��Ă���ꍇ�A�������2xN�̃Z���z��ł��\���܂���B�ŏ��̍s�́A
% �ݒ�̕�����ŁA2�Ԗڂ̍s�́A�֘A�����v�b�V���{�^���̕�����ł��B�D��
% ���ʂ̐ݒ�́AVALUE �ɖ߂���Ă��āA�{�^�����x���ɂ͂Ȃ��Ă��Ȃ����Ƃ�
% ���ӂ��Ă��������B
%
% [VAL,DLGSHOWN] = UIGETPREF(...) �́A�_�C�A���O��������Ă��邩�ۂ���
% �o�͂��܂��B
%
% �t���I�Ȉ����́A�p�����[�^�ƒl�Ƃ̑g�œn���܂��B
%
% (...'CheckboxState',0 �܂��� 1) �́A�`�F�b�N�{�b�N�X�̏�����Ԃ��A
% �`�F�b�N�A�܂��̓`�F�b�N�Ȃ��̂����ꂩ�ɐݒ肵�܂��B�f�t�H���g�ł́A
% �`�F�b�N�Ȃ��ł��B
%
% (...'CheckboxString',CBSTR) �́A�`�F�b�N�{�b�N�X�̏�ɕ������ݒ肵�܂��B
% �f�t�H���g�ł́A'Never show this dialog again(�ēx�A���̃_�C�A���O��
% �\���ł��܂���)'�ł��B
%
% (...'HelpString',HSTR) �́A�w���v�{�^���̏�ɕ������ݒ肵�܂��B
% �f�t�H���g�ł́A������͋�ŁA�w���v�{�^���͂���܂���B
%
% (...'HelpFcn',HFCN) �́A�w���v�{�^���������ꂽ�Ƃ��A���s����R�[���o�b�N��
% �ݒ肵�܂��B�f�t�H���g�ł́Adoc('uigetpref')�ł��B'HelpString'���Ȃ��ꍇ�A
% �{�^���͍쐬����܂���B
%
% (...'ExtraOptions',EO) �́A�������̗D�揇�ʂ̐ݒ���}�b�s���O�ł��Ȃ�
% ���ʂ̃{�^�����쐬���܂��B������A�܂��́A������̃Z���z��̂ǂ���ł�
% �\���܂���B�f�t�H���g�ł́A{}�ŁA���ʂȃ{�^���͍쐬����܂���B
%
% (...'DefaultButton',DB) �́A�_�C�A���O���N���[�Y����ꍇ�ɏo�͂���
% �{�^���l��ݒ肵�܂��B�f�t�H���g�ł́A�ŏ��̃{�^���ɑΉ����܂��BDB ��
% �D�揇�ʂ̐ݒ�A�܂��́AExtraOption �ɑΉ�������̂ł͂Ȃ����Ƃɒ���
% ���Ă��������B
%
% ���F
%
%  [selectedButton,dlgShown]=uigetpref('graphics','savefigurebeforeclosing',...
%       'Closing Figure',...
%       {'Do you want to save your figure before closing?'
%         ''
%	      'You can save your figure manually by typing ''hgsave(gcf)'''},...
%       {'always','never';'Yes','No'},...
%       'ExtraOptions','Cancel',...
%       'DefaultButton','Cancel',...
%       'HelpString','Help',...
%       'HelpFcn','doc(''closereq'');')
%
% �Q�l�F UISETPREF, GETPREF, SETPREF, ADDPREF, RMPREF


%  Copyright 1999-2002 The MathWorks, Inc.
%  $Revision: 1.2.4.1 $
