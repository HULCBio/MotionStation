% SIGRANGEINFO - ���f���I�u�W�F�N�g�̐M�������W
%
%
% [MIN,MAX] = SIGRANGEINFO(DATA,BLOCK)�́Acvdata�J�o���[�W�I�u�W�F�N�gDATA��
% ��BLOCK�ɑ΂���M�������W�����߂܂��B�u���b�N�������o�͂����ꍇ�́A�����
% �͌�������AMIN��MAX�̓x�N�g���ɂȂ�܂��B
%
% ���f���I�u�W�F�N�g���w�肷��BLOCK�p�����[�^�́A���̌`���������܂��B
%
% BlockPath           - Simulink�u���b�N�܂��̓��f���̐�΃p�X�@
% BlockHandle         - Simulink�u���b�N�܂��̓��f���̃n���h���@
% SimulinkObj         - Simulink�I�u�W�F�N�gAPI�n���h��
% StateflowID         - Stateflow ID (1�ÂN�����ꂽ�`���[�g�̂���)
% StateflowObj        - Stateflow�I�u�W�F�N�gAPI�n���h��
% (1�ÂN�����ꂽ�`���[�g����̂���) {BlockPath, sfID}    - Stateflow�I�u
%  �W�F�N�g�̃p�X�Ƃ��̃`���[�g�̃C���X�^���X�Ɋ܂܂��I�u�W�F�N�g��ID�����
%                                             ��Z���z��
% {BlockPath, sfObj}   - �`���[�g�Ɋ܂܂��Stateflow�u���b�N��Stateflow �I�u
%                        �W�F�N�g��API�n���h���̃p�X
% {BlockPath, sfID}    - Stateflow�I�u�W�F�N�g�̃p�X�Ƃ��̃`���[�g�̃C���X�^��
%                        �X�Ɋ܂܂��I�u�W�F�N�g��ID����Ȃ�Z���z��
%
% [MIN,MAX] = SIGRANGEINFO(DATA,BLOCK,PORTIDX)�́A�M�������W��Simulink�u���b
% �NBLOCK�ɑ΂���PORTIDX�o�͒[�q���ɐ������܂��B
%


% Copyright 1990-2003 The MathWorks, Inc.
