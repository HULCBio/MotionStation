% SETFIS �́A�t�@�W�C���_�V�X�e���̃v���p�e�B��ݒ肵�܂��B
% 
% FIS2 = SETFIS(FIS1,'fisPropName',newPropValue) �́A'fisPropName' �ɑ�
% ������FIS�v���p�e�B�� newPropValue �ɐݒ肳���ȊO�AFIS1 �Ɠ������e��
% FIS �s�� FIS2 ���o�͂��܂��B
%
% FIS2 = SETFIS(FIS1,varType,varIndex,'varPropName',newPropValue) �́A
% varType �� varIndex �Ŏw�肳�ꂽ�ϐ��Ɋ֘A�����v���p�e�B��V�����ݒ肵
% �� FIS2 ���o�͂��܂��B
% 
% FIS2 = SETFIS(FIS1,varType,varIndex,'mf',mfIndex, 'mfPropName',....
% newPropValue) �́AvarType�AvarIndex�AmfIndex �Ŏw�肳�ꂽ�����o�V�b�v
% �֐��Ɋ֘A�����v���p�e�B�ɐV�����l��ݒ肵�� FIS2 ���o�͂��܂��B
%
% ���:
%           a = newfis('tipper');
%           a = addvar(a,'input','service',[0 10]);
%           a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%           getfis(a)
%           a = setfis(a,'Name','tip_example');
%           a = setfis(a,'DefuzzMethod','bisector');
%           a = setfis(a,'input',1,'Name','quality');
%           getfis(a)
%
% �Q�l    GETFIS.

