% PREDICT �́Ak �X�e�b�v��̗\�����v�Z���܂��B
%   YP = PREDICT(MODEL,DATA,K)
%   
%   DATA : IDDATA �I�u�W�F�N�g�̌^�ŕ\���ꂽ�o�� - ���̓f�[�^�ŁA�\���v
%          �Z�Ɏg���܂��B 
%      
%   MODEL: �C�ӂ� IDMODEL �I�u�W�F�N�g�ŁAIDPOLY, IDSS, IDARX, IDGREY  
%          ���g�������f��
%
%   K    : �\�����ʁB���� t-K �܂ł̉ߋ��̏o�͂��A����t �ł̏o�͂�\����
%          ��̂Ɏg���܂��B���ׂĂ̊֘A�������͂��g���܂��BK = inf 
%          �Ƃ���ƁA�V�X�e���̏����ȈӖ��̃V�~�����[�V���������s���܂�
%          (�f�t�H���g K = 1)�B
%   YP   : IDDATA �I�u�W�F�N�g�ŕ\�����A�v�Z���ʂ̗\���o�́BDATA ������
%          �̎������܂�ł���ꍇ�AYP ���������A�����̎������܂݂܂��B
%
% YP = PREDICT(MODEL,DATA,K,INIT) �́A�����x�N�g���̑I�����s�����Ƃ��ł�
% �܂��B
%   INIT : �������̕��@�F
% 	    'e': �\���덷�̃m�������ŏ��������悤�ɏ�����Ԃ𐄒�
%	         ���̏�Ԃ́AX0 �Ƃ��ďo��(���L�Q�Ɓj
%                �����̎�����DATA�ɑ΂��āAX0�́A�e�����̏�����Ԃ�
%                �܂ޗ�����s��ł� 
%	    'z': ������Ԃ��[���ɂ���
%	    'm': ���f���̓���������Ԃ��g�p
%    X0  : �K�؂Ȓ����̗�x�N�g���ŁA�����l�Ƃ��Ďg�p
%          �����̎������܂�DATA�ɑ΂��āAX0�́A�e�����ɑ΂��鏉�����
%          ��^���������s��ł�
% INIT ���ݒ肳��Ă��Ȃ��ꍇ�AModel.InitialState ���g���A'Estimate', 
% 'Backcast', 'Auto' �͐��肳�ꂽ������Ԃ�^���A����A'Zero' �� 'z' ��
% 'Fixed' �� 'm' ��^���܂��B
%
% [YP,X0,MPRED] = PREDICT(MODEL,DATA,M) �́A������� X0 �Ɨ\���q MPRED
% ���o�͂��܂��BMPRED �́AIDPOLY�I�u�W�F�N�g�̃Z���z��ɂȂ�܂��B�����ŁA
% MPRED{ky} �́Aky�Ԗڂ̏o�͂ɑ΂���\���q�ł��B
%
% �Q�l: COMPARE, IDMODEL/SIM

%   L. Ljung 10-1-89,9-9-94


%   Copyright 1986-2001 The MathWorks, Inc.
