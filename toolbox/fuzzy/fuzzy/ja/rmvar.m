% RMVAR  FIS����ϐ�������
% 
% fis2 = RMVAR(fis,'varType',varIndex) �́AFIS �s�� fis �Ɗ֘A�����t�@�W�B
% ���_�V�X�e������ݒ肳�ꂽ�ϐ����������܂��B
%
% [fis2,errorStr] = RMVAR(fis,'varType',varIndex) �́A�K�v�ȃG���[���b�Z�[
% �W�𕶎��� errorStr �ɏo�͂��܂��B
%
% ���
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addvar(a,'input','food',[0 10]);
%    getfis(a)
%    a = rmvar(a,'input',1);
%    getfis(a)
%
% �Q�l    ADDMF, ADDVAR, RMMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
