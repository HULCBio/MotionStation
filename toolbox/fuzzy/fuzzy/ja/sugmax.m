% SUGMAX ����t�@�W�B�V�X�e���̍ő�o�͔͈͂̌���
% 
% [maxOut,minOut] = SUGMAX(FIS) �́A���͕ϐ��͈̔͂ɑO�����Đ�����݂���
% �s�� FIS �Ɋ֘A��������t�@�W�C���_�V�X�e���ɑ΂���\�ȍő�o�͂ƍ�
% ���o�͂ɑΉ�����2�̃x�N�g�� maxOut �� minOut ���o�͂��܂��BmaxOut ��
% maxIn �ɂ́A�o�̗͂v�f���Ɠ����v�f���������Ă��܂��B
%
% ���
%    a = newfis('sugtip','sugeno');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%    a = addvar(a,'input','food',[0 10]);
%    a = addmf(a,'input',2,'rancid','trapmf',[-2 0 1 3]);
%    a = addmf(a,'input',2,'delicious','trapmf',[7 9 10 12]);
%    a = addvar(a,'output','tip',[0 30]);
%    a = addmf(a,'output',1,'cheap','constant',5);
%    a = addmf(a,'output',1,'generous','constant',25);
%    ruleList = [1 1 1 1 2; 2 2 2 1 2 ];
%    a = addrule(a,ruleList);
%    sugmax(a)



%   Copyright 1994-2002 The MathWorks, Inc. 
