% OPEN_SYSTEM   Simulink�V�X�e���E�B���h�E�܂��̓u���b�N�_�C�A���O �{�b�N�X
% ���J��
%
% OPEN_SYSTEM('SYS') �́A�w�肵���V�X�e���E�B���h�E�܂��̓T�u�V�X�e���E�B��
% �h�E���J���܂��B
%
% OPEN_SYSTEM('BLK') �́A'BLK'���u���b�N�̐�΃p�X���ł���A�w�肵���u���b�N
% �Ɋ֘A����_�C�A���O�{�b�N�X���J���܂��B
%
% OPEN_SYSTEM �́A�t���I�ȓ��͈����Ƃ��āA�ȉ��̂悤�Ȏ�X�̃I�v�V������ݒ��
% ���܂��B�I�v�V�����͈ȉ��̂Ƃ���ł��B
%
% DESTSYS    SYS ���J�����߂̑��̃V�X�e���E�B���h�E��ݒ�B
% ���� �I�v�V�����́A'replace' �� 'reuse' �I�v�V�����Ƌ��Ɏg�p�ł��܂��B
% SYS �� DESTSYS �͓������f�����ɂȂ���΂����Ȃ����Ƃɒ��ӂ��Ă��������B
%  force           �C�ӂ�OpenFcn��}�X�N�̂���V�X�e�����ŃV�X�e�����J���B
% parameter  �u���b�N�̃p�����[�^�_�C�A���O���J��
% property   �u���b�N�̃v���p�e�B�_�C�A���O���J��
% mask       �u���b�N�̃}�X�N�_�C�A���O���J��
% OpenFcn    �u���b�N��OpenFcn�����s
%  replace    ���̃V�X�e���E�B���h�E���ɃV�X�e�����J�����Ƃ��A�w��̃E�B���h
% �E���ė��p���邩�A�J���ꂽ�V�X�e���̑傫���Ɠ����傫���̃E�B���h�E��ݒ�
% reuse      �V�X�e���𑼂̃E�B���h�E�V�X�e���ɊJ���Ƃ��A�E�B���h�E���ė��p
% ���A�X�N���[���ɂ��܂������悤�ɒ���
%
% ��̃I�v�V�����̑g�ݍ��킹���g�������ꍇ������܂��B
% ���Ƃ��΁A�}�X�N���ꂽ�u���b�N���E�B���h�E�ɊJ���čė��p����ꍇ�A���̂�
% ���ɂ��܂��B
%
%  OPEN_SYSTEM(SYS,DESTSYS,'force','replace')
%
% 'force' �I�v�V�����́A�}�X�N���ꂽ�u���b�N�ɑ΂��āA�T�u�V�X�e���E�B���h�E
% �̉��ɁAopen_system ���I�[�v�����邱�Ƃ��K�v�ƂȂ�܂��B
%
% OPEN_SYSTEM ���A���͈����Ƃ��ăZ���z����󂯓���邱�Ƃɒ��ӂ��Ă��������B
% ���̂��Ƃ́AOPEN_SYSTEM �ւ̃R�[�����x�N�g�����ł��邱�Ƃ��Ӗ����Ă��܂��B
%
% ���:
%
% % 'f14' ���J��
% open_system('f14');
%
% % �T�u�V�X�e�� 'f14/Controller' ���J��
% open_system('f14/Controller')
%
% % 'reuse'���[�h�ŁA'f14' ��'f14/Controller' �E�B���h�E�ɊJ��
% open_system('f14','f14/Controller','reuse');
%
% % open_system �̃x�N�g����
% open_system( { 'f14', 'vdp' });
%
% % ���̃x�N�g�������ꂽ open_system �́A��̕�����́A���Z�Ȃ��Ƃ���
% % ��舵���A���̌���
% 'f14' �́A���s����O�ɁA�J������K�v������
% �܂��B
% open_system( { 'f14', 'f14/Controller', 'f14' },...
% {  '',   '',               'vdp' }, ...
% {  '',   '',               'replace' } );
%
% �Q�l : CLOSE_SYSTEM, SAVE_SYSTEM, NEW_SYSTEM, LOAD_SYSTEM.


% Copyright 1990-2002 The MathWorks, Inc.
