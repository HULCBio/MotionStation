% BWHITMISS �@�o�C�i�� hit-miss ���Z
% 
% BW2 = BWHITMISS(BW,SE1,SE2) �́A�\�����v�f SE1 �� SE2 �Œ�`���� hit-
% miss ���Z���s���܂��Bhit-miss ���Z�́ASE1 �̌^��"��v"����s�N�Z����
% �ߖT�ƁASE2 �̌^�Ɉ�v���Ȃ����̂�ۑ����܂��BSE1 �� SE2 �� STREL ��
% ���A�܂��͋ߖT�z��ɂ���ĕԂ���镽�R�ȍ\�����v�f�I�u�W�F�N�g�ł��B
% SE1 �� SE2 �̗̈�͋��ʂ̗v�f�������Ă��܂���BBWHITMISS(BW,SE1,SE2) 
% �́AIMERODE(BW,SE1) & IMERODE(~BW,SE2) �Ɠ����ł��B
%
% BW2 = BWHITMISS(BW,INTERVAL) �́A"INTERVAL"�ƌĂ΂��P��z��̍��Œ�`
% ���� hit-miss ���Z���s���܂��BINTERVAL �́A1, 0, -1 �̂����ꂩ��v�f��
% ����z��ł��B�l1�́ASE1 �̗̈�����A�l -1 �́ASE2 �̗̈�����܂��B
% �����āA�l 0 �́A�������܂��B
% 
% BWHITMISS(INTERVAL) �́ABWHITMISS(BW,INTERVAL == 1,INTERVAL == -1) �Ɠ�
% ���ł��B
%
% �N���X�T�|�[�g
% -------------
% BW1 �́A��X�p�[�X�� logical ���C�ӂ̃N���X�̐��l�z��ł��BBW2 �́A
% ��� BW1 �Ɠ����T�C�Y�� logical �ł��BSE1 �� SE2 �͕��R�� STREL �I�u
% �W�F�N�g���A1��0�݂̂��܂� logical �����l�z��łȂ���΂Ȃ�܂���B
% INTERVAL �́A1�A0�A-1�̂����ꂩ���܂񂾔z��łȂ���΂Ȃ�܂���B
%
%   ���
%   -------
%       bw = [0 0 0 0 0 0
%             0 0 1 1 0 0
%             0 1 1 1 1 0
%             0 1 1 1 1 0
%             0 0 1 1 0 0
%             0 0 1 0 0 0]
%
%       interval = [0 -1 -1
%                   1  1 -1
%                   0  1  0];
%
%       bw2 = bwhitmiss(bw,interval)
%
% �Q�l�FIMDILATE, IMERODE, STREL.



%   Copyright 1993-2002 The MathWorks, Inc.
