% GUIDATA    �A�v���P�[�V�����f�[�^���X�g�A���A�ǂݍ��݂܂��B
%
% GUIDATA(H, DATA) �́Afigure�̃A�v���P�[�V�����f�[�^���̎w�肵���f�[�^
% ��ۑ����܂��B
%
% H �́Afigure�����ʂ���n���h���ŁAfigure���g�A�܂���figure���Ɋ܂܂��
% �C�ӂ̃I�u�W�F�N�g�ł��\���܂���B
%
% DATA �́A��œǂݍ��ނ��߂̕ۑ�����]����C�ӂ̃A�v���P�[�V������\��
% ���܂��B
%
% DATA = GUIDATA(H) �́A�O�ɃX�g�A�����f�[�^���o�͂��A�O�ɃX�g�A��������
% ���Ȃ��ꍇ�́A��s����o�͂��܂��B
%
% GUIDATA �́Afigure�̃A�v���P�[�V�����f�[�^�ւ֗̕��ȃC���^�t�F�[�X������
% �A�v���P�[�V������p�ӂ��Ă��܂��B���[�U�́Afigure�̃n���h����T��������
% �R�[���o�b�N�T�u�֐�����f�[�^���A�N�Z�X�ł��܂��B���[�U�̃\�[�X�R�[�h��
% ���A�A�v���P�[�V�����f�[�^�p�Ƀn�[�h�R�[�h���ꂽ�v���p�e�B�����쐬��
% ����A�ێ����邱�Ƃ�������邱�Ƃ��ł��܂��BGUIDATA �́AGUIHANDLES ��
% ���Ɏg�p����ƁA���ɗL���ł��BGUIHANDLES �́A�^�O�ɂ�胊�X�g���ꂽGUI 
% �̒��̂��ׂĂ̗v�f�̃n���h�����܂ލ\���̂ł��B
%
% ���F
%
% �n���h�� F ������figure���쐬����A�v���P�[�V�������l���܂��B���̒��ɂ́A
% �̃^�O���A���ꂼ��A 'valueSlider' �� 'valueEdit' �ł���A�X���C�_��
% �ҏW�\�ȃe�L�X�g��uicontrol���܂܂�Ă��܂��B�A�v���P�[�V������ 
% M-�t�@�C������̈ȉ��̕����́AGUIHANDLES �ɂ��o�͂����n���h����
% �܂ލ\���̂ɃA�N�Z�X���邽�߂� GUIDATA �̗��p�������܂��B����Ƌ��ɁA
% �����̒��ɂ́A�������ƃR�[���o�b�N�̊ԂɃA�v���P�[�V�����ŗL�ȃn��
% �h�����܂�ł��܂��B
%
%   ... GUI�Z�b�g�A�b�v�̈ꕔ��...
%
%   f = openfig('mygui.fig');
%   data = guihandles(f); % �n���h�����܂܂��ď�����
%   data.errorString = 'Total number of mistakes: ';
%   data.numberOfErrors = 0;
%   guidata(f, data);  % �\���̂��X�g�A
%
%   ... �X���C�_�̃R�[���o�b�N�̈ꕔ��...
%
%   data = guidata(gcbo); % �\���̂��擾���āA�n���h�����g�p
%   set(data.valueEdit, 'String',...
%       num2str(get(data.valueSlider, 'Value')));
%
%   ... �G�f�B�b�g�̃R�[���o�b�N�̈ꕔ��...
%
%   data = guidata(gcbo); % �n���h�����K�v�A�G���[��񂪕K�v�ȏꍇ������
%   val = str2double(get(data.valueEdit,'String'));
%   if isnumeric(val) & length(val)==1 & ...
%      val >= get(data.valueSlider, 'Min') & ...
%      val <= get(data.valueSlider, 'Max')
%     set(data.valueSlider, 'Value', val);
%   else
%     % �G���[�񐔂��J�E���g���ĕ\��
%     data.numberOfErrors = data.numberOfErrors + 1;
%     set(handles.valueEdit, 'String',...
%      [ data.errorString, num2str(data.numberOfErrors) ]);
%     guidata(gcbo, data); % �ύX���X�g�A
%   end
%
% GUIDE �́A���͈����Ƃ��Ď����I�Ƀn���h���̍\���̂��n�����R�[���o�b�N
% �֐����쐬���邱�Ƃɒ��ӂ��Ă��������B����́AGUIDE �𗘗p���ď������
% �R�[���o�b�N�ŁA"data = guidata(gcbo);"���Ăяo������K�v���Ȃ��Ȃ�܂��B
%
% �Q�l�F GUIHANDLES, GUIDE, OPENFIG, GETAPPDATA, SETAPPDATA.


%   Damian T. Packer 6-8-2000
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 02:08:08 $
