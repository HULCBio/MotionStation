% UIPUTFILE   �t�@�C����W���ɃZ�[�u���邽�߂̃_�C�A���O�{�b�N�X
%
% [FILENAME, PATHNAME, FILTERINDEX] = UIPUTFILE(FILTERSPEC, TITLE) �́A
% ���[�U�����͂ł���_�C�A���O�{�b�N�X��\�����A�t�@�C�����ƃp�X��\��
% ��������ƑI�����ꂽ�t�B���^�̃C���f�b�N�X��߂��܂��B�L���ȃt�@�C����
% ���w�肳��Ă���ꍇ�́A����ɖ߂�܂��B�����̃t�@�C�������w��A���邢��
% �I�����ꂽ�ꍇ�́A���[�j���O���b�Z�[�W���\������܂��B���[�U�́AYes ��
% �I�����ăt�@�C�����𗘗p���邩�A���邢�́ANo��I�����ĕʂ̃t�@�C������
% �I�����邽�߂Ƀ_�C�A���O�ɖ߂邱�Ƃ��ł��܂��B
%
% �p�����[�^ FILTERSPEC �́A�_�C�A���O�{�b�N�X�̒��̃t�@�C���̏����\����
% ���肷����̂ł��B���Ƃ��΁A'*.m' �́A���ׂĂ� MATLAB M-�t�@�C����\��
% ���܂��BFILTERSPEC ���Z���z��̏ꍇ�A�ŏ��̗�́A�g���q�̈ꗗ���A2��
% �ڂ́A�L�q�̈ꗗ�Ƃ��Ďg���܂��B
%
% FILTERSPEC ��������A�܂��̓Z���z��̏ꍇ�A"All files (*.*)" �����X�g
% �ɕt������܂��B
%
% FILTERSPEC ����̏ꍇ�A�t�@�C���^�C�v�̃f�t�H���g���X�g���g���܂��B
%   
% FILTERSPEC ���t�@�C�����̏ꍇ�A�f�t�H���g�̃t�@�C�����ɂȂ�A�t�@�C��
% �̊g���q���A�f�t�H���g�̃t�B���^�Ƃ��āA�g���܂��B
%
% �p�����[�^ TITLE �́A�_�C�A���O�{�b�N�X�̃^�C�g�����܂ޕ�����ł��B
%
% �o�͕ϐ� FILENAME �́A�_�C�A���O�{�b�N�X�̒��őI�����ꂽ�t�@�C������
% �܂ޕ�����ł��B���[�U���ACancel �{�^�����������ꍇ�A0 �ɐݒ肳��܂��B
%
% �o�͕ϐ� PATH �́A�_�C�A���O�{�b�N�X�̒��ɑI�����ꂽ�p�X�����܂ޕ�����
% �ł��B���[�U���ACancel �{�^�����������ꍇ�A0 �ɐݒ肳��܂��B
%
% �o�͕ϐ� FILTERINDEX �́A�_�C�A���O�{�b�N�X�őI�����ꂽ�t�@�C����
% �C���f�b�N�X��Ԃ��܂��B�C���f�b�N�X��1�Ŏn�܂�܂��B���[�U�� Cancel 
% �{�^�����������ꍇ�A0 �ɐݒ肳��܂��B
%
% [FILENAME, PATHNAME, FILTERINDEX] = UIPUTFILE(FILTERSPEC, TITLE, FILE)
% �\������Ă���g���q�̑���Ɏw�肳�ꂽ FILE ���g���܂��B
%
% [FILENAME, PATHNAME] = UIGETFILE(..., 'Location', [X Y])�́A�_�C�A
% ���O�{�b�N�X���X�N���[���ʒu[X,Y]�Ƀs�N�Z���P�ʂŒu���܂��B���̃I�v
% �V�����́AUNIX�v���b�g�t�H�[���ł̂݃T�|�[�g����܂��B
%   
% [FILENAME, PATHNAME] = UIGETFILE(..., X, Y)�́A�_�C�A���O�{�b�N�X��
% �X�N���[���ʒu[X,Y]�Ƀs�N�Z���P�ʂŒu���܂��B���̃I�v�V�����́AUNIX
% �v���b�g�t�H�[���ł̂݃T�|�[�g����܂��B���̃V���^�b�N�X�́A�p�~�����
% ����폜�����\��ł��B���̃V���^�b�N�X�����ɗ��p���Ă��������B
%     [FILENAME, PATHNAME] = UIGETFILE(..., 'Location', [X Y])
%
% ���F
%
%   [filename, pathname] = uiputfile('matlab.mat', 'Save Workspace as');
%
%   [filename, pathname] = uiputfile('*.mat', 'Save Workspace as');
%
%   [filename, pathname] = uiputfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)';
%       '*.m',  'M-files (*.m)'; ...
%       '*.fig','Figures (*.fig)'; ...
%       '*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Save as');
%
%   [filename, pathname, filterindex] = uiputfile( ...
%      {'*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Save as', 'Untitled.mat');
%
% ��؂�q�̂Ȃ������̊g���q�́A�Z�~�R�����ŕ������Ȃ���΂����Ȃ�����
% �ɒ��ӂ��Ă��������B
%
%   [filename, pathname] = uiputfile( ...
%      {'*.m';'*.mdl';'*.mat';'*.*'}, ...
%       'Save as');
%
% ���̂悤��1�̋�؂�q�ŕ����̊g���q��\�����Ƃ��ł��܂��B
%
%   [filename, pathname] = uiputfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)'; ...
%       '*.*',                   'All Files (*.*)'}, ...
%       'Save as');
%
% ���̃R�[�h�́A���[�U���_�C�A���O�̃L�����Z�����������ꍇ�Ƀ`�F�b�N
% ���܂��B
%
%   [filename, pathname] = uiputfile('*.m', 'Pick an M-file');
%   if isequal(filename,0) | isequal(pathname,0)
%      disp('User pressed cancel')
%   else
%      disp(['User selected ', fullfile(pathname, filename)])
%   end
%
%
% �Q�l�FUIGETFILE, UIGETDIR.


%   Copyright 1984-2002 The MathWorks, Inc. 
