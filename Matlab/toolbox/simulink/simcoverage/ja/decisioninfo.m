% DECISIONINFO - ���f���I�u�W�F�N�g�̃f�V�W�����J�o���[�W���
%
% COVERAGE = DECISIONINFO(DATA, BLOCK)�́Acvdata�J�o���[�W�I�u�W�F�N�gDATA��
% ��BLOCK�̃f�V�W�����J�o���[�W�����߂܂��BCOVERAGE�́A2�v�f�x�N�g���Ƃ��ďo��
% ����܂��B [covered_outcomes total_outcomes].
% BLOCK�Ɋւ������DATA�̈ꕔ�łȂ��ꍇ�́ACOVERAGE�͋�ł��B
%
% ���f���I�u�W�F�N�g���w�肷��BLOCK�p�����[�^�́A���̌`���ł��B
%
% BlockPath           - Simulink�u���b�N�܂��̓��f���̐�΃p�X
% BlockHandle         - Simulink�u���b�N�܂��̓��f���̃n���h��
% SimulinkObj         - Simulink�I�u�W�F�N�gAPI�n���h��
% StateflowID         - Stateflow ID (1�ÂN�����ꂽ�`���[�g�̂���) Sta
%                       teflowObj        - Stateflow�I�u�W�F�N�gAPI�n���h��
% (1�ÂN�����ꂽ�`���[�g����̂���)
% {BlockPath, sfID}    - Stateflow�I�u�W�F�N�g�̃p�X�Ƃ��̃`���[�g�̃C���X�^��
%                        �X�Ɋ܂܂��I�u�W�F�N�g��ID����Ȃ�Z���z��
% {BlockPath, sfObj}   - �`���[�g�Ɋ܂܂��Stateflow�u���b�N��Stateflow�I�u
%                        �W�F�N�g��API�n���h���̃p�X
% {BlockPath, sfID}    - Stateflow�I�u�W�F�N�g�̃p�X�Ƃ��̃`���[�g�̃C���X�^��
%                        �X�Ɋ܂܂��I�u�W�F�N�g��ID����Ȃ�Z���z��
%
% COVERAGE = DECISIONINFO(DATA, BLOCK, IGNORE_DESCENDENTS)�́A�J�o���[�W����
% �߁AIGNORE_DESCENDENTS�͐^�ł���ꍇ�ɉ��w�I�u�W�F�N�g���̃J�o���[�W�𖳎�
%
% [COVERAGE,DESCRIPTION] = DECISIONINFO(DATA, BLOCK)?�́A�J�o���[�W�����߁A
% BLOCK���̃f�V�W�����̍\���I�ȋL�q�Ə����𐶐����܂��BDESCRIPTION�́A�e�f�V
% �W�����̃e�L�X�g�L�q�ƁABLOCK���̊e���ʂɑ΂���L�q�ƁA���s�J�E���g���܂ލ\
% ���̂ł��B
%


% Copyright 1990-2003 The MathWorks, Inc.
