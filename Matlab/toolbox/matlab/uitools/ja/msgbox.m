% MSGBOX   ���b�Z�[�W�{�b�N�X
% 
% msgbox(Message) �́A�K�؂ȃT�C�Y��Figure�ɍ����悤�� Message �������I
% �ɉ��s���āA���b�Z�[�W�{�b�N�X���쐬���܂��BMessage �́A������x�N�g���A
% ������s��A�܂��́A�Z���z��ł��B
%
% msgbox(Message,Title) �́A���b�Z�[�W�{�b�N�X�̃^�C�g�����w�肵�܂��B
%
% msgbox(Message,Title,Icon) �́A���b�Z�[�W�{�b�N�X�ɕ\������A�C�R����
% �w�肵�܂��BIcon �́A'none'�A'error'�A'help'�A'warn'�A'custom' �̂����ꂩ
% �ł��B�f�t�H���g�́A'none' �ł��B
%
% msgbox(Message,Title,'custom',IconData,IconCMap) �́A�J�X�^���A�C�R����
% ��`���܂��BIconData �́A�A�C�R�����`����C���[�W�f�[�^���܂݂܂��B
% IconCMap �́A�C���[�W�ɑ΂��Ďg�p�����J���[�}�b�v�ł��B
%
% msgbox(Message,...,CreateMode) �́A���b�Z�[�W�{�b�N�X��modal���ǂ�����
% �ݒ肵�܂��B�܂��Amodal�łȂ��ꍇ�A���̃��b�Z�[�W�{�b�N�X�𓯂�Title��
% �u�������邩�ۂ���ݒ肵�܂��BCreateMode �ɑ΂��Ďg�p�\�Ȓl�́A
% 'modal', 'non-modal','replace' �ŁAnon-modal' ���f�t�H���g�ł��B
% 
% CreateMode �́AWindowStyle �� Interpreter �����o�[�����\���̂ɂȂ�܂��B
% WindowStyle �́A��Őݒ肵���l�̂����ꂩ���g���܂��BInterpreter �́A
% 'text' �܂��� 'none' �̂����ꂩ���g���܂��BInterpreter �ɑ΂���f�t�H���g
% �l�� 'none' �ł��B
%
% h = msgbox(...) �́A�{�b�N�X�̃n���h���ԍ���h�ɏo�͂��܂��B
%
% ���[�U����������܂ŁAmsgbox�u���b�N�����s���邽�߂ɁA���͈������X�g
% �̒��ɁA������ 'modal' ���܂܂��AUIWAIT �Ƌ��� msgbox �ւ̃R�[�����~
% ���܂��B 
%
% ���[�U����������܂Ńu���b�N�����s�����������܂��B
%    uiwait(msgbox('String','Title','modal'));
%
% �J�X�^���A�C�R�����g������������܂��B
% 
%    Data=1:64;Data=(Data'*Data)/64;
%    h=msgbox('String','Title','custom',Data,hot(64))
%
% ������ msgbox �E�B���h�E���ė��p�����������܂��B
% 
%    CreateStruct.WindowStyle='replace';
%    CreateStruct.Interpreter='tex';
%    h=msgbox('X^2 + Y^2','Title','custom',Data,hot(64),CreateStruct);
%  
% �Q�l�F DIALOG, ERRORDLG, HELPDLG, TEXTWRAP, WARNDLG, UIWAIT.


%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.9.4.1 $
