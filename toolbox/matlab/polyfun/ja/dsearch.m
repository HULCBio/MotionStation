% DSEARCH �ŋߖT��p����Delaunay�O�p�����̌���
% 
% K = DSEARCH(X,Y,TRI,XI,YI) �́A�f�[�^�_ (xi,yi) �̍ŋߖT�̃f�[�^�_ 
% (x,y) �̃C���f�b�N�X���o�͂��܂��BDSEARCH �ɂ́ADELAUNAY ���瓾��ꂽ
% �f�[�^�_ X, Y ����Ȃ�O�p�`���� TRI ���K�v�ł��B
%
% K = DSEARCH(X,Y,TRI,XI,YI,S) �́A����v�Z�������ɁA�X�p�[�X�s�� 
% S ���g���܂��B
% 
%    S = sparse(tri(:,[1 1 2 2 3 3]),tri(:,[2 3 1 3 1 2]),1,nxy,nxy) 
%
% �����ŁAnxy = prod(size(x)) �ł��B
%
% �Q�l�FTSEARCH, DELAUNAY, VORONOI.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 02:01:23 $
