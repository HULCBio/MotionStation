% LLOYDS Lloyd �A���S���Y�����g�p���āA�ʎq���p�����[�^���œK��
%
% [PARTITION, CODEBOOK] = LLOYDS(TRAINING_SET, INI_CODEBOOK) �́ALloyd 
% �A���S���Y�����g�p���āA�w�肵���g���[�j���O�x�N�g�� TRAINING_SET ��
% ��Â��āA�X�J���ʎq�� PARTITION �� CODEBOOK ���œK�����܂��B�ϐ� 
% TRANING_SET �̃f�[�^�́A�ʎq�����郁�b�Z�[�W�\�[�X�̓T�^�I�ȃf�[�^��
% �Ȃ���΂Ȃ�܂���BINI_CODEBOOK �́A�R�[�h�u�b�N�l�̏�������l�ł��B
% �œK�����ꂽ CODEBOOK �̃x�N�g�����́AINI_CODEBOOK �Ɠ����ł��B
% INI_CODEBOOK ���x�N�g���łȂ��X�J�������ł���Ƃ��A����͖]�܂��� 
% CODEBOOK �x�N�g���̒����ł��BPARTITION �̃x�N�g�����́ACODEBOOK ��
% �x�N�g��������1�������������ɂȂ�܂��B���Θc�ݒl��10^(-7)��菬����
% �Ƃ��A�œK���������I�����܂��B
% 
% [PARTITION, CODEBOOK] = LLOYDS(TRAINING_SET, INI_CODEBOOK, TOL) �́A
% �œK���̋��e�͈͂�^���܂��B
% 
% [PARTITION, CODEBOOK, DISTORTION] = LLOYDS(...) �́A�œK���̍ŏI�c�ݒl
% ���o�͂��܂��B
% 
% [PARTITION, CODEBOOK, DISTORTION, REL_DISTORTION] = LLOYDS(...) �́A
% �v�Z�̏I�����ɁA���Θc�ݒl���o�͂��܂��B 
%
% �Q�l�F QUANTIZ, DPCMOPT.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
