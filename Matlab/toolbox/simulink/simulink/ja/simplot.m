% SIMPLOT   Simulink�̃f�[�^�\���̏o�͂��v���b�g
%
% SIMPLOT(DATA) �́AScope���C�N�ȃO���t�B�b�N�X��Handle Graphics�E�B���h
% �E�ɍ쐬���܂��B
% DATA �́ASimulink�̏o�̓u���b�N�ɂ���Đ��������`���̃f�[�^�\���́A
% �܂��́A�s��ł��B�F�́ASimulink��Scope�ŗp��������̂ƈ�v����悤��
% �ݒ肳��܂��B
%   
% DATA �� "Matrix"�A�܂��́A"Structure without time" �̏ꍇ�́A�ʁX�̎���
% �x�N�g�����w��ł��܂��BTIME�́ADATA���̃f�[�^�M���Ɠ��������̃x�N�g����
% �����͈����Ƃ��ē��͂��܂��BDATA �� "Structure with time" �ł���ꍇ
% �ɂ́ATIME �͉e����^���܂���B
% ���Ƃ��΁A
%
%       SIMPLOT(TIME, DATA)
%
% �́ATIME �ɑ΂��� DATA ���v���b�g���܂��B
%
% DATA �����[�q��Scope�u���b�N�ɂ���Đ��������\���̂ł���ꍇ�́A
% �e�[�q����̃f�[�^�́A�ʁX�̃T�u�v���b�g�ɕ\������܂��B�[�q�̃C��
% �f�b�N�X�̃x�N�g���́A����̒[�q��I�����邽�߂ɗp���邱�Ƃ��ł��܂��B
% ���Ƃ��΁A
%
%       PORTS  =  [1,3];
%       SIMPLOT(DATA, PORTS)
%
% �́A1�Ԗڂ�3�Ԗڂ̒[�q����̃f�[�^���v���b�g���܂��B
%
% DATA ���\���̂܂��͍s�񂩂�Ȃ�Z���z��̏ꍇ�A�e�v�f�ɑ΂���v���b�g
% �́A�����̎��s�̊ԂŔ�r�ł���悤�ɏ㏑������܂��B
% �e�X�̎��s�́A�����\���̂����Ɖ��肳��܂��B���s����ʂ��邽�߂�
% ���C���X�^�C�����p�����܂��B���Ƃ��΁A
%
%      DATA  =  {RUN1, RUN2};      % ���ӁF�Z���z�� - {}
%      SIMPLOT(DATA);
%
% �́ARUN1 �� RUN2 �̃f�[�^���㏑�����܂��B
%
% DATA �� "Matrices" �܂��� "Structures without time" ���܂ޏꍇ�́A
% ���ׂĂ̎��s�̃f�[�^�Z�b�g�͓����T�C�Y�łȂ���΂Ȃ�܂���B 
%
% 'diff' �t���O�́A�����̎��s�̍��ق�\�����邽�߂ɗp�����܂��B1��ڂ�
% ���s�́A���̂��̎��s���猸�Z����A��r����Ă�����s�̃��C���X�^�C��
% ���g���Ă��̌��ʂ��v���b�g����܂��B���ԃx�N�g���������łȂ��ꍇ�ɂ́A
% ���`���}���p�����܂��B�J�n���ԂƏI�����Ԃ����s�ԂňقȂ�ꍇ�́A
% �d�Ȃ镔���ɂ��Ă̂ݍ��ق��v���b�g����܂��B���Ƃ��΁A
%
%      DATA  =  {RUN1 RUN2};
%      SIMPLOT(DATA, 'diff')
%
% �́ARUN2 �ɑ΂��郉�C���X�^�C����p���āARUN2-RUN1 ���v���b�g���܂��B
%   
% ���͈����I�v�V������g�ݍ��킹��:
% ---------------------------------
% �O�q�̃I�v�V�����́A�l�X�ȑg�ݍ����ŗp���邱�Ƃ��ł��܂��BDATA �ȊO��
% ���ׂĂ̓��͈����̓I�v�V�����ł����A�ݒ肷��Ƃ��ɂ́A���̏��Ԃœ���
% ���Ȃ���΂Ȃ�܂���B
%
%      SIMPLOT(TIME, DATA, PORTS, 'diff')
%
% �I�u�W�F�N�g�̃n���h���̎擾:
% ----------------------------
% HFIG  =  SIMPLOT(DATA) �́Afigure�̃n���h�����o�͂��܂��B
%
% [HFIG, HAXES, HLINES]  =  SIMPLOT(DATA) �́A�v���b�g���ꂽfigure,axis,
% lines�̃n���h�����o�͂��܂��B
%
% �n���h���̗��p�ɂ́A���̕��@������܂��B
% WHITEBG(HFIG) �́A�ʏ��MATLAB��figure�̃J���[��p���܂��B
% SET(HAXES, 'NextPlot', 'add') �́A���ׂĂ�axes�� HOLD ON �ɂ��܂��B
% SET(HLINES, 'LineStyle', '-') �́A���ׂẴ��C���X�^�C���������ɐݒ肵
% �܂��B
%
% �Q�l : PLOT.


%   Copyright 1990-2002 The MathWorks, Inc.
