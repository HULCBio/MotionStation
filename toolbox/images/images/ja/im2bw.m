% IM2BW    �X���b�V���z�[���h�@���g���āA�C���[�W���o�C�i���C���[�W�ɕ�
%          ��
% IM2BW �́A�C���f�b�N�X�t���C���[�W�A���x�C���[�W�ARGB �C���[�W�̂�
% ���ꂩ����o�C�i���C���[�W���쐬���܂��B������s�����߂ɁA���̓C
% ���[�W�� (���ɁA���x�C���[�W�ɂȂ��Ă��Ȃ��ꍇ)�O���[�X�P�[������
% �ɕϊ����āA���̃O���[�X�P�[���C���[�W���X���b�V���z�[���h�@�ɂ��
% �o�C�i���ɕϊ����܂��B�o�̓o�C�i���C���[�W BW �́A���̓C���[�W�� 
% LEVEL �����̋P�x�̃s�N�Z�������ׂ�0�ɁA���̂��ׂẴs�N�Z����1�ɂ�
% �܂�(���̓C���[�W�̃N���X�Ɋւ�炸�ALEVEL ��[0,1]�͈̔͂Őݒ肳��
% �Ă��邱�Ƃɒ��ӂ��Ă�������)�B
%  
% BW = IM2BW(I,LEVEL) �́A���x�C���[�W I �������ɕϊ����܂��B
%
% BW = IM2BW(X,MAP,LEVEL) �́A�J���[�}�b�v MAP �����C���f�b�N�X�t
% ���C���[�W X �������C���[�W�ɕϊ����܂��B
%
% BW = IM2BW(RGB,LEVEL) �́ARGB �C���[�W RGB �������C���[�W�ɕϊ���
% �܂��B
%
% �֐� GRAYTHRESH �́A�����I�� LEVEL ���v�Z�������̂��g���邱�Ƃ�
% ���ӂ��Ă��������B
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W�́Auint8�Auint16�A�܂��́Adouble �̂�����̃N���X��
% �T�|�[�g���Ă��܂��B���̓C���[�W�́A��X�p�[�X�ł���K�v������܂��B
% �o�̓C���[�W BW �́A�N���X logical �ɂȂ�܂��B
%
% ���
% ----
%     load trees
%     BW = im2bw(X,map,0.4);
%     imshow(X,map), figure, imshow(BW)
%
% �Q�l : GRAYTHRESH, IND2GRAY, RGB2GRAY



%   Copyright 1993-2002 The MathWorks, Inc.  
