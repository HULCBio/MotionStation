%WRITE   WPTREE �I�u�W�F�N�g�t�B�[���h�̒l�̏�������
%   T = write(T,'cfs',NODE,COEFS) �́A���[�m�[�h NODE �ɑ΂���W��������%   ���݂܂��B
%
%   T = write(T,'cfs',N1,CFS1,'cfs',N2,CFS2, ...) �́A���[�m�[�h N1,N2,
%   ... �ɑ΂���W�����������݂܂��B
%
%   ����:
%     �W���l�́A�C�ӂ̃T�C�Y�������܂��B
%     �����̃T�C�Y���擾���邽�߂ɁAS = READ(T,'sizes',NODE) �܂��́A
%     S = READ(T,'sizes',[N1;N2; ... ]) ���g���܂��B
%
%   ���:
%     % �E�F�[�u���b�g�p�P�b�g�c���[�̍쐬
%     x = rand(1,512);
%     t = wpdec(x,3,'db3');
%     t = wpjoin(t,[4;5]);
%     plot(t);
%
%     % �l�̏�������
%     sNod = read(t,'sizes',[4,5]);
%     cfs4  = zeros(sNod(1,:));
%     cfs5  = zeros(sNod(2,:));
%     t = write(t,'cfs',4,cfs4,'cfs',5,cfs5);
%
%   �Q�l: DISP, GET, READ, SET

%   INTERNAL OPTIONS :
%----------------------
%   The valid choices for PropName are:
%     'ent', 'ento', 'sizes':
%        Without PropParam or with PropParam = Vector of nodes indices.
%
%     'cfs':  with PropParam = One node indices.
%       ,
%     'allcfs', 'entName', 'entPar', 'wavName': without PropParam.
%     
%     'wfilters':
%        without PropParam or with PropParam = 'd', 'r', 'l', 'h'.
%
%     'data' :
%        without PropParam or
%        with PropParam = One terminal node indices or
%             PropParam = Vector terminal node indices.
%        In the last case, the PropValue is a cell array.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.


%   Copyright 1995-2002 The MathWorks, Inc.
