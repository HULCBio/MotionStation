% MOVEFILE   �t�@�C���܂��̓f�B���N�g���̈ړ�
%
% [STATUS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION,MODE) �́A
% �t�@�C���܂��̓f�B���N�g�� SOURCE ��V�K�̃t�@�C���܂��̓f�B���N�g�� 
% DESTINATION �Ɉړ����܂��BSOURCE �� DESTINATION �́A�J�����g�f�B���N
% �g���̑��΃p�X���A�܂��͐�΃p�X���̂����ꂩ�ł��BMODE ���g�p����
% �ꍇ�AMOVEFILE �́ADESTINATION ���ǂݍ��ݐ�p�ł����Ă��ASOURCE ��
% DESTINATION �Ɉړ����܂��BDESTINATION �̏������ݑ����́A�ۑ�����܂��B
% ���� 1 ���Q�Ƃ��Ă��������B
%
% [STATUS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE) �́A�J�����g�f�B���N
% �g���Ƀ\�[�X���ړ����܂��B���� 2 ���Q�Ƃ��Ă��������B
%
% [STATUS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION) �́ASOURCE 
% �� DESTINATION �Ɉړ����܂��BSOURCE �̍Ō�Ƀ��C���h�J�[�h * ������
% �ꍇ�A���ׂĂɈ�v����t�@�C���I�u�W�F�N�g�� DESTINATION �Ɉړ�����
% �܂�(���� 3 ���Q��)�BDESTINATION ���f�B���N�g���̏ꍇ�AMOVEFILE �́A
% DESTINATION �̉��� SOURCE ���ړ����܂��BSOURCE ���f�B���N�g���A�܂���
% �Ō�� * �������āA���� DESTINATION �����݂��Ȃ��ꍇ�AMOVEFILE �́A
% �f�B���N�g���Ƃ��� DESTINATION ���쐬���ADESTINATION �̉��� SOURCE ��
% �ړ����܂��BSOURCE ���ЂƂ̃t�@�C���ŁADESTINATION ���f�B���N�g����
% �͂Ȃ��A�܂��͑��݂��Ȃ��ꍇ�ASOURCE �́A�L���Ȗ��O DESTINATION ��
% ��������܂��B
% 
% [STATUS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION,'f') �́A
% DESTINATION ���ǂݎ���p�ł����Ă��A��L�̂悤�ɁASOURCE �� 
% DESTINATION �Ɉړ����܂��BDESTINATION �̏������ݑ����̏�Ԃ͕ۑ�����
% �܂��B
%
% ���̓p�����[�^:
%     SOURCE: �\�[�X�t�@�C���܂��̓f�B���N�g���Ƃ��Ē�`����� 1�~n ��
%             ������ł��B���� 4 ���Q�Ƃ��Ă��������B
%     DESTINATION: �ړ���̃t�@�C���܂��̓f�B���N�g���Ƃ��Ē�`�����
%                  1�~n �̕�����ł��B���� 5 ���Q�Ƃ��Ă��������B
%     MODE: �R�s�[���[�h���`����L�����N�^�̃X�J���ł��B
%           'f' : SOURCE �� DESTINATION �ɋ����I�ɏ������݂܂��B
%                 ���� 5 ���Q�Ƃ��Ă��������B
%                 �ȗ����ꂽ�ꍇ�AMOVEFILE �́ADESTINATION �̌��݂�
%                 �������ݏ�Ԃ�D�悵�܂��B
%
% �o�̓p�����[�^:
%     SUCCESS: MOVEFILE �̌��ʂ��`���� logical �̃X�J���ł��B
%              1 : MOVEFILE �̎��s�ɐ����B
%              0 : �G���[�������B
%     MESSAGE: �G���[�܂��̓��[�j���O���b�Z�[�W���`���镶����ł��B
%              ��̕����� : MOVEFILE �̎��s�ɐ����B
%              ���b�Z�[�W : �K�؂ȃG���[�܂��̓��[�j���O���b�Z�[�W�B
%     MESSAGEID: �G���[�܂��̓��[�j���O���ʎq���`���镶����ł��B
%              ��̕����� : MOVEFILE �̎��s�ɐ����B
%              ���b�Z�[�W id: �K�؂ȃG���[�܂��̓��[�j���O���ʎq�B
%              (ERROR, LASTERR, WARNING, LASTWARN ���Q��)
%
% ���� 1: ���̏ꍇ���̂����āA�t�@�C���A�f�B���N�g�����ړ������Ƃ��ɂ́A
%         OS �̑����ۑ��Ɋւ���K�����K�p����܂��B
% ���� 2: MOVEFILE �́A���g�Ƀt�@�C�����ړ����邱�Ƃ͂ł��܂���B
% ���� 3: MOVEFILE �́A1�̃t�@�C�����ɕ����̃t�@�C�����ړ����邱�Ƃ�
%         �ł��܂���
% ���� 4: UNC �p�X���T�|�[�g����Ă��܂��B���O�̍Ō�ɐڔ����Ƃ��āA
%         ���邢�́A�p�X�̕�������̖��O�̍Ō�̊g���q�Ƃ��Ẵ��C���h
%         �J�[�h * ���T�|�[�g����Ă��܂��B
% ���� 5: 'writable' �́A�폜����܂����A���ʌ݊����̂��߂ɂ܂��T�|�[�g
%         ����Ă��܂��B
%
% �Q�l : CD, COPYFILE, DELETE, DIR, FILEATTRIB, MKDIR, RMDIR.


%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc. 
