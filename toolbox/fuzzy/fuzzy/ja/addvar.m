% �ړI
% �ϐ��� FIS �ɕt�����܂��B
%
% �\��
% a = addvar(a,varType,varName,varBounds)
%
% �ڍ�
% addvar �́A���̏��Ԃŕ��ׂ�ꂽ4�̈����������Ă��܂��B
% 1. FIS �̖��O
% 2. �ϐ��̃^�C�v(���͂܂��͏o��)
% 3. �ϐ��̖��O
% 4. �ϐ��̐����͈͂��L�q����x�N�g��
% �C���f�b�N�X�́A�t������鏇�ɕϐ��ɓK�p����A�V�X�e���ɕt�������ŏ�
% �̓��͕ϐ��́A���̃V�X�e���ɑ΂��ē��͕ϐ��ԍ�1�ƂȂ�܂��B���͕ϐ���
% �o�͕ϐ��́A�ʁX�ɔԍ����t�����܂��B
%
% ���
%     a = newfis('tipper');
%     a = addvar(a,'input','service',[0 10]);
%     getfis(a,'input',1)
%     MATLAB replies
%     Name = service
%     NumMFs = 0
%     MFLabels  = 
%     Range = [0 10]
%
% �Q�l    addmf, addrule, rmmf, rmvar



%   Copyright 1994-2002 The MathWorks, Inc. 
