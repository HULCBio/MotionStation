% GUIHANDLES   �n���h���̍\���̂��o��
% 
% HANDLES = GUIHANDLES(H) �́Afieldnames �Ƃ��Ă��̃^�O���g���āAfigure
% ���̃I�u�W�F�N�g�̃n���h�����܂ލ\���̂�߂��܂��B�I�u�W�F�N�g�́A����
% �^�O����̏ꍇ�A�܂��́A�������ϐ����łȂ��ꍇ�́A�폜����܂��B
% �I�u�W�F�N�g�̒��ɓ��������^�O�������̂�����ꍇ�́A�\���̂̃t�B�[���h
% �́A�n���h���̃x�N�g�����܂�ł��܂��B�B�ꂽ�n���h�������I�u�W�F�N�g�́A
% �\���̂̒��Ɋ܂܂�Ă��܂��B
%
% H �́Afigure�����ʂ���n���h���ŁA����́Afigure���g�܂���figure����
% �܂܂��C�ӂ̃I�u�W�F�N�g�ɂȂ�܂��B
%
% HANDLES = GUIHANDLES �́A�J�����gfigure�ɑ΂���n���h���̍\���̂�
% �o�͂��܂��B
%
% ���F
%
% �n���h�� F ������figure���쐬����A�v���P�[�V�������l���܂��B���̒��ɂ́A
% �X���C�_��ҏW�\�ȃe�L�X�g��uicontrol �̃^�O���A���ꂼ��A'valueSlider' 
% �� 'valueEdit' �Ŋ܂܂�Ă��܂��B�A�v���P�[�V������ M-�t�@�C������̈ȉ�
% �̕����́AGUIHANDLES �ɂ��o�͂����n���h�����܂ލ\���̂ɃA�N�Z�X
% ���邽�߂� GUIDATA �̗��p�������܂��B
%
%   ... GUI �Z�b�g�A�b�v�R�[�h�̈ꕔ��...
%
%   f = figure;
%   uicontrol('Style','slider','Tag','valueSlider', ...);
%   uicontrol('Style','edit','Tag','valueEdit',...);
%
%   ... �X���C�_�̃R�[���o�b�N�̈ꕔ��...
%
%   handles = guihandles(gcbo); % �n���h���̍\���̂��쐬
%   set(handles.valueEdit, 'string',...
%       num2str(get(handles.valueSlider, 'value')));
%
%   ... �G�f�B�b�g�R�[���o�b�N�̈ꕔ��...
%
%   handles = guihandles(gcbo);
%   val = str2double(get(handles.valueEdit,'String'));
%   if isnumeric(val) & length(val)==1 & ...
%      val >= get(handles.valueSlider, 'Min') & ...
%      val <= get(handles.valueSlider, 'Max')
%     % �G�f�B�b�g�l�� OK �̏ꍇ�̓X���C�_�l���X�V
%     set(handles.valueSlider, 'Value', val);
%   else
%     % �G�f�B�b�g����s���ȕ�������폜���A�X���C�_�̃J�����g�l�Œu��
%     set(handles.valueEdit, 'String',...
%       num2str(get(handles.valueSlider, 'Value')));
%   end
%
% ���̗��ł́A�R�[���o�b�N�����s����x�ɁA�n���h���̍\���̂��쐬����
% �܂��B�\���̂���x�����쐬����A���̌�̎g�p�ɑ΂��Ă̓L���b�V�������
% ���ɂ��ẮAGUIDATA �w���v���Q�Ƃ��Ă��������B
%
% �Q�l�F GUIDATA, GUIDE, OPENFIG.


%   Damian T. Packer 6-8-2000
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 02:08:11 $
