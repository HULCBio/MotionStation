% [perf,P] = quadperf(pds,g,options)
%
% �A�t�B���V�X�e���A�܂��́A�|���g�s�b�N�p�����[�^�ˑ��V�X�e��PDS��2��
% RMS�Q�C���B
%
% OPTION(1)=0�Ȃ�΁AQUADPERF�́AG�̐ݒ�ɂ��������āA���̂��Ƃ����s��
% �܂��B
% G=0�̂Ƃ�PDS��2��Hinf���\�𐄒肵�A�����łȂ���΁A���\G > 0�����o�X�g
% �ł��邩���e�X�g���܂��B
%
% OPTION(1)=1�Ȃ�΁AQUADPERF�́A2��Hinf���\ G>0���ێ������p�����[�^��
% ����ő剻���܂��B�ő�̈�́A�p�����[�^�{�b�N�X�����̒��S�܂��Ŋg��
% ���邱�Ƃɂ�蓾���܂��B���̃I�v�V�����́A�A�t�B��PDS�ɑ΂��Ă̂ݎg
% �p�\�ł��B
%
% ����:
%  PDS       �|���g�s�b�N�V�X�e���A�܂��́A�p�����[�^�ˑ��V�X�e��(PSYS��
%            �Q��)�B
%  G         �K�肳�ꂽ���\(�f�t�H���g=0)�B
%  OPTIONS   �I�v�V������3�v�f�x�N�g��
%            OPTIONS(1)   :  ��L���Q��(�f�t�H���g=0)�B
%            OPTIONS(2)=0 :  �������[�h(�f�t�H���g)�B
%                      =1 :  �����Ƃ��ێ琫�̂Ȃ����[�h�B
%            OPTIONS(3)   :  P�̏������̋��E(�f�t�H���g = 1e9)�B
% �o��:
%  PERF      OPTIONS(1)=0�Ȃ�΁A2��RMS�Q�C���ł��B�����łȂ���΁A���\G
%            ���ۏ؂����p�����[�^�{�b�N�XPV�̊���(PERF=1��100%���Ӗ���
%            �܂�)
%  P         Lyapunov�s��P
%
% �Q�l�F    MUPERF, QUADSTAB, PSYS.



% Copyright 1995-2002 The MathWorks, Inc. 
