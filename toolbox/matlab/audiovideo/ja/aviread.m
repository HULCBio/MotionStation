% AVIREAD     AVI �t�@�C���̓ǂݍ��� 
% MOV = AVIREAD(FILENAME) �́AMATLAB���[�r�[�\���� MOV ����
% AVI ���[�r�[ FILENAME ��ǂݍ��݂܂��BFILENAME �Ɋg���q���܂܂�
% �Ă��Ȃ��ꍇ�́A'.avi' ���g���܂��BMOV ��2�̃t�B�[���h�A"cdata"��
% "colormap"�������܂��B�t���[�����g�D���[�J���[�C���[�W�ł���ꍇ�́A
% MOV.cdata �� Height-Width-3 �̑傫���ŁAMOV.colormap �͋�ɂȂ��
% ���B�t���[�����C���f�b�N�X�t���C���[�W�̏ꍇ�́AMOV.cdata �̃t�B�[���h
% �� Height �s Width ��̑傫���ŁAMOV.colormap �� M �s 3 ��̑傫����
% ���BUNIX�̏ꍇ�́AFILENAME �͔񈳏k��AVI�t�@�C���łȂ���΂Ȃ��
% ����B
%  
% MOV = AVIREAD(...,INDEX) �́AINDEX �Ŏw�肳�ꂽ�t���[���݂̂�ǂ�
% ���݂܂��BINDEX �́A�r�f�I�X�g���[�����̃C���f�b�N�X�z��A�܂���1��
% �C���f�b�N�X�̂����ꂩ�ł��B�����ŁA�ŏ��̃t���[���̃C���f�b�N�X��1�ł��B
%
% �T�|�[�g����Ă���t���[���^�C�v�́A8 �r�b�g (�C���f�b�N�X�t���A�܂��́A
% �O���[�X�P�[��)�A16 �r�b�g�O���[�X�P�[���A�܂��́A 24 �r�b�g 
% (�g�D���[�J���[) �t���[���ł��B
%
% �Q�l�FAVIINFO, AVIFILE.

% $Revision: 1.1.6.3 $ $Date: 2004/04/28 01:45:09 $
%   Copyright 1984-2001 The MathWorks, Inc.
