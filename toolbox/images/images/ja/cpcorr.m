% CPCORR  ���ݑ��ւ��g���āA�R���g���[���|�C���g�̈ʒu�𒲐� 
% INPUT_POINTS = CPCORR(INPUT_POINTS_IN,BASE_POINTS_IN,INPUT,BASE) �́A
% ���K���������ݑ��ւ��g���āAINPUT_POINTS_IN �� BASE_POINTS_IN �Ɏw��
% �������݂��̃R���g���[���|�C���g�̈ʒu�𒲐����܂��B
%
% INPUT_POINTS_IN �́A���̓C���[�W���̃R���g���[���|�C���g�̍��W���܂� 
% M �s 2��� double �̍s��ł��BBASE_POINTS_IN �́A�x�[�X�C���[�W���̃R
% ���g���[���|�C���g�̍��W���܂� M �s 2��� double �̍s��ł��B
%
% CPCORR �́AINPUT_POINTS_IN �Ɠ����傫���� double �̍s�� INPUT_POINTS 
% �ɒ��������R���g���[���|�C���g���o�͂��܂��BCPCORR ���A�R���g���[���|
% �C���g�̑g�ő��ւ����݂��Ȃ��ꍇ�AINPUT_POINTS �́A���̑g�ɑ΂��āA
% INPUT_POINTS_IN �Ɠ������W���܂݂܂��B
%
% CPCORR �́A4�s�N�Z���܂ŁA�R���g���[���|�C���g�̈ʒu���ړ����܂��B����
% ���ꂽ���W�́A�s�N�Z����1/10�̑傫���̐��x�������ACPCORR �́A�C���[�W
% ���e�Ƒe���R���g���[���|�C���g�I������T�u�s�N�Z�����x�𓾂�悤�ɐ݌v
% ����Ă��܂��B
%
% INPUT �C���[�W�� BASE �C���[�W�́A�����I�ɂȂ�ɂ́ACPCORR �Ɠ����X�P
% �[���������Ă���K�v������܂��B
%
% CPCORR �́A���̂����ꂩ���N����ꍇ�A�|�C���g�𒲐����邱�Ƃ��ł���
% ����B
%     - �|�C���g���A�C���[�W�̃G�b�W�ɔ��ɋ߂��ꍇ
%     - Inf�A�܂��́ANaN ���܂ރ|�C���g�̉��̃C���[�W�̗̈�
%     - ���̓C���[�W�̒��̓_�̉��̗̈悪�A�[���̕W���΍��������Ă���
%     - �_�̉��̃C���[�W�̗̈�̑��ւ��Ⴂ
%
% �N���X�T�|�[�g
% -------------
% �C���[�W�́A�N���X logical, uint8, uint16, �܂��́Adouble �ŁA�L���l
% ���܂�ł���K�v������܂��B���͂̃R���g���[���|�C���g�̑g�́A�N���X
% double �ł��B
%
% ���
% --------
% ���̗��́ACPCORR ���g���āA�C���[�W���ɑI�������R���g���[���|�C���g
% �ׂ̍����`���[�j���O��������̂ł��BINPUT_POINTS �s��� INPUT_POINTS_ADJ
% �̒l�̒��̈Ⴂ�ɒ��ӂ��Ă��������B
%
%       input = imread('lily.tif');
%       base = imread('flowers.tif');
%       input_points = [127 93; 74 59];
%       base_points = [323 195; 269 161];
%       input_points_adj = cpcorr(input_points,base_points,...
%                                 input(:,:,1),base(:,:,1))
%
% �Q�l�FCP2TFORM, CPSELECT, NORMXCORR2, IMTRANSFORM.



%   Copyright 1993-2002 The MathWorks, Inc.

