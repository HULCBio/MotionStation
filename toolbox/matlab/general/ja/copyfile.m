% COPYFILE   �t�@�C���܂��̓f�B���N�g���̃R�s�[
% 
% [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE,DESTINATION,MODE) �́A
% �t�@�C���܂��̓f�B���N�g�� SOURCE ��V�����t�@�C���܂��̓f�B���N�g�� 
% DESTINATION �ɃR�s�[���܂��BSOURCE �� DESTINATION �̗����́A�J�����g
% �f�B���N�g���Ɋւ����΃p�X���܂��̓p�X���̂����ꂩ�ł��BMODE ���ݒ�
% ����Ă���ꍇ�ADESTINATION ���ǂݎ���p�ł����Ă��ACOPYFILE �́A
% SOURCE �� DESTINATION �ɃR�s�[���܂��BDESTINATION ���������݂̑�����
% ��Ԃ́A�ۑ�����܂��B���� 1 ���Q�Ƃ��Ă��������B
%
% [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE) �́A�J�����g�̃f�B��
% �N�g���� SOURCE ���R�s�[���܂��B
%
% [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE, DESTINATION) �́A
% SOURCE �� DESTINATION �ɃR�s�[���܂��BSOURCE ���f�B���N�g���A�܂���
% �����̃t�@�C�����܂݁ADESTINATION �����݂���ꍇ�ACOPYFILE �́A
% �f�B���N�g���Ƃ��� DESTINATION ���쐬���ASOURCE �� DESTINATION ��
% �R�s�[���܂��BSOURCE ���f�B���N�g���A�܂��͕����̃t�@�C�����܂݁A
% ��L�� DESTINATION �ւ̓K�p���Ȃ��ꍇ�ACOPYFILE �͎��s���܂��B
%
% [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE,DESTINATION,'f') �́A
% DESTINATION ���ǂݎ���p�ł����Ă��A��L�̂悤�ɁASOURCE �� 
% DESTINATION �ɃR�s�[���܂��BDESTINATION �̏������ݑ����̏�Ԃ́A�ۑ�
% ����܂��B
%
% ���̓p�����[�^:
%     SOURCE: �\�[�X�t�@�C���܂��̓f�B���N�g���Ƃ��Ē�`�����1�~n ��
%             ������ł��B����2 ����� 3 ���Q�Ƃ��Ă��������B
%     DESTINATION: �R�s�[��̃t�@�C���܂��̓f�B���N�g���Ƃ��Ē�`�����
%                  1�~n �̕�����ł��B�f�t�H���g�̓J�����g�f�B���N�g��
%                  �ł��B���� 3 ���Q�Ƃ��Ă��������B
%     MODE: �R�s�[���[�h�Ƃ��Ē�`�����L�����N�^�̃X�J���ł��B
%           'f' : SOURCE �� DESTINATION �ɋ����I�ɏ������܂�܂��B�ȗ�
%                 ���ꂽ�ꍇ�ACOPYFILE �� DESTINATION �̌��݂̏�������
%                 ��Ԃ������܂��B���� 4 ���Q�Ƃ��Ă��������B
%
% �o�̓p�����[�^:
%     SUCCESS: COPYFILE �̌��ʂ��`���� logical �̃X�J���ł��B
%              1 : COPYFILE �́A���s�ɐ���
%              0 : �G���[������
%     MESSAGE: �G���[�A�܂��̓��[�j���O���b�Z�[�W���`���镶����ł��B
%              ��̕����� : COPYFILE �͎��s�ɐ���
%              ���b�Z�[�W : �K�؂ȃG���[�܂��̓��[�j���O���b�Z�[�W
%     MESSAGEID: �G���[�܂��̓��[�j���O�̎��ʎq���`���镶����
%           ��̕����� : COPYFILE �͎��s�ɐ���
%           message id: MATLAB�G���[�܂��̓��[�j���O���b�Z�[�W�̎��ʎq
%	    (ERROR�ALASTERR�AWARNING�ALASTWARN ���Q��)
%
% ���� 1: ���݁ASOURCE �̑����́AWindows �v���b�g�t�H�[����ŃR�s�[����
%         ����Ƃ��ɂ͕ۑ�����܂���B���̏�Ԃ��̂����āA�����̕ۑ���
%         �ւ��鍪�{�I�ȃV�X�e���̃��[���́A�t�@�C���ƃf�B���N�g����
%         �R�s�[�����ꍇ�A�ȉ��̂Ƃ���ł��B
% ���� 2: �p�X�̕�������̖��O�̍Ō�̊g���q�Ƃ��āA�܂��͖��O�̍Ō��
%         �ڔ����Ƃ��āA���C���h�J�[�h * ���T�|�[�g����Ă��܂��B
%         ���C���h�J�[�h * ���g�p�A�܂��̓f�B���N�g�����R�s�[����ꍇ�A 
%         COPYFILE �̌��݂̋����́AUNIX �� Windows �ԂňقȂ�܂��B�ڍ�
%         �́ADOC COPYFILE ���Q�Ƃ��Ă��������B
% ���� 3: UNC �p�X���T�|�[�g����Ă��܂��B
% ���� 4: 'writable' �́A�폜����܂����A���ʌ݊����̂��߂ɂ܂��T�|�[�g
%         ����Ă��܂��B

%
% �Q�l�FCD, DELETE, DIR, FILEATTRIB, MKDIR, MOVEFILE, RMDIR.


%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc. 
