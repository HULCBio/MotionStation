%  UIGETDIR   �W���̃I�[�v���f�B���N�g���_�C�A���O�{�b�N�X
%
% DIRECTORYNAME = UIGETDIR(STARTPATH, TITLE) �́A�f�B���N�g���\����
% �\�����A�f�B���N�g����I�����A�f�B���N�g�����𕶎���Ƃ��ďo�͂���
% �_�C�A���O�{�b�N�X��\�����܂��B�f�B���N�g�������݂���ꍇ�́A�����
% �o�͂��܂��B
%
% STARTPATH �p�����[�^�́A�_�C�A���O�{�b�N�X���̏����̃f�B���N�g����
% �t�@�C���̕\�������肵�܂��B
%
% STARTPATH ����̏ꍇ�́A�_�C�A���O�{�b�N�X�́A�J�����g�f�B���N�g����
% �I�[�v������܂��B
%
% STARTPATH ���L���ȃf�B���N�g���p�X��\�킷������̏ꍇ�́A�_�C�A���O
% �{�b�N�X�́A�w�肵���f�B���N�g���ɃI�[�v������܂��B
%
% STARTPATH ���L���ȃf�B���N�g���p�X�łȂ��ꍇ�́A�_�C�A���O�{�b�N�X�́A
% �x�[�X�f�B���N�g���ɃI�[�v������܂��B
%
% Windows:
% �x�[�X�f�B���N�g���́AWindows Desktop�f�B���N�g���ł��B
%
% UNIX: 
% �x�[�X�f�B���N�g���́A�l�`�s�k�`�a���N������f�B���N�g���ł��B�_�C�A
% ���O�{�b�N�X�́A�f�t�H���g�ł��ׂẴt�@�C���^�C�v��\�����܂��B�\��
% �����t�@�C���̃^�C�v�́A�_�C�A���O�{�b�N�X��Selected Directory
% �t�B�[���h�̃t�B���^�������ύX���邱�Ƃɂ���āA�ύX���邱�Ƃ��ł�
% �܂��B���[�U���f�B���N�g���ł͂Ȃ��t�@�C����I�������ꍇ�́A�t�@�C��
% ���܂ރf�B���N�g�����o�͂���܂��B
%
% �p�����[�^ TITLE �́A�_�C�A���O�{�b�N�X�̃^�C�g�����܂ޕ�����ł��B
% TITLE ����̏ꍇ�́A�f�t�H���g�̃^�C�g�����_�C�A���O�{�b�N�X�Ɋ���
% ���Ă��܂��B
%
% Windows:
% TITLE ������́A���[�U�ւ̎w�����w�肷��_�C�A���O�{�b�N�X���̃f�t�H
% ���g�̃L���v�V������u�������܂��B
%
% UNIX:
% TITLE ������́A�_�C�A���O�{�b�N�X�̃f�t�H���g�̃^�C�g����u������
% �܂��B
%
% ���̓p�����[�^���w�肳��Ȃ��Ƃ��́A�_�C�A���O�{�b�N�X�̓f�t�H���g��
% �_�C�A���O�^�C�g�����g���ăJ�����g�f�B���N�g���ɃI�[�v�����܂��B
%
% �o�̓p�����[�^ DIRECTORYNAME �́A�_�C�A���O�{�b�N�X�őI�����ꂽ�f�B
% ���N�g�����܂ޕ�����ł��B���[�U��Cancel�{�^�����������ꍇ�́A0��
% �o�͂��܂��B
%
% ���:
%
%   directoryname = uigetdir;
%
%   Windows:
%   directoryname = uigetdir('D:\APPLICATIONS\MATLAB');
%   directoryname = uigetdir('D:\APPLICATIONS\MATLAB', 'Pick a Directory');
%
%   UNIX:
%   directoryname = uigetdir('/home/matlab/work');
%   directoryname = uigetdir('/home/matlab/work', 'Pick a Directory');
%
% �Q�l �F UIGETFILE, UIPUTFILE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 02:08:55 $
%   Built-in function.