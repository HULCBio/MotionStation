% UIGETFILE  �W���I�ȃI�[�v���t�@�C���̃_�C�A���O�{�b�N�X 
%
%  [FILENAME, PATHNAME, FILTERINDEX] = UIGETFILE(FILTERSPEC, TITLE) �́A
% ���[�U�����͂���_�C�A���O�{�b�N�X��\�����A�t�@�C�����ƃp�X��\��
% �������߂��܂��B�t�@�C�������݂���ꍇ�̂݁A������\�����ʂ��o�͂�
% ��܂��B���[�U�����݂��Ȃ��t�@�C����I������ƁA�G���[���b�Z�[�W��
% �\������A�R���g���[���̓_�C�A���O�{�b�N�X�ɕԂ���܂��B���̏ꍇ�A
% ���[�U�͑��̃t�@�C��������͂��邩�A�܂��́ACancel �{�^�����������Ƃ�
% �ł��܂��B
%
% �p�����[�^ FILTERSPEC �́A�_�C�A���O�{�b�N�X�̒��̃t�@�C���̏����\����
% ���肵�܂��B���Ƃ��΁A'*.m' �́A���ׂĂ� MATLAB M-�t�@�C����\�����܂��B
% FILTERSPEC ���Z���z��̏ꍇ�A�ŏ��̗�͊g���q�̈ꗗ��\�����A2�Ԗ�
% �̗�͓��e�̈ꗗ��\�����܂��B
%
% FILTERSPEC ��������A�܂��̓Z���z��̏ꍇ�́A"All files (*.*)" ��
% ���X�g�ɉ������܂��B
%
% FILTERSPEC ����̏ꍇ�́A�t�@�C���^�C�v�̃f�t�H���g���X�g���g���܂��B
%
% �p�����[�^ TITLE �́A�_�C�A���O�{�b�N�X�̃^�C�g�����܂ޕ�����ł��B
%
% �o�͕ϐ� FILENAME �́A�_�C�A���O�{�b�N�X�̒��ɑI�����ꂽ�t�@�C���̖�
% �O���܂ޕ�����ł��B���[�U��Cancel�{�^�����������ꍇ�A0�ɐݒ肳��܂��B
%
% �o�̓p�����[�^ PATHNAME �́A�_�C�A���O�{�b�N�X�̒��ɑI�������t�@�C
% ���̃p�X���܂ޕ�����ł��B���[�U��Cancel�{�^�����������ꍇ�A0�ɐݒ�
% ����܂��B
% 
% �o�͕ϐ�FILTERINDEX�́A�_�C�A���O�{�b�N�X�őI�������t�B���^�̃C���f�b�N
% �X���o�͂��܂��B�C���f�b�N�X�t���́A1����n�܂�܂��BCancel�������ƁA
% 0�ɐݒ肳��܂��B
%
% [FILENAME, PATHNAME, FILTERINDEX] = UIGETTFILE(FILTERSPEC, TITLE, FILE)
% �́A�\������Ă���g���q�̑���Ɏw�肳�ꂽ FILE ���g���܂��B
% 
% [FILENAME, PATHNAME] = UIGETFILE(..., 'Location', [X Y]) �́A�_�C�A
% ���O�{�b�N�X���X�N���[���ʒu[X,Y]�Ƀs�N�Z���P�ʂŒu���܂��B���̃I�v�V����
% �́AUNIX�v���b�g�t�H�[���ł̂݃T�|�[�g����܂��B
%   
% [FILENAME, PATHNAME] = UIGETFILE(..., 'MultiSelect', SELECTMODE)
% �́A�����t�@�C���̑I����UIGETFILE�_�C�A���O�ɑ΂��ĉ\���ǂ������w��
% ���܂��BSELECTMODE�̗L���Ȓl�́A'on' �����'off'�ł��B'MultiSelect' 
% �̒l��'on'�ɐݒ肳��Ă���ꍇ�́A�_�C�A���O�{�b�N�X�͕����t�@�C���̑I
% �����T�|�[�g���܂��B'MultiSelect' �́A�f�t�H���g�ł�'off' �ɐݒ肳��
% �܂��B
%
% �o�͕ϐ�FILENAME�́A�����t�@�C�������I������Ă���ꍇ�͕����񂩂��
% ��Z���z��ł��B�����łȂ��ꍇ�́A�I�����ꂽ�t�@�C������\�킷������ł��B
%   
% [FILENAME, PATHNAME] = UIGETFILE(..., X, Y) �́A�_�C�A���O�{�b�N�X��
% �X�N���[���ʒu[X,Y]�Ƀs�N�Z���P�ʂŒu���܂��B���̃I�v�V�����́AUNIX
% �v���b�g�t�H�[���ł̂݃T�|�[�g����܂��B���̃V���^�b�N�X�͔p�~�����
% ����A�폜�����\��ł��B�ȉ��̃V���^�b�N�X�����Ɏg�p���Ă��������B
%     [FILENAME, PATHNAME] = UIGETFILE(..., 'Location', [X Y])
%
% ���F
%
%   [filename, pathname] = uigetfile('*.m', 'Pick an M-file');
%
%   [filename, pathname] = uigetfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)';
%       '*.m',  'M-files (*.m)'; ...
%       '*.fig','Figures (*.fig)'; ...
%       '*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Pick a file');
%
%   [filename, pathname, filterindex] = uigetfile( ...
%      {'*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Pick a file', 'Untitled.mat');
%
% ��؂�q�̂Ȃ������̊g���q�́A�Z�~�R�����ŕ������Ȃ���΂����Ȃ�����
% �ɒ��ӂ��Ă��������B
%
%   [filename, pathname] = uigetfile( ...
%      {'*.m';'*.mdl';'*.mat';'*.*'}, ...
%       'Pick a file');
%
% ���̂悤��1�̋�؂�q�ŕ����̊g���q��\�����Ƃ��ł��܂��B
%
%   [filename, pathname] = uigetfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)'; ...
%       '*.*',                   'All Files (*.*)'}, ...
%       'Pick a file');
%
% ���̃R�[�h�́A���[�U���_�C�A���O�̃L�����Z�����������ꍇ�Ƀ`�F�b�N
% ���܂��B
%
%   [filename, pathname] = uigetfile('*.m', 'Pick an M-file');
%   if isequal(filename,0)|isequal(pathname,0)
%      disp('User pressed cancel')
%   else
%      disp(['User selected ', fullfile(pathname, filename)])
%   end
%
%
% �Q�l�FUIPUTFILE, UIGETDIR.


%   Copyright 1984-2002 The MathWorks, Inc. 
