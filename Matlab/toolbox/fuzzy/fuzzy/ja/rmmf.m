% RMMF   FIS ���烁���o�V�b�v�֐�������
% 
% fis2 = RMMF(fis,varType,varIndex,'mf',mfIndex, warningDlgEnabled) �́A
% FIS �s�� fis �Ɋ֘A�����t�@�W�B���_�V�X�e������ݒ肳�ꂽ�����o�V�b�v
% �֐����������܂��B�m�F���K�v�ȏꍇ�A�u�[���A���ϐ� 'warningDlgEnabled'
% ���w�肵�܂��B�ϐ� 'varType' �́A'input' �܂��� 'output' �̂ǂ��炩
% �ł��B�����o�V�b�v�֐��̏�����A���͂Ȃ����o�̓����o�V�b�v���܂ނ��ׂ�
% �̃��[���́Afis �����菜����܂��B
%
% ���:
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%    a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%    subplot(2,1,1),plotmf(a,'input',1)
%    a = rmmf(a,'input',1,'mf',2);
%    subplot(2,1,2),plotmf(a,'input',1)
%
% �Q�l    ADDMF, ADDRULE, ADDVAR, PLOTMF, RMVAR.


%   Ned Gulley, 2-2-94   Kelly Liu 7-22-96
%   Copyright 1994-2002 The MathWorks, Inc. 
