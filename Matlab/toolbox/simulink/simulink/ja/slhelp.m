% SLHELP   Simulink���[�U�[�Y�K�C�h�܂��̓u���b�N�̃w���v�̕\��
%
% SLHELP�́ASimulink�I�����C�����[�U�[�Y�K�C�h���w���v�u���E�U�ɕ\�����܂��B
%
% SLHELP(BLOCK_HANDLE) �́A���p�\�Ȃ��HTML Help viewer�ɁA�����łȂ��ꍇ��
% �́A�f�t�H���g��web�u���E�U��Simulink�u���b�N���t�@�����X�y�[�W��\�����܂��B
% �\�������y�[�W�́ABLOCK_HANDLE�ɂ���ă|�C���g�����u���b�N�̃��t�@����
% �X�y�[�W�ł��BBLOCK_HANDLE�́A���l�̃n���h���A�܂��́A�u���b�N�̐��
% Simulink �p�X�̂����ꂩ�ō\���܂���B
%
% �}�X�N���ꂽ�u���b�N�ɑ΂��ẮAmask editor�_�C�A���O�{�b�N�X��MaskHelp
% �t�B�[���h�ɓ��͂��ꂽ�e�L�X�g���\������܂��B���̋@�\�́A�}�X�N�̃w���v�e�L
% �X�g����HTML�R�[�h�̗��p���\�ɂ��܂��B
%
% ���:
% slhelp(gcb)              %--  �I�����ꂽ�u���b�N�̃w���v�e�L�X�g
%                            %     ��\��
% slhelp('mysys/myblock')  %--  'mysys'�Ƃ����u���b�N���}����
%          %    'myblock'�Ƃ����u���b�N�̃w��
%        %    �v��\��
%
% mask editor��Mask Help�t�B�[���h�œ���ȃe�L�X�g��p���邱�Ƃɂ���āA
% �u���b�N�_�C�A���O��Help�{�^���Ɗ֘A����h�L�������g�������N���邱�Ƃ�
% �ł��܂��B
% Mask Help�t�B�[���h��URL�𒼐ڎw��ł��܂��B
% URL�̎w��q, 'file','ftp', 'mailto', 'news'���T�|�[�g����Ă��܂��B '
% http', 'file', 'ftp','mailto' and 'news'.
% MATLAB�� 'web(...)','eval(...)'�A����сA'helpview(...)'�R�}���h�����p�ł�
%
% ����ȃ^�O��Mask Help�e�L�X�g�̐擪�ɂ���ꍇ�ɂ́A�u���E�U���Ƀe�L�X�g��
% ���̂�\���������ɁA�K�؂ȃA�N�V�������s���܂��B
%
% ���̃h�L�������g�ւ�Mask Help�̃����N�̃e�L�X�g�̗�:
% http://www.mathworks.com
% file:///C:\Document.htm
% web(['file:///' which(func.m)]);
% eval('!edit file.txt');
%
% �Q�l : DOC, DOCOPT, HELPVIEW, HELPWIN, WEB


% Copyright 1990-2002 The MathWorks, Inc.
