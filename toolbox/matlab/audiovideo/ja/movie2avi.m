% MOVIE2AVI(MOV,FILENAME)  MATLAB���[�r�[����AVI���[�r�[���쐬���܂�
% 
% MOVIE2AVI(MOV,FILENAME) �́AMATLAB���[�r�[ MOV ����AVI���[�r�[��
% �쐬���܂��B
%
% MOVIE2AVI(MOV,FILENAME,PARAM,VALUE,PARAM,VALUE...) �́A�w�肵���p
% �����[�^�ݒ���g���āAMATLAB���[�r�[ MOV ����AVI���[�r�[���쐬���܂��B
%
% �g�p�\�ȃp�����[�^�F
%
%   FPS         - AVI ���[�r�[�ɐݒ肷��P�ʎ��Ԃ�����̃t���[�����B�f�t
%                 �H���g�́A15 fps�ł��B
%
%   COMPRESSION - �g�p���鈳�k�@������������BUNIX�ł́A���̒l��
% 		  'None' �ł��BWindows�p�Ɏg�p�\�ȃp�����[�^�́A'Indeo3', 
%                 'Indeo5', 'Cinepak', 'MSVC', 'None' �̂����ꂩ�ł��B�J
%                 �X�^�}�C�Y�������k�@���g�p����ɂ́Acodec�h�L�������e�[�V
%                 �����Ŏw�肷��4�̃L�����N�^�R�[�h��ݒ肵�܂��B�w��
%                 �����J�X�^�}�C�Y���k���@��������Ȃ��ꍇ�́A�G���[��
%                 �����܂��B�f�t�H���g�́AWindows�ł� 'Indeo3'�AUNIX�ł� 
%                 'None' �ł��B
%
%   QUALITY      - 0����100�̊Ԃ̐����B���̃p�����[�^�́A�񈳏k���[�r�[
%                  �ɂ͉e�����܂���B�������傫���قǁA�掿���ǂ�(���k
%                  �ɂ��C���[�W�̗򉻂����Ȃ�)���Ƃ��Ӗ����܂����A����
%                  �̃t�@�C���T�C�Y�͑傫���Ȃ�܂��B�f�t�H���g�́A75�ł��B
%                 
%   KEYFRAME     - �e���|�����̈��k���@���T�|�[�g���邽�߂̒P�ʎ���
%                  ������̃L�[�t���[�����ł��B�f�t�H���g�́A���b2�L�[�t
%                  ���[���ł��B
%
%   COLORMAP     - �C���f�b�N�X�t��AVI���[�r�[�ɑ΂��āA�g�p����J���[
%                  �}�b�v���`���� M �s 3 ��̍s��BM �́A256(Indeo��
%                  �k�@���g�p����ꍇ��236)���傫���ݒ肵�Ă͂�����
%                  ����B�f�t�H���g�̃J���[�}�b�v�͂���܂���B 
%
%   VIDEONAME    - �r�f�I�X�g���[���ɑ΂���L�q�I�Ȗ��O�B���̃p�����[�^
%                  �́A64�L�����N�^�����Z���K�v������܂��B�f�t�H���g
%                  �̖��O�́Afilename �ł��B
%
% �Q�l�FAVIFILE, AVIREAD, AVIINFO, MOVIE.

%   Copyright 1984-2004 The MathWorks, Inc.

