% UISETFONT   �t�H���g�I���_�C�A���O�{�b�N�X
% 
% S = UISETFONT(FIN�A'dialogTitle') �́A���[�U�����͂��邽�߂̃_�C�A���O
% �{�b�N�X��\�����A���͂����O���t�B�b�N�X�I�u�W�F�N�g�ɑI�������t�H���g
% ��K�p���܂��B
%
% �p�����[�^�́A�I�v�V�����ŁA�C�ӂ̏����Ŏw��ł��܂��B
%
% �p�����[�^FIN���g�p�����ƁAtext�܂���uicontrol,axes�I�u�W�F�N�g��
% �����ꂩ�̃n���h���ԍ����w�肷�邩�A�܂��́A�t�H���g�\����ݒ肵�Ȃ����
% �Ȃ�܂���B
%
% FIN ���I�u�W�F�N�g�̃n���h���̏ꍇ�A���̃I�u�W�F�N�g�ɑ�������t�H���g
% �v���p�e�B�́A�t�H���g�_�C�A���O�{�b�N�X�����������邽�߂Ɏg���܂��B
% 
% FIN ���\���̂̏ꍇ�A���̃����o�[�́AFontName,FontUnits,FontSize,
% FontWeight,FontAngle �̃T�u�Z�b�g�ł��B�����āA�t�H���g�v���p�e�B������
% �I�u�W�F�N�g�ɓK�؂Ȓl��ݒ肵�Ȃ���΂Ȃ�܂���B
%
% �p�����[�^ 'dialogTitle' ���g�p�����ꍇ�A����̓_�C�A���O�{�b�N�X��
% �^�C�g�����܂ޕ�����ł��B
%
% �o�� S �́A�\���̂ł��B�\���� S�́A�����o�Ƃ��ăt�H���g�v���p�e�B����
% �o�͂��܂��B
% �����o�[�́AFontName,FontUnits,FontSize,FontWeight,FontAngle �ł��B
%
% ���[�U���_�C�A���O�{�b�N�X����Cancel�{�^������������A�G���[����������
% �ƁA�o�͒l�́A0�ɐݒ肳��܂��B
%
% ���:
%         Text1 = uicontrol('style','text','string','XxYyZz');
%         Text2 = uicontrol('style','text','string','AxBbCc',...
%                 'position', [200 20 60 20]);
%         s = uisetfont(Text1, 'Update Font');
%         if isstruct(s)           % �L�����Z���ɑ΂���`�F�b�N
%            set(Text2, s);
%         end
%
% �Q�l�FINSPECT, LISTFONTS, PROPEDIT, UISETFONT


%   Copyright 1984-2002 The MathWorks, Inc.
