% PLOTMF 1�̕ϐ��ɑ΂��邷�ׂẴ����o�V�b�v�֐��̕\��
% 
% PLOTMF(fismat,varType,varIndex) �́AverType �� verIndex �ɂ���ė^����
% �ꂽ�^�C�v(���͂܂��͏o��)��C���f�b�N�X��\���ϐ����\�����s�� fis-
% mat �ɂ��^����t�@�W�B���_�V�X�e���Őݒ肷��ϐ��֘A�̂��ׂẴ����o
% �V�b�v�֐����v���b�g���܂��B���̊֐��́AMATLAB �̊֐� subplot �Ƌ��ɗp
% ���邱�Ƃ��ł��܂��B
%
% [xOut,yOut] = PLOTMF(fismat,varType,varIndex) �́A�����o�V�b�v�֐��֘A
% �� x �� y �̃f�[�^�_���A�v���b�g���邱�ƂȂ��o�͂��܂��B
%
% PLOTMF(fismat,varType,varIndex,numPts) �́A�Ȑ������傤�� numPts ��
% �_�Ńv���b�g�������̂Ɠ����v���b�g���쐬���܂��B
%
% ���
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%    a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%    plotmf(a,'input',1)
%
% �Q�l    EVALMF, PLOTFIS.



%   Copyright 1994-2002 The MathWorks, Inc. 
