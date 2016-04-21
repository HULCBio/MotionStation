% LANDSATDEMO �����h�T�b�g����J���[�������s���f��
%
% ���̃f���́ALandsat Thematic Mapper �f�[�^����J���[�������쐬�����
% �̂ł��B�����h�T�b�g�̃f�[�^�́A7�̃X�y�N�g���ш悩��\������A�e��
% �悪�A�Ώۗ̈�̒��̈قȂ�������C���[�W�����ĕ\�킵�Ă��܂��B�f�[�^�́A
% 512 x 512 x 7 �̔z��ɓǂݍ��܂�܂��B�J���[�������쐬���邽�߁A�ԁA��
% �̋��x�Ɋ��蓖�Ă邱�Ƃɂ��ARGB �C���[�W���쐬���܂��B
%
% ���W�I�{�^�����N���b�N���邱�ƂŁA�������̋��ʂ̃J���[��������������
% ���ł��܂��B�����ʂ̒��̐����́A�X�y�N�g���ш��ԁA�΁A�Ɏˉe������
% �̂ł��B�z�� �3 2 1 ]�́A�ш� 3 �́A�Ԃ̋��x�Ƃ��Ď�����A�ш�2�͗΁A��
% ��1�͐̋��x�Ƃ��Ď�����܂��B
%
% "True Color [3 2 1]" - ��s�@���猩�������
%
%   "Near Infrared [4 3 2]" - �A����ԁA�����Â��F�ŕ\��
%
%   "Shortwave Infrared [7 4 3]" - ���x�ɂ��ω�
%   
% "Custom Composite" ���N���b�N���āA�|�b�v�A�b�v���j���[��ύX���āA�ԁA
% �΁A�̃��[�U���g�̍������쐬���܂��B
%
% "Single Band Intensity" ���N���b�N���āA�O���[���x�C���[�W�Ƃ��āA�e��
% ������܂��B
%
% �`�F�b�N�{�b�N�X����N���b�N���āA"Saturation Stretch" �ɐ؂�ւ��܂��B
% �قƂ�ǂ̃����h�T�b�g�f�[�^�Z�b�g�ɑ΂��āA�ʓx�̈������΂��́A�d�v��
% �Ȃ�܂��B�ʓx�̈������΂���؂�ւ����ꍇ�A�f���́A�e�ш�̃s�N�Z����
% 2% ���N���b�v���A�C���[�W��\������O�ɁA���`�̃R���g���X�g�̈�������
% �����s���܂��B
%
% �f�������s����ԁA�C���[�W�ƃf�[�^�����[�N�X�y�[�X�ɔz�u���邱�Ƃ��ł�
% �܂��B
% 
% IMG = LANDSATDEMO('getimage') �́A�C���[�W�����[�N�X�y�[�X�ɓǂݍ��݂�
% ���B
% 
% DATA = LANDSATDEMO('getdata') �́A���[�N�X�y�[�X����7�ш悷�ׂĂ�ǂݍ�
% �݂܂��B
%
% ����
% ----
% �����h�T�b�g��TM �f�[�^�Z�b�g�̎g�p�́A�R�����h�B�A�f���o�[�� Space 
% Imaging �Ђ��狖���󂯂Ă��܂��B
%
% ���
% -------
%       data = landsatdemo('getdata');
%       truecolor = data(:,:,[3 2 1]);
%       stretched = imadjust(truecolor,stretchlim(truecolor),[]); 
%       imshow(truecolor), figure, imshow(stretched)
%
% �Q�l�F IMADJUST, STRETCHLIM.



%   Copyright 1993-2002 The MathWorks, Inc.  
