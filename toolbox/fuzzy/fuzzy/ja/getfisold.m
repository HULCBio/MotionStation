% getfisold �́A�t�@�W�B���_�V�X�e���̃v���p�e�B���擾���܂��B
% 
% OUT = getfisold(FIS) �́A�t�@�W�C���_�V�X�e�� FIS �Ɋւ����ʓI�ȏ��
% ���o�͂��܂��BOUT = getfisold(FIS,'fisProp') �́A'fisProp' �Ɩ��t���� 
% FIS �v���p�e�B�̃J�����g�l���o�͂��܂��B
% 
% OUT = getfisold(FIS,'varType',varIndex) �́A�w�肵�� FIS �ϐ��Ɋւ���
% ��ʓI�ȏ��̃��X�g���o�͂��܂��B
% OUT = getfisold(FIS,'varType',varIndex,'varProp') �́A'varProp' �Ɩ��t
% �����ϐ��v���p�e�B�̃J�����g�l���o�͂��܂��B
%
% OUT = getfisold(FIS,'varType',varIndex,'mf',mfIndex) �́A�w�肵�� FIS 
% �����o�V�b�v�֐��Ɋւ����ʓI�ȏ��̃��X�g���o�͂��܂��B
% OUT = getfisold(FIS,'varType',varIndex,'mf',mfIndex,'mfProp') �́A'mf-
% Prop' �Ɩ��t���������o�V�b�v�֐��̃v���p�e�B�̃J�����g�l���o�͂��܂��B
% 
% ���:
%        a = newfis('tipper');
%        a = addvar(a,'input','service',[0 10]);
%        a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%        a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%        getfisold(a)
%        getfisold(a,'input',1)
%        getfisold(a,'input',1,'mf',2)
%
% �Q�l     SETFIS, SHOWFIS.

