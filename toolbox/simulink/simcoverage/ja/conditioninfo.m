% decisioninfo     - ���f���I�u�W�F�N�g�ɑ΂���condition coverage���
%
%
% COVERAGE = CONDITIONINFO(DATA, BLOCK) �́Acvdata coverage�I�u�W�F�N�g
% DATA ���� BLOCK �ɑ΂������coverage�����o���܂��BCOVERAGE �́A
% [covered_cases total_cases]�ƂȂ�2�̗v�f�x�N�g�����o�͂���܂��BBLOCK
% �ɂ��Ă̏��̈ꕔ���Ȃ��ꍇ�ACOVERAGE �͋�ɂȂ�܂��B
%
% ���f���I�u�W�F�N�g���w�肷��BLOCK�p�����[�^�́A�ȉ��̌`�������܂�:
%
% BlockPath           - Simulink�u���b�N�܂��̓��f���̐�΃p�X�@BlockHandl
%  e         - Simulink�u���b�N�܂��̓��f���̃n���h�� SimulinkObj
%                       - Simulink�I�u�W�F�N�gAPI�n���h��
% StateflowID         - Stateflow ID (�X�ɗᎦ���ꂽ�`���[�gID) Stateflow
%                       Obj        - Stateflow�I�u�W�F�N�gAPI�n���h��
% (�X�ɗᎦ���ꂽ�`���[�gID) {BlockPath, sfID}    - Cell array with the p
%                                         ath to
%                                         a Stat
%                                         eflow�u���b�N�̃p�X�ƃ`���[�g�̃C���X�^���X�Ɋ܂܂��I�u�W�F�N�g��ID���܂ރZ���z��
% {BlockPath, sfObj}   - Stateflow�u���b�N�̃p�X�Ƃ��̃`���[�g�Ɋ܂܂��St
%                        ateflow�I�u�W�F�N�gAPI�n���h��
% [BlockHandle sfID]   - Stateflow�u���b�N�̃n���h���Ƃ��̃`���[�g�C���X�^��
%                        �X�Ɋ܂܂��I�u�W�F�N�g��ID����Ȃ�z��
%
% COVERAGE = CONDITIONINFO(DATA, BLOCK, IGNORE_DECENDENTS) �́ABLOCK �ɑ΂�
% �����coverage�����o���AIGNORE_DECENDENTS ���^�̏ꍇ�Adecendent�I�u�W�F�N�g
% ����coverage�𖳎����܂��B
%
% [COVERAGE,DESCRIPTION] = CONDITIONINFO(DATA, BLOCK) �́Acoverage�����o���A
% �e�����Ɛ^�̐��ƋU�̐��̃e�L�X�g�̋L�q���܂ލ\���̔z��DESCRIPTION �𐶐�
%


% Copyright 1990-2002 The MathWorks, Inc.
