% TABLEINFO - ���f���I�u�W�F�N�g�̃f�V�W�����J�o���[�W���
%
% COVERAGE = MCDCINFO(DATA, BLOCK)�́Acvdata�J�o���[�W�I�u�W�F�N�gDATA����
% BLOCK�ɑ΂�������J�o���[�W�����߂܂��BCOVERAGE�́A2�v�f�x�N�g���Ƃ��ďo�͂�
% ��܂�: [covered_cases total_cases].BLOCK�Ɋւ������DATA�̈ꕔ�łȂ���
% ���́ACOVERAGE�͋�ł��B
%
% ��͂���郂�f���I�u�W�F�N�g���w�肷��BLOCK�p�����[�^�́A���̌`���Ŏw�肳
% ��܂��B
%
% BlockPath           - Simulink�u���b�N�܂��̓��f���̐�΃p�X�@
% BlockHandle         - Simulink�u���b�N�܂��̓��f���̃n���h���@
% SimulinkObj         - Simulink�I�u�W�F�N�gAPI�n���h��
% StateflowID         - Stateflow ID (1�ÂN�����ꂽ�`���[�g�̂���)
% StateflowObj        - Stateflow�I�u�W�F�N�gAPI�n���h��
% (1�ÂN�����ꂽ�`���[�g����̂���)
%  {BlockPath, sfID}    - Stateflow�I�u�W�F�N�g�̃p�X�Ƃ��̃`���[�g�̃C���X
%                         �^���X�Ɋ܂܂��I�u�W�F�N�g��ID����Ȃ�Z���z��
% {BlockPath, sfObj}   - �`���[�g�Ɋ܂܂��Stateflow�u���b�N��Stateflow �I�u
%                        �W�F�N�g��API�n���h���̃p�X
% {BlockPath, sfID}    - Stateflow�I�u�W�F�N�g�̃p�X�Ƃ��̃`���[�g�̃C���X�^��
%                        �X�Ɋ܂܂��I�u�W�F�N�g��ID����Ȃ�Z���z��
%
% COVERAGE = MCDCINFO(DATA, BLOCK, IGNORE_DESCENDENTS)�́ABLOCK�̃f�V�W����
% �J�o���[�W�����߁AIGNORE_DESCENDENTS���^�ł���ꍇ�ɉ��w�I�u�W�F�N�g���̃J
%
% [COVERAGE,DESCRIPTION] = MCDCINFO(DATA, BLOCK)�́A�J�o���[�W�����߁A�e�u�[��
% �A�����̃e�L�X�g�L�q�ƁA���̎����̏����ƁA�e���������̌��ʂ��ʂɕύX����
% ���߂Ɏ��s���ꂽ���ǂ����������t���O�ATrue�̌��ʂɒB���������l��\�킷����
% ��ƁAfalse�̌��ʂ̕�������܂ލ\���̔z��DESCRIPTION�𐶐����܂��B
%


% Copyright 1990-2003 The MathWorks, Inc.
