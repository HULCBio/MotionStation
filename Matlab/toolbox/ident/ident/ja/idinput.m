% IDINPUT �́A����p�̓��͐M���̍쐬
% 
%   U = IDINPUT(N,TYPE,BAND,LEVELS)
%
%   U: �쐬�������͐M���B��x�N�g���A�܂��́AN�snu��̍s��B
%   N: ���͂̒���
%   N = [N Nu] �́AN �s Nu ��̓��͂�\���܂�(Nu �́A���̓`�����l����)�B
% 
%   N = [P Nu M] �́AM*P �s Nu ��̓��͂�^���܂��B�����ŁA���͂ɂ́A��
%       �� P �������AM ���������܂܂�Ă��܂��B
%       �f�t�H���g�l�́ANu = 1 �� M =1 �ł��B
%   TYPE: ���̒��̂����ꂩ����͂��Ă��������B
%         'RGS'  : �����_���A�K�E�X�M��
%         'RBS'  : �����_���o�C�i���M��
%         'PRBS' : �^�������_���A�o�C�i���M��
%         'SINE' : �������̐����g�̘a����Ȃ�M��
%         �f�t�H���g: TYPE = 'RBS'.
%   BAND: ���͎��g���̑ш敝���K�肷��1�s2��̍s�x�N�g���ł��B
%         'RS', 'RBS', 'SINE' �̏ꍇ�ABAND = [LFR,HFR] �ł��B�����ŁALFR
%         �� HFR �́ANyquist ���g���Ő��K�������ʉߑш���g���̉����Ə�
%         ���̎��g���ł�(��ɁA0��1�̊Ԃ̐���)�B
%         'PRBS' �̏ꍇ�ABAND = [0,B] �ł��B�����ŁA �M���́A����1/B ��
%         ��ԑS�̂ň��l�ƂȂ�܂��B�f�t�H���g�́ABAND = [0 1] �ł��B
%   LEVELS = [MI, MA] : ���̓��x�����`����2�s1��̍s�x�N�g���ł��B
%         'RBS', 'PRBS', 'SINE' �̏ꍇ�A���x���́A���͐M������� MI �� 
%              MA �̊Ԃɑ��݂���悤�ɒ������܂��B
%         'RS' �̏ꍇ�AMI �́A�M���̕��ϒl����W���΍������������̂ŁAMA
%              �͐M���̕��ϒl�ɕW���΍������������̂ł��B�f�t�H���g�́A
%              LEVELS = [-1, 1]�ł��B
%
% 'PRBS' �ŁAM > 1 �̏ꍇ�A�f�[�^��̒���������́A�ő咷�� PRBS ������
% �����{�œ�����悤�ɒ�������܂��B M = 1 �̏ꍇ�A�����́AP = N ���
% �������Ȃ�悤�ɑI������܂��B�����͂̏ꍇ�A�M�����ő�ɍ��킹�ăV�t�g
% ����܂��B����́A���̂悤�ȐM���ɂ��V�X�e���̓���Ɏg�p���郂�f����
% �����Ɋւ��āAP/Nu �����f�������̏���ł��邱�Ƃ��Ӗ����܂��B
%
% 'SINE' �̏ꍇ�Api*[BAND(1) BAND(2)] �̊Ԋu�ŁA���g���O���b�h freq = 
% 2*pi*[1:Grid_Skip:fix(P/2)]/P �ɑ΂��āA�����g��I�����܂�(Grid_Skip 
% �Ɋւ��ẮA�����Q��)�B�����͐M���ɑ΂��ẮA���ꂼ��̓��͂��A���̃O
% ���b�h����قȂ���g�����g���܂��B�����S�̂̐����{����ɖ�������܂��B
% �I���������g���́A[U,FREQS] = IDINPUT(....) �őI������܂��B�����ŁA
% FREQS �̍s ku �́A���͔ԍ� ku �̎��g�����܂�ł��܂��B���ʂ̐M���́A5
% �Ԗڂ̈��� SINEDATA �ŗ^�����܂��B
% 
%   U = IDINPUT(N,TYPE,BAND,LEVELS,SINEDATA)
% 
% �����ŁA
% 
%   SINEDATA= [No_of_Sinusoids, No_of_Trials, Grid_Skip],
% 
% �́ANo_of_Sinusoids �́A������� BAND ��𓙊Ԋu�ɁA�Œ�̐U���M������
% ����܂ŁANo_of_Trials ���A�����_���ɕύX����񐔂ł��B
% 
% �f�t�H���g�F SINEDATA = [10,10,1];
%
% �Q�l�F IDMODEL/SIM

%   L. Ljung 3-3-95


%   L. Ljung 3-3-95
%   Copyright 1986-2001 The MathWorks, Inc.
