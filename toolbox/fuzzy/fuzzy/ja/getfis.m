% GETFIS �t�@�W�B���_�V�X�e���̃v���p�e�B�̎擾
% 
% OUT = GETFIS(FIS) �́A�t�@�W�B���_�V�X�e�� FIS �̈�ʓI�ȏ��̃��X�g
% ���o�͂��܂��B
% OUT = GETFIS(FIS,'fisProp') �́A'fisProp' �Ɩ��t���� FIS �v���p�e�B��
% �J�����g�̒l���o�͂��܂��B
% OUT = GETFIS(FIS, 'vartype', 'varindex') �́A'varindex' �� 'vartype'
% �̈�ʓI�ȏ��̃��X�g���o�͂��܂��B
% OUT = GETFIS(FIS, 'vartype', 'varindex', 'varprop') �́A'varindex' ��
% 'vartype' �ɑ΂��� 'varprop' �̃J�����g�̒l���o�͂��܂��B 
% OUT = GETFIS(FIS, 'vartype', 'varindex', 'mf', 'mfindex') �́A�����o
% �V�b�v�֐� 'mfindex' �̈�ʓI�ȏ��̃��X�g���o�͂��܂��B
% OUT = GETFIS(FIS, 'vartype', 'varindex', 'mf', 'mfindex', 'mfprop') 
% �́A'mfindex' �� 'mf' �ɑ΂��� 'mfprop' �̃J�����g�̒l���o�͂��܂��B
%
% ���
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%    getfis(a)
%
% �Q�l    SETFIS, SHOWFIS.


%   Ned Gulley, 2-2-94, Kelly Liu 7-10-96
%   Copyright 1994-2002 The MathWorks, Inc. 
