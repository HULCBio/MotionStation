% SPCHART   s-���ʂ̃O���b�h���C�����쐬
%
% [GRIDLINES,LABELS] = SPCHART(AX) �́A�� AX ��� s-���ʃO���b�h���C����
% �v���b�g���܂��B�ŗL���g���ƌ�����͈̔͂́AAX �̎��͈̔͂���Ɏ����I��
% ���肳��܂��BGRIDLINES �� LABELS �́A�v���b�g���ꂽ�O���b�h�̃��C����
% ���x���ɑ΂���n���h�����܂�ł��܂��B
%
% [GRIDLINES,LABELS] = SPCHART(AX,ZETA,WN) �́AZETA �� WN �ł��ꂼ��
% �ݒ肵��������ƌŗL���g���ɑ΂��āA�� AX ��� s-���ʃO�b���b�h��
% �v���b�g���܂��B
%
% [GRIDLINES,LABELS] = SPCHART(AX,OPTIONS) �́A�\���� OPTIONS ���̂��ׂĂ�
% �O���b�h�p�����[�^���w�肵�܂��B�L���ȃt�B�[���h(�p�����[�^)�́A�ȉ���
% ���̂��܂܂�܂��B:
%       Damping: ������̃x�N�g��
%       Frequency: ���g���̃x�N�g��
%       FrequencyUnits = '[ Hz | {rad/sec} ]';
%       GridLabelType  = '[ {damping} | overshoot ]';
%
% 'Hz' �̎��g���P�ʂ��w�肳��AWN ���^����ꂽ�ꍇ�AWN �l�́A'Hz' ��
% �P�ʂŗ^������Ă���Ɖ��肳��邱�Ƃɒ��ӂ��Ă��������B
% 
% �Q�l : PZMAP, SGRID, GRIDOPTS.


%   Revised: Adam DiVergilio, 11-99
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:15 $
