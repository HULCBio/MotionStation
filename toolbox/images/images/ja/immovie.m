% IMMOVIE    �}���`�t���[���C���f�b�N�X�t���C���[�W�̃��[�r�[���쐬
%
% MOV = IMMOVIE(X,MAP) r�́A�}���`�t���[���C���f�b�N�X�t���C���[�W X ��
% ���̃C���[�W���烀�[�r�[�̍\���z�� MOV ���o�͂��܂��B���[�r�[�z���
% �쐬���Ȃ���A�X�N���[����Ƀ��[�r�[�t���[����\�����邱�Ƃ��ł��܂��B
% MATLAB MOVIE �֐����g���āA���[�r�[��\�����邱�Ƃ��ł��܂��B
%
% MOV = IMMOVIE(RGB) �́A�}���`�t���[���g�D���[�J���[�C���[�W RGB �ɁA
% �C���[�W���烀�[�r�B�\���̔z�� MOV ���o�͂��܂��B
%
% ���[�r�[�\���z��Ɋւ���ڍׂɂ��ẮAGETFRAME �̃��t�@�����X�y�[�W
% ���Q�Ƃ��Ă��������B
%
% X �́A�傫�����������A�����J���[�}�b�v MAP ���g���������̃C���f�b�N�X
% �t���C���[�W����\������Ă��܂��BX �́AM x N x 1 x K �̔z��ł��B
% �����ŁAK �̓C���[�W�̐��ł��B
%
% RGB �́A�����T�C�Y�̕����̃g�D���[�J���[�C���[�W����\������Ă��܂��B
% RGB �́AM x N x 3 x K �z��ŁAK �́A�C���[�W�̐��ł��B
%
% �N���X�T�|�[�g
% -------------
% �C���f�b�N�X�t���C���[�W�́Auint8�Auint16�Adouble�A�܂��� logical 
% �ł��B�g�D���[�J���[�C���[�W�́Auint8�Auint16�A�܂��� double �ł��B
% MOV �́AMATLAB�̃��[�r�[�\���̂ł��B
%
% ���
% ------
%        load mri
%        mov = immovie(D,map);
%        movie(mov,3)
%
% ����
% ----
%   MATLAB �֐� AVIFILE ���g���āA�C���[�W���烀�[�r�[���쐬���܂��B��
%   ���Ċ��ɑ��݂��Ă��郀�[�r�[���֐� MOVIE2AVI ���g���āAAVI �t�@�C
%   ����ϊ����܂��B
%
% �Q�l�FAVIFILE, GETFRAME, MONTAGE, MOVIE, MOVIE2AVI



%   Copyright 1993-2002 The MathWorks, Inc.  
