%LOADLIBRARY MATLAB �ɋ��L���C�u���������[�h���܂� 
% LOADLIBRARY(SHRLIB,HFILE) �́A�w�b�_�t�@�C�� HFILE �ɒ�`����A
% ���C�u���� SHRLIB�Ɍ�����֐��� MATLAB �Ƀ��[�h���܂��B
%
% LOADLIBRARY(SHRLIB,@MFILE) �́AMFILE �ɒ�`����A���C�u���� SHRLIB
% �Ɍ�����֐��� MATLAB �Ƀ��[�h���܂��BMFILE �́AMFILENAME 
% �I�v�V�������g�p���āALOADLIBRARY �ɂ��O�ɐ������ꂽMATLAB 
% M-�t�@�C���ł��B@MFILE �́A���� M-�t�@�C���ɑ΂���֐��n���h���ł��B
%
% LOADLIBRARY(SHRLIB,...,OPTIONS) �́A����OPTIONS��1�܂��͕�����
% �����C�u���� SHRLIB �����[�h���܂��B(�v���g�^�C�v�t�@�C�����g�p
% ���ă��[�h����ꍇ�AALIAS �I�v�V�����̂ݎg�p�ł��܂��B)
%
% OPTIONS:
%  'alias','newlibname'     ���C�u������ʂ̃��C�u�������Ń��[�h
%          ���邱�Ƃ��ł��܂�
%
%  'addheader','header'     �ǉ��̃w�b�_�t�@�C��'header'�ɒ�`         
%�@�@�@�@�@���ꂽ �֐������[�h���܂�
%�@�@�@�@�@�t�@�C���g���q�̂Ȃ��t�@�C�����Ƃ��ăw�b�_�p�����[�^��
%          �w�肵�Ă��������BMATLAB �́A�w�b�_�t�@�C�������邱�Ƃ�
%          �m���߂��A�K�v�łȂ��t�@�C���𖳎����܂��B
%
%          ���̃V���^�b�N�X���g�p���āA�K�v�ȕt���w�b�_�t�@�C��
%          ���w�肷�邱�Ƃ��ł��܂��B
%             LOADLIBRARY shrlib hfile ...
%                addheader addfile1 ...
%                addheader addfile2 ...          % �ȉ����l
%
%  'includepath','path'    �g�p�����p�X�ɒǉ��̃C���N���[�h�p�X��
%�@�@�@�@�@�ǉ����܂��B
%
%  'mfilename','filename'   �J�����g�f�B���N�g���Ƀv���g�^�C�v M-
%         �t�@�C�� filename.m �𐶐����A���C�u���������[�h���邽�߂�
%         ���̃t�@�C�����g�p���܂��BSuccessive LOADLIBRARY �R�}���h�́A
%    �@�@ ���C�u�����̃��[�h�Ńw�b�_�Ƃ��Ă��̃v���g�^�C�v�t�@�C����
%         �g�p���邽�߂Ɋ֐��n���h��@filename ���w�肷�邱�Ƃ��ł��܂��B
%    �@   ������g�p���āA���[�h�ߒ��̍���������ъȒP�����ł��܂��B
%
% �Q�l UNLOADLIBRARY, LIBISLOADED.

%   Copyright 2002 The MathWorks, Inc. 
