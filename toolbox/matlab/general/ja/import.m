% IMPORT   �J�����g��Java�p�b�P�[�W�ƃN���X�C���|�[�g���X�g�̒ǉ�
% 
% IMPORT PACKAGE_NAME.* �́A�w�肵���p�b�P�[�W�����J�����g�̃C���|�[�g
% ���X�g�ɉ����܂��B
% 
% IMPORT PACKAGE1.* PACKAGE2.* ...�́A�����̃p�b�P�[�W����t������̂�
% �g���܂��B
% 
% IMPORT CLASSNAME �́A���S�ɏ����̍�����Java �N���X�����C���|�[�g���X�g
% �ɉ����܂��B
% 
% IMPORT CLASSNAME1 CLASSNAME2 ... �́A�����̊��S�ɏ����̍�����Java�N��
% �X�����C���|�[�g���X�g�ɉ����܂��B
% 
% �p�b�P�[�W����N���X����������Ɋi�[�����ꍇ�́AIMPORT(S) �̂悤
% �� IMPORT �̊֐��`�����g���܂��B
% 
% L = IMPORT(...)�́AIMPORT�̏I�����ɁAIMPORT�����݂���Ƃ��A�J�����g��
% �C���|�[�g���X�g�̓��e�𕶎��̃Z���z��Ƃ��Ă��̒ʂ�ɏo�͂��܂��B
% ���͂�^���Ȃ�L = IMPORT�ł́A�J�����g�̃C���|�[�g���X�g�𓾂܂��B
% �����ł́A�t���������̂͂���܂���B
% 
% IMPORT�́A�g�p�������̂̒��ŁA�֐��̃C���|�[�g���X�g�݂̂ɉe����^��
% �܂��B�R�}���h�v�����v�g�Ŏg����x�[�X�C���|�[�g���X�g�����݂��܂��B
% IMPORT���X�N���v�g���Ŏg����ƁA�X�N���v�g��ǂݍ��ފ֐��̃C���|�[
% �g���X�g�ɉe����^���邩�A�܂��́A�X�N���v�g���R�}���h�v�����v�g�����
% �ݍ��܂ꂽ�ꍇ�́A�x�[�X�C���|�[�g���X�g�ɉe����^���܂��B
% 
% CLEAR IMPORT�́A�x�[�X�C���|�[�g���X�g���N���A���܂��B�֐��̃C���|�[�g
% ���X�g�́A�N���A����܂���B
% 
% ���F
%       import java.awt.*
%       import java.util.Enumeration java.lang.*
%       f = Frame;               % java.awt.Frame �I�u�W�F�N�g���쐬
%       s = String('hello');     % java.lang.String �I�u�W�F�N�g���쐬
%       methods Enumeration      % java.util.Enumeration ���\�b�h�̃��X
%                                % �g�\��
%
% �f�[�^�̃C���|�[�g
% ��X�̃^�C�v�̃f�[�^�� MATLAB �ɃC���|�[�g�ł��܂��B���̒��ɂ́A
% MAT-�t�@�C���A�e�L�X�g�t�@�C���A�o�C�i���t�@�C���AHDF �t�@�C�����܂�
% ��Ă��܂��BMAT-�t�@�C������f�[�^���C���|�[�g����ɂ́A�֐� LOAD ��
% �g���܂��B
% MATLAB �̃C���|�[�g�֐���GUI �Ŏg�p���邽�߂ɂ́AUIIMPORT ���^�C�v��
% �܂��B
%
% �f�[�^�̃C���|�[�g�̏ڍׂɂ��ẮA���̃w�b�_�̉��� MATLAB�w���v 
% �u���E�U�̃f�[�^�̃C���|�[�g�ƃG�N�X�|�[�g���Q�Ƃ��Ă��������B
%
%       MATLAB -> MATLAB�J����
%       MATLAB -> External Interfaces/API
% 
% �Q�l�FCLEAR, LOAD


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2004/04/28 01:53:07 $
%   Built-in function.

