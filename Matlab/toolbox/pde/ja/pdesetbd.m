% PDESETBD �́APDE Tollbox �̋��E�ɑ΂��鋫�E������ݒ肵�܂��B
% 
%     pdesetbd(BOUNDS,TYPE,MODE,COND,COND2,COND3,COND4)
%
% pdesetbd(BOUNDS,TYPE,MODE,COND,COND2) �́A���E BOUNDS �� COND �� COND2
% �Ŏw�肳�ꂽ�^�C�v TYPE �̋��E�����ɐݒ肵�܂��BMODE �́A�X�J������
% �ꍇ1�A�V�X�e��(2����)���̏ꍇ2�ł��B
% 
% BOUNDS �́A���E�����s��ƕ�������郊�X�g���̗�ԍ��ɑΉ����܂��BBOU-
% NDS �͊O���̋��E�݂̂��܂�ł��܂��B
% 
% (��ʓI��)Neumann �����ł� TYPE = 'neu' �ŁADirichlet �����ł� TYPE = 
% 'dir'�A�������E�����ł� TYPE = 'mix' �ł��B
% 
% ���� : 
% �V�X�e��(2����)�̏ꍇ�̂݁A�����������g�p�\�ł��B
% 
% COND, COND2,... �́Ax �� y �̊֐��܂��͋ȗ��̊֐��ŕ\�������E��������
% �ޕ�����ł��B
% 
%  ��ʓI�� Neumann �����̏ꍇ
% 
%     n*(c*grad(u))+q*u = g,
% 
% COND �́Aq�����܂݁A COND2 �́Ag �����܂݂܂��B
% 
% Dirichlet�����̏ꍇ
% 
%        h*u = r,
% 
% COND �́Ah �����܂݁ACOND2 �́Ar �����܂݂܂��B
% 
% ���������̏ꍇ
% 
%        n*(c*grad(u))+q*u = g; hu = r,
% 
% COND �́Aq �����܂݁ACOND2 �́Ag �����܂݁A COND3 �́Ah �����܂݁ACO-
% ND4 �́Ar �����܂݂܂��B
% 

%       Copyright 1994-2001 The MathWorks, Inc.
