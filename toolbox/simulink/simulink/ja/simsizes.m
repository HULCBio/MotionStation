% SIMSIZES   S-function�̃T�C�Y�ݒ�ɗp���郆�[�e�B���e�B
%
% SIMSIZES �́AS-function�ɂ��ē���̏���^���邽�߂�M-�t�@�C��
% S-function�ŗ��p�����⏕�֐��ł��B���̏��́A���́A�o�́A��Ԃ̐��A����ё�
% �̃u���b�N�̓������܂�ł��܂��B
%
% �������w�肵�Ȃ��� mdlInitializeSizes �̂͂��߂� SIMSIZES �֐����Ăяo��
% ���ƁA���̏���Simulink�ɗ^���܂��B���Ƃ��΁A
%  ���Ƃ��΁A sizes = simsizes;����́A�ȉ��̌`���̏���������Ă��Ȃ��\���̂�
% �o�͂��܂��B sizes.NumContStates       % �A����Ԑ�
% sizes.NumDiscStates       % ���U��Ԑ�                        sizes.
% NumOutputs             % �o�͐�
% sizes.NumInputs              % ���͐�
% sizes.DirFeedthrough      % ���ڃt�B�[�h�X���[�t���O           sizes.
% NumSampleTimes      % �T���v�����Ԑ�
%
% �P�����(�O�q�����T�C�Y�\����)���w�肵�Ď��s����ƁASIMSIZES�́A
% S-function�u���b�N���t���O0(�T�C�Y�\���̂̌Ăяo��)�ŌĂяo���ꂽ�Ƃ��ɁA
% �T�C�Y�\���̂�K�؂Ȕz��ɕϊ����ASimulink�ɏ�����Ԃ��܂��B���Ƃ��΁A
% sys = simsizes(sizes);
%
% �Q�l : SFUNTMPL.


% Copyright 1990-2002 The MathWorks, Inc.
