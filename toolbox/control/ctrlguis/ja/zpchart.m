% ZPCHART   z-���ʂ̃O���b�h���C�����쐬
%
% [GRIDLINES,LABELS] = ZPCHART(AX) �́A�� AX ��� z-���ʃO���b�h���C����
% �v���b�g���܂��B�ŗL���g���ƌ�����͈̔͂́AAX �̎��͈̔͂���Ɏ����I��
% ���肳��܂��BGRIDLINES �� LABELS �́A�v���b�g���ꂽ�O���b�h�̃��C����
% ���x���ɑ΂���n���h�����܂�ł��܂��B
%
% [GRIDLINES,LABELS] = ZPCHART(AX,ZETA,WN) �́AZETA �� WN �ł��ꂼ��
% �ݒ肵��������ƌŗL���g���ɑ΂��āA�� AX ��� z-���ʃO���b�h���v���b�g
% ���܂��B
%
% [GRIDLINES,LABELS] = SPCHART(AX,OPTIONS) �́A�\���� OPTIONS ���̂��ׂĂ�
% �O���b�h�p�����[�^���w�肵�܂��B�L���ȃt�B�[���h(�p�����[�^)�́A�ȉ���
% ���̂��܂݂܂�:
%       Damping: ������̃x�N�g��
%       Frequency: ���g���̃x�N�g��
%       FrequencyUnits = '[ Hz | {rad/sec} ]';
%       GridLabelType  = '[ {damping} | overshoot ]';
%       SampleTime     = '[ real scalar | {-1} ]';
%
% 'Hz'�̎��g���P�ʂ��w�肳��AWN ���^����ꂽ�ꍇ�AWN �l�́A'Hz'��
% �P�ʂŗ^��������̂Ɖ��肳��邱�Ƃɒ��ӂ��Ă��������B
%
% �Q�l : PZMAP, ZGRID.


%   Revised: Adam DiVergilio, 11-99
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:22 $

