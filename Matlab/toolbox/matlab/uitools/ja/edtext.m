% EDTEXT   axes��text�I�u�W�F�N�g�̑Θb�I�ҏW
% 
% EDTEXT �́A�G�f�B�^�u���e�L�X�guicontrol��GCO�̈�ԏ�Ɉړ����邱�Ƃ�
% ��莋�o�\�ɂ��Astring �v���p�e�B��GCO�̃v���p�e�B�ɐݒ肷�邱�ƂŁA
% GCO �� string �v���p�e�B��ҏW���܂��Buicontrol�̃R�[���o�b�N���g���K
% ����Ă���΁AGCO��string�v���p�e�B�́A���[�U�����͂������̂ɐݒ肳��܂��B
%
% ���̊֐����g���āAaxes��text�I�u�W�F�N�g�̕������ҏW���邽�߂ɂ́A
% axes��text�I�u�W�F�N�g�� buttondownfcn �� 'edtext' �ɐݒ肵�Ă��������B
% �������ҏW������ŃR�[���o�b�N�����s�������ꍇ�́A�R�[���o�b�N�������
% axes��text�I�u�W�F�N�g�� 'UserData' ���ɐݒ肵�Ă��������B
%
% EDTEXT �́Agcf���ŁA�^�O 'edtext' �������o�s�\��edit control��
% �g�p���܂��B���̂悤�ȃI�u�W�F�N�g��������Ȃ���΁A�쐬����܂��B
%
% EDTEXT('hide') �́A�G�f�B�^�u���e�L�X�g�I�u�W�F�N�g��\�����܂���B
%
% ���:
% 
% ����2�̃R�}���h�́A�J�����g��figure���̂��ׂĂ�text�I�u�W�F�N�g
% (title, xlabel, ylabel) �� point-and-clock editing ���C���X�g�[�����܂��B
% 
%     set(findall(gcf,'type','text'),'buttondownfcn','edtext')
%     set(gcf,'windowbuttondownfcn','edtext(''hide'')')
%   
% �Q�l�F GCO, GCBO.


%  Author: T. Krauss, 10/94
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:07:55 $
