% MKDIR   �V�K�f�B���N�g���̍쐬
%
% [SUCCESS,MESSAGE,MESSAGEID] = MKDIR(PARENTDIR,NEWDIR) �́A�e�� 
% PARENTDIR �̉��ɁA�V�K�f�B���N�g���� NEWDIR �Ƃ��č쐬���܂��B
% PARENTDIR ����΃p�X�Ƃ��Ďw�肳��Ă�Ԃ́ANEWDIR �́A���΃p�X
% �łȂ���΂Ȃ�܂���BNEWDIR �����݂���ꍇ�AMKDIR �́ASUCCESS = 1
% ���o�͂��A���[�U�Ɋ��Ƀf�B���N�g�������݂���Ƃ������[�j���O���o��
% �܂��B
% 
% [SUCCESS,MESSAGE,MESSAGEID] = MKDIR(NEWDIR) �́ANEWDIR �����΃p�X��
% �\�킷�ꍇ�A�J�����g�f�B���N�g�����ɁA�f�B���N�g�� NEWDIR ���쐬���܂��B
% �����łȂ��ꍇ�ANEWDIR �́A��΃p�X��\�킵�AMKDIR �́A�J�����g�{�����[��
% �̃��[�g�ɐ�΃f�B���N�g�� NEWDIR ���쐬���悤�Ǝ��݂܂��B��΃p�X�́A
% Windows �h���C�u�̕����AUNC �p�X '\\' ������A�܂��́A UNIX '/' ������
% �����ꂩ�ł͂��܂�܂��B
% [SUCCESS,MESSAGE,MESSAGEID] = MKDIR(NEWDIR) �́A�J�����g�f�B���N�g��
% ���ɁA�f�B���N�g�� NEWDIR ���쐬���܂��B
%
% [SUCCESS,MESSAGE,MESSAGEID] = MKDIR(PARENTDIR,NEWDIR) �́A���݂���
% �f�B���N�g�� PARENTDIR �ɁA�f�B���N�g�� NEWDIR ���쐬���܂��B
%
% ���̓p�����[�^:
%     PARENTDIR : �e�f�B���N�g���Ŏw�肳��镶����ł��B���� 1 ��
%                 �Q�Ƃ��Ă��������B
%     NEWDIR : �V�K�f�B���N�g���Ƃ��Ďw�肳��镶����ł��B
%
% �o�̓p�����[�^:
%     SUCCESS : MKDIR �̌��ʂ��`���� logical �̃X�J���ł��B
%              1 : MKDIR �͎��s�ɐ���
%              0 : �G���[������
%     MESSAGE : �G���[�܂��̓��[�j���O���b�Z�[�W���`���镶����ł��B
%               ��̕����� : MKDIR �͎��s�ɐ���
%               ���b�Z�[�W : �K�؂ȃG���[�܂��̓��[�j���O���b�Z�[�W
%     MESSAGEID : �G���[�܂��̓��[�j���O�̎��ʎq���`���镶����ł��B
%                 ��̕����� : MKDIR �͎��s�ɐ���
%                 ���b�Z�[�W : �K�؂ȃG���[�܂��̓��[�j���O�̎��ʎq
%                 (ERROR, LASTERR, WARNING, LASTWARN ���Q��)
%
% ���� 1: UNC �p�X���T�|�[�g����Ă��܂��B
% 
% �Q�l�FCD, COPYFILE, DELETE, DIR, FILEATTRIB, MOVEFILE, RMDIR.



%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $ $Date: 2004/04/28 01:53:23 $
