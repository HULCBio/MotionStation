% SHOWRULE FIS ���[���̕\��
% 
% SHOWRULE(FIS) �́A�s�� FIS �Ɋ֘A�����t�@�W�B���_�V�X�e���ɑ΂��āA
% verbose �t�H�[�}�b�g�ł��ׂẴ��[����\�����܂��B
%
% SHOWRULE(FIS,ruleIndex) �́A�x�N�g�� ruleIndex �ɂ��ݒ肵�����[��
% ��\�����܂��B
%
% SHOWRULE(FIS,ruleIndex,ruleFormat) �́AruleFormat �ɂ��ݒ肵�����[
% ���t�H�[�}�b�g���g���ă��[����\�����܂��B����ɂ́A'verbose' (�f�t�H
% ���g)�A'symbolic' (����j���[�g����)�A����сA'indexed' (�����o�V�b�v
% �֐��C���f�b�N�X�Q�Ɨp)�̒���1���g�����Ƃ��ł��܂��B
%
% SHOWRULE(fis,ruleIndex,ruleFormat,lang) �́A'english'�A'francais'�A
% 'deutsch' �̂����ꂩ�ł���K�v������ lang �ݒ�̌�����ɃL�[���[�h����
% ��Ɖ��肵�āAverbose ���[�h�Ń��[����\�����܂��B�L�[���[�h(English)
% �́AIF�ATHEN�AIS�AAND�AOR�ANOT �ł��B
%
% ���
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
%    showrule(a,[2 1],'symbolic')
%
% �Q�l    ADDRULE, PARSRULE, RULEEDIT.



%   Copyright 1994-2002 The MathWorks, Inc. 
