% TRIPLOT  2�����O�p�`�̃v���b�g
%
% TRIPLOT(TRI,X,Y) �́AM �s3��̍s�� TRI �̒��ɒ�`����Ă�O�p�`��\��
% ���܂��BTRI �̍s�́A1�̎O�p�`���`����C���f�b�N�X�� X,Y�Ɋ܂񂾂���
% �ł��B�f�t�H���g�̃��C���J���[�̓u���[�ł��B 
%
% TRIPLOT(TRI,X,Y,COLOR) �́A������ COLOR ���g���āA���C���J���[��ݒ�
% ���܂��B
%
% H = TRIPLOT(...) �́A�\�������O�p�`�̃n���h���̃x�N�g����߂��܂��B
%
% TRIPLOT(...,'param','value','param','value'...) �́A�v���b�g���쐬����
% �Ƃ��Ɏg�p����t���I�ȃ��C���̃p�����[�^���ƒl��ݒ肵�܂��B
%
% ���F
%
%   rand('state',0);
%   x = rand(1,10);
%   y = rand(1,10);
%   tri = delaunay(x,y);
%   triplot(tri,x,y)
%
% �Q�l�FTRISURF, TRIMESH, DELAUNAY.


%   Copyright 1984-2002 The MathWorks, Inc. 
