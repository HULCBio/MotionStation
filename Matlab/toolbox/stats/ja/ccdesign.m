% CCDESIGN   ���S�����v����쐬
%
% D=CCDESIGN(NFACTORS) �́A�v��NFACTORS�ɑ΂��钆�S�����v����쐬���܂��B
% �o�͍s��D �́AN�~NFACTORS�ł���A�����ŁAN �́A�v��̓_���ł��B�e�s�́A
% �v���1�̎��s��\���A���s���邷�ׂĂ̗v���̐ݒ���܂�ł��܂��B
% �v���̒l�́Acube point���A-1��1�̊Ԃ̒l�ɓ���悤�ɐ��K������܂��B
%   
% D=CCDESIGN(NFACTORS,'PNAME1',pvalue1,'PNAME2',pvalue2,...) ���g���āA
% �ǉ��̃p�����[�^�Ƃ��̒l���w�肷�邱�Ƃ��ł��܂��B
% �g�p�\�ȃp�����[�^�́A���̂悤�ɂȂ�܂��B:
%   
%      �p�����[�^   �l
%      'center'     �܂܂��钆�S�_�̐��ŁA'uniform'�́A��l�Ȑ��x��^����
%                   ���߂ɕK�v�Ȓ��S�_�̐���I��������̂ŁA�܂��A
%                   'orthogonal' (�f�t�H���g) �́A�����v���^������̂ł��B
%      'fraction'   1/2�ׂ̂���Ƃ��āA�\���ꂽcube portion�ɑ΂��� 
%                   ���S�v���̕����A �����A0 = whole design, 
%                   1 = 1/2 �����A2 = 1/4 �����ȂǁB
%      'type'       'inscribed', 'circumscribed', ���邢�́A'faced'��
%                   �����ꂩ�ƂȂ�܂��B
%      'blocksize'  1�u���b�N���ŋ������ő�_��
%   
% [D,BLK]=CCDESIGN(...) �́A�u���b�N�����ꂽ�v����s���܂��B �o�̓x�N�g��
% BLK �́A�u���b�N���������x�N�g���ł��B�u���b�N�́A���l�̏�������
% (���Ƃ��΁A��������)���肳�����s�ŃO���[�v�����������̂ł��B
% �u���b�N�����ꂽ�v��́A�p�����[�^�]���ɂ��Ẵu���b�N�Ԃ̈Ⴂ��
% ���ʂ��ŏ��ɂ��܂��B
%
% �Q�l : BBDESIGN, ROWEXCH, CORDEXCH.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:10:47 $
