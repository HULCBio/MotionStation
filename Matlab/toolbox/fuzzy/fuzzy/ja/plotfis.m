% PLOTFIS FIS ���́\�o�̓_�C�A�O�����̕\��
% 
% PLOTFIS(FISSTRUCT) �́AFIS �\���� FISSTRUCT �֘A�̃t�@�W�B���_�V�X�e��
% �̓���-�o�͕\�����쐬���܂��B���͂Ƃ����̃����o�V�b�v�֐��́AFIS �\
% ���̂̓����̍����ɕ\������A�o�͂Ƃ��̃����o�V�b�v�֐��́A�E���ɕ\����
% ��܂��B
%
% ���� FIS �_�C�A�O�����́A(�R�}���h FUZZY �ŋN������)FIS Editor �㕔��
% ���̂Ɨގ����Ă��܂��B
%
% ���:
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%    a = addvar(a,'input','food',[0 10]);
%    a = addmf(a,'input',2,'rancid','trapmf',[-2 0 1 3]);
%    a = addmf(a,'input',2,'delicious','trapmf',[7 9 10 12]);
%    a = addvar(a,'output','tip',[0 30]);
%    a = addmf(a,'output',1,'cheap','trimf',[0 5 10]);
%    a = addmf(a,'output',1,'generous','trimf',[20 25 30]);
%    ruleList = [1 1 1 1 2; 2 2 2 1 2 ];
%    a = addrule(a,ruleList);
%    plotfis(a)
% 
% �Q�l    EVALMF, PLOTMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
