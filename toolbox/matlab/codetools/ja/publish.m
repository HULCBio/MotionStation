%PUBLISH    �X�N���v�g�̎��s�ƌ��ʂ̕ۑ�
% PUBLISH(CELLSCRIPT,FORMAT) �́A�w�肵���`���ŃX�N���v�g���o�͂��܂��B
% FORMAT �́A���̂����ꂩ�ɂȂ�܂��B
%
%      'html' - HTML.
%      'doc'  - Microsoft Word ( Microsoft Word ���K�v�ł� )�B
%      'ppt'  - Microsoft PowerPoint ( Microsoft PowerPoint ���K�v�ł�)�B
%      'xml'  - XSLT �܂��� ���̃c�[���ŕϊ��\�� XML �t�@�C��
%      'rpt'  - Report Generator Template �Z�b�g�A�b�v�t�@�C��
%               ( Report Generator ���K�v�ł�)�B
%      'latex'  - TeX.  �܂��A�f�t�H���g�� imageFormat �� 'epsc2' �ɕύX���܂��B%
% PUBLISH(SCRIPT,OPTIONS) �́A���̃t�B�[���h�̂����ꂩ���܂ލ\���̂�
% �񋟂��܂��B (���X�g�̍ŏ��̑I�����f�t�H���g�ł�):
%
%       format: 'html' | 'doc' | 'ppt' | 'xml' | 'rpt' | 'latex'
%       stylesheet: '' | XSL �t�@�C���� (format = html �܂��� xml 
%                   �łȂ����薳������܂�)
%       outputDir: '' (���̃t�@�C����艺�ʂ� html �T�u�t�H���_) | �t���p�X
%       imageFormat: 'png' | figureSnapMethod �Ɉˑ����āAPRINT �܂��� 
%                    IMWRITE �ɂ��T�|�[�g��������
%       figureSnapMethod: 'print' | 'getframe'
%       useNewFigure: true | false
%       maxHeight: [] | ���̐��� (�s�N�Z��)
%       maxWidth: [] | ���̐��� (�s�N�Z��)
%       showCode: true | false
%       evalCode: true | false
%       stopOnError: true | false
%       createThumbnail: true | false
%
% HTML �ɏo�͂���ƁA �f�t�H���g�̃X�^�C���V�[�g�́A"showcode = false" 
% �̏ꍇ�ł��A HTML �R�����g�Ƃ��ăI���W�i���̃R�[�h��ۑ����܂�
% ���o���邽�߂� GRABCODE ���g�p���Ă��������B
%
% �Q�l GRABCODE.

% Matthew J. Simoneau, June 2002

% Copyright 1984-2004 The MathWorks, Inc.
