% RMDIR	  �f�B���N�g���̍폜
%
% [SUCCESS,MESSAGE,MESSAGEID] = RMDIR(DIRECTORY,MODE) �́A�e�f�B���N�g
% ������ DIRECTORY �Ŏw�肳�ꂽ�A�N�Z�X�������f�B���N�g�����폜����
% ���BRMDIR �́A�T�u�f�B���N�g�����ċA�I�ɍ폜���邱�Ƃ��ł��܂��B
%
% [SUCCESS,MESSAGE,MESSAGEID] = RMDIR(DIRECTORY) �́ADIRECTORY �����
% �f�B���N�g���ł���ꍇ�̂݁A�e�f�B���N�g������ DIRECTORY ���폜���܂��B
%
% [SUCCESS,MESSAGE,MESSAGEID] = RMDIR(DIRECTORY, 's') �́A�e�f�B���N�g��
% ����T�u�f�B���N�g���c���[���܂� DIRECTORY ���폜���܂��B���� 1 ��
% �Q�Ƃ��Ă��������B

% ���̓p�����[�^:
%     DIRECTORY: ���΂��邢�͐�΃p�X�Ŏw�肳��镶����ł��B
%                ���� 2 ���Q�Ƃ��Ă��������B
%     MODE: ����̃��[�h�������L�����N�^�̃X�J���ł��B
%           's' : DIRECTORY �Ɋ܂܂��T�u�f�B���N�g���c���[���ċA�I��
%                 �폜����邱�Ƃ������܂��B���� 3 ���Q�Ƃ��Ă��������B
%     
% �o�̓p�����[�^:
%     SUCCESS: RMDIR �̌��ʂ��`���� logical �̃X�J���ł��B
%                 1 : RMDIR �̎��s�ɐ���
%                 0 : �G���[������
%     MESSAGE: �G���[�܂��̓��[�j���O���b�Z�[�W���`���镶����ł��B
%              ��̕����� : RMDIR �̎��s�ɐ���
%              ���b�Z�[�W : �K�؂ȃG���[�܂��̓��[�j���O���b�Z�[�W
%     MESSAGEID: �G���[�܂��̓��[�j���O���ʎq���`���镶����ł��B
%              ��̕����� : RMDIR �̎��s�ɐ���
%              ���b�Z�[�Wid : MATLAB�G���[�܂��̓��[�j���O���b�Z�[�W���ʎq
%              (ERROR, LASTERR, WARNING, LASTWARN���Q��)
%
% ���� 1: �T�u�f�B���N�g���c���[�̓t�@�C���܂��̓T�u�f�B���N�g���̏���
%         ���ݑ����Ɋ֌W�Ȃ��폜����܂��B
% ���� 2: UNC �p�X���T�|�[�g����܂��BRMDIR �́A���K�\���̃��C���h�J�[�h
%          * �̎g�p���T�|�[�g���܂���B
% ���� 3: RMDIR �́AWindows 98�A�܂��� Millennium �ł� 's' ���[�h�ł�
%         �폜���T�|�[�g���܂���B
%
% �Q�l : CD, COPYFILE, DELETE, DIR, FILEATTRIB, MKDIR, MOVEFILE.


%   JP Barnard
%   Copyright 1984-2003 The MathWorks, Inc. 
