% PARSRULE �t�@�W�B���[���̕��@�I�ȋL�q
% 
% ���̊֐��̕��@�L�q�́A�t�@�W�B�V�X�e��(fis)�̃��[��(txtRuleList)������
% ���A�K�؂ȃ��[���̃��X�g������ FIS �\���̂��o�͂�����̂ł��B�I���W�i
% ���̓��� FIS �\���� fis ���ŏ��Ƀ��[�������ꍇ�A�V�����s�� fis2 �ƒu
% �������܂��B3�̈قȂ郋�[���t�H�[�}�b�g(ruleFormat �Őݒ�)���A�T�|�[
% �g����Ă��܂��B�����́A*verbose*�A*symbolic*�A*indexed* �ł��B�f�t
% �H���g�t�H�[�}�b�g�́A*verbose* �ł��B�I�v�V�����̌������(lang)���g��
% ���Ƃ��Averbose ���[�h�ƂȂ�A�L�[���[�h�́Alang �ŗ^����ꂽ�����
% �Ȃ�܂��B�����ŗ��p�ł��錾��́A'english'�A'francais'�A'deutsch' ��
% ���B�p��ł̃L�[���[�h�́AIF�ATHEN�AIS�AAND�AOR�ANOT �ł��B
%
% outFIS = PARSRULE(inFIS,inRuleList) �́A������s�� inRuleList �Ƀ��[��
% �̍\����͂��s���āA�X�V���� FIS �s�� outFIS ���o�͂��܂��B
%
% outFIS = PARSRULE(inFIS,inRuleList,ruleFormat) �́A�^����ꂽ ruleFo-
% rmat �ɂ���ă��[���̍\����͂��s���܂��B
%
% outFIS = PARSRULE(inFIS,inRuleList,ruleFormat,lang) �́A�L�[���[�h�� 
% lang �ɂ��^�����錾��Ƃ��āAverbose ���[�h�Ń��[���̍\����͂��s
% ���܂��B
%
% ���:
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addvar(a,'input','food',[0 10]);
%    a = addmf(a,'input',2,'rancid','trapmf',[-2 0 1 3]);
%    a = addvar(a,'output','tip',[0 30]);
%    a = addmf(a,'output',1,'cheap','trimf',[0 5 10]);
%    rule1 = 'if service is poor or food is rancid then tip is cheap';
%    a = parsrule(a,rule1);
%    showrule(a)
%
% �Q�l    ADDRULE, RULEEDIT, SHOWRULE.



%   Copyright 1994-2002 The MathWorks, Inc. 
