%NOTEBOOK   Microsoft Word �� M-book ���J���܂�( Windows �̂�)
% NOTEBOOK ���g�ł́AMicrosoft Word ���N�����A"Document 1" �Ɩ��t�����V����
% M-book ���쐬���܂��B
%
% NOTEBOOK(FILENAME) �́AMicrosoft Word ���N�����AM-book FILENAME ���I�[�v��
% ���܂��BFILENAME �����݂��Ȃ��ꍇ�AFILENAME �Ɩ��t�����V���� M-book ���쐬
% ���܂��B
%
% NOTEBOOK('-SETUP') �́ANOTEBOOK �p�̉�b�^�̐ݒ�֐��ł��B
% ���[�U�́AMicrosoft Word �̃o�[�W�����Ƃ������̃t�@�C���̈ʒu���v�����v�g
% �ɏ]���ē��͂��܂��B
%
% NOTEBOOK('-SETUP',WORDVER,WORDLOC,TEMPLATELOC) �́A�ŗL�̏����g���� 
% Notebook��ݒ肵�܂��B
% WORDVER �� Microsoft Word ('97'�܂���'2000'�܂���'2002')�̃o�[�W�����A
% WORDLOC�� winword.exe���܂ރf�B���N�g���ATEMPLATELOC �� Microsoft Word 
% �̃e���v���[�g�f�B���N�g���ł��B
%
% ���
% notebook
% notebook c:\documents\mymbook.doc
% notebook -setup
%
% Microsoft Word 97(winword.exe) ���AC:\Program Files\Microsoft Office 97
% \Office �f�B���N�g���ɃC���X�g�[������AC:\Program Files\Microsoft 
% Office 97\Templates directory �f�B���N�g���� Microsoft Word �e���v���[�g��
% �C���X�g�[������Ă���ꍇ�́A���̂悤�ɂȂ�܂��B
%
% wordver = '97';
% wordloc = 'C:\Program Files\Microsoft Office 97\Office';
% templateloc = 'C:\Program Files\Microsoft Office 97\Templates';
% notebook('-setup', wordver, wordloc, templateloc)

% Copyright 1984-2003 The MathWorks, Inc.
