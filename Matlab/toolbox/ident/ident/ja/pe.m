% PE �́A�\���덷���v�Z���܂��B
% 
%   E = PE(Model,DATA)
%   E = PE(Model,DATA,INIT)
%
%   E    : �v�Z�����\���덷�B�덷�� E.OutputData �Ɋ܂� IDDATA �I�u�W
%          �F�N�g�ł��B
%   DATA : IDDATA �I�u�W�F�N�g�̌^�ŕ\�����o�� - ���̓f�[�^(HELP IDDATA 
%          ���Q��)
%   Model: �C�ӂ� IDMODEL �I�u�W�F�N�g�AIDPOLY, IDSS, IDARX, IDGREY ��
%          �^�������f��
%   INIT : �������̕��@�F
% 	    'e': E �̃m�������ŏ��������悤�ɏ�����Ԃ𐄒�
%	         ���̏�Ԃ́AX0 �Ƃ��ďo��
%	    'z': ������Ԃ��[���ɂ���
%	    'm': ���f���̓���������Ԃ��g�p
%       X0: �K�؂Ȓ����̗�x�N�g���ŁA�����l�Ƃ��Ďg�p
%           �����̎������܂�DATA�ɑ΂��āAX0�́A�e�����ɑ΂��鏉�����
%           ��^���������s��ł�
% INIT ���ݒ肳��Ă��Ȃ��ꍇ�AModel.InitialState ���g���A'Estimate',
% 'Backcast', 'Auto'�͐��肳�ꂽ������Ԃ�^���A����A'Zero' �� 'z' ���A
% 'Fixed' �� 'm' ��^���܂��B
%
% [E,X0] = PE(Model,DATA) �́A�g�p���鏉����� X0 ���o�͂��܂��BDATA ��
% �����̎������܂ޏꍇ�AX0 �́A�e�����ɑ΂��鏉����Ԃ��܂ޗ�����s��
% �ɂȂ�܂��B

%	L. Ljung 10-1-86,2-11-91


%	Copyright 1986-2001 The MathWorks, Inc.
