% �\��
% a = addmf(a,varType,varIndex,mfName,mfType,mfParams)
%
% �ڍ�
% �����o�V�b�v�֐��́A���ɑ��݂��Ă��� FIS �̕ϐ����ɁA�t�����邱�Ƃ���
% ���܂��B�C���f�b�N�X�́A�t������鏇�Ƀ����o�[�V�b�v�֐��Ɋ��蓖�Ă��
% �܂��B���̂��߁A�ϐ��ɕt�����ꂽ�ŏ��̃����o�[�V�b�v�֐��́A���̕ϐ���
% �΂��ă����o�[�V�b�v�֐��ԍ�1�ƂȂ�܂��B1�����̓��͂�����`����Ă�
% �Ȃ��ꍇ�A�V�X�e���ւ̓��͕ϐ��ԍ�2�Ƀ����o�V�b�v�֐���t�����邱�Ƃ�
% �ł��܂���B�֐��́A���̏��Ԃ�6�̓��͈�����K�v�Ƃ��܂��B
%
%   1. ���[�N�X�y�[�X����FIS�\���̂� MATLAB �ϐ���
%   2. (���͂܂��͏o�͂�)�����o�[�V�b�v�֐���t������ϐ��̃^�C�v��\��
%      ������
%   3. �����o�[�V�b�v�֐���t������ϐ��̃C���f�b�N�X
%   4. �V���������o�V�b�v�֐��̖��O
%   5. �V���������o�V�b�v�֐��̃^�C�v
%   6. �����o�V�b�v�֐���ݒ肷��p�����[�^�x�N�g��
%
% ���
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%    a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%    plotmf(a,'input',1)
%
% �Q�l    ADDRULE, ADDVAR, PLOTMF, RMMF, RMVAR



%  Copyright 1994-2002 The MathWorks, Inc. 
