%GETCALLINFO  �R�[�����ꂽ�֐��Ƃ��̍ŏ��̃R�[�����O���C�����o�͂��܂�
% STRUCT = GETCALLINFO(FILENAME,OPTION)
% �o�͍\���� STRUCT �́A���̌`�����Ƃ�܂��B
%      type:       [ script | function | subfunction ]
%      name:       �X�N���v�g���A�֐����A�܂��́A�T�u�֐���
%      firstline:  �X�N���v�g�A�֐��A�܂��́A�T�u�֐��̍ŏ��̍s
%      calls:      �X�N���v�g�A�֐��A�܂��́A�T�u�֐��ɂ��R�[��
%      calllines:  ��L�̃R�[�����s���郉�C��
%
% OPTION = [ 'file' | 'subfuns' | 'funlist' ]
% �f�t�H���g�ł́AOPTION �́A'subfuns' �ɐݒ肳��܂��B
%   
% OPTION = 'file' �́A�X�N���v�g�A�T�u�֐��̂Ȃ��֐��A�܂��́A�T�u�֐���
% ����֐��ł��邩�ǂ����Ɋւ�炸�A�t�@�C���S�̂�1�̍\���̂��o�͂��܂��B 
% �T�u�֐��̂���t�@�C���ɑ΂��āA�t�@�C���ɑ΂���R�[���́A�T�u�֐��ɂ��
% ���ׂĂ̊O���Ăяo�����܂݂܂��B 
%
% OPTION = 'subfuns' �́A�\���̂̔z����o�͂��܂��B�ŏ��̂��̂̓��C���֐���
% �΂�����̂ŁA�T�u�֐����ׂĂ������܂��B���̃I�v�V�����́A�X�N���v�g�� 
% 1�̊֐��̃t�@�C���ɑ΂���'file' �Ƃ��ē������ʂ��o�͂��܂��B
%
% OPTION = 'funlist' �́A 'subfuns' �I�v�V�����Ɏ����\���̂̔z����o�͂��܂����A% calls �� calllines �̏��͏o�͂��ꂸ�A�T�u�֐��Ƃ��̍ŏ��̃��C���̃��X�g
% �̂ݏo�͂���܂��B

%   Copyright 1984-2003, The MathWorks, Inc.
