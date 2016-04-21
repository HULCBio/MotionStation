% CANDGEN   D-�œK���v��̂��߂̌��W���̍쐬
%
% XCAND = CANDGEN(NFACTORS,MODEL) �́A�v�� NFACTORS �� ���f�� MODEL ��
% �p���āA D-�œK�v��ɓK�؂Ȍ��W���𐶐����܂��B
% �o�͍s�� XCAND �́A�e�s��N�̌��_��1�̍��W��\���AN�~NFACTORS��
% �s��ł��BMODEL �́A���̕�����̂����ꂩ�ƂȂ�܂��B
%
%     'linear'          �萔�Ɛ��`�� (�f�t�H���g)
%     'interaction'     �萔�A���`�A�N���X�ς̍�
%     'quadratic'       ���ݍ�p����2�捀�̘a
%     'purequadratic'   �萔�A���`�A����сA2��̍�
%
% MODEL �́A�֐� X2FX �Ŏg�p�ł���v�f�\������Ȃ�s��̌^�ł��ݒ�ł��܂��B 
%
% [XCAND,FXCAND] = CANDGEN(NFACTORS,MODEL) �́A�v���l XCAND �̍s��ƍ��̒l
% FXCAND �̍s��̗������o�͂��܂��B��҂́AD-�œK���v��𐶐����邽�߂�
% CANDEXCH �ւ̓��͂ƂȂ邱�Ƃ��ł��܂��B
%
% ROWEXCH �́A�֐�CANDGEN���g�p���āA���W���������I�ɐ������A�֐�
% CANDEXCH���g�p���āAD-�œK���v����쐬���܂��B�f�t�H���g�̌��W����
% �C���������ꍇ�A�����̊֐���ʁX�ɁA�Ăяo�����Ƃ��]�܂��ꍇ��
% ���邩������܂���B
%
% �Q�l : ROWEXCH, CANDEXCH, X2FX.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:10:37 $
