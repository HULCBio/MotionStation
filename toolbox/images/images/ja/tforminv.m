% TFORMINV �@��ԓI�ȋt�ϊ���K�p
% X ���s��̏ꍇ�AU = TFORMINV( X, T ) �́AX �̊e�s�� T �Œ�`�����t�ϊ�
% ��K�p���܂��BT �́AMAKETFORM, FLIPTFORM, CP2TFORM �ō쐬���� TFORM �\
% ���̂ł��BX �́AM �s T.ndims_out ��ŁAX �̊e�s�́AT �̏o�͋�Ԃ̓_��\
% ���܂��BU �́AM �s T.ndims_out ��̍s��ŁAU �̊e�s�́AT �̓��͋�Ԃ̒�
% �̓_��\���܂��B�����āAX �̑Ή�����s�̋t�ϊ��ɂȂ�܂��B
%
% X ���A(T.ndims_out ��1�̏ꍇ�A�C���v���V�b�g�Ɍ�ɑ����V���O���g������
% ���܂�)(N+1)�����̔z��̏ꍇ�ATFORMINV �́A�e�_ X(P1,P2,...,PN,:) �ɕ�
% ����K�p���܂��BSIZE(X,N+1) �́AT.ndims_in �Ɠ������Ȃ�܂��BU �́AU
% (P1,P2,...PN,:) �̒��̊e�ϊ��̌��ʂ��܂�(N+1)�����z��ł��BSIZE(U,I) 
% �́ASIZE(X,I) �ɓ������Ȃ�܂��BI = 1,...,N �ŁASIZE(U,N+1) �́AT.ndi-
% ms_in �Ɠ����ł��B
% 
% ���
% -------
% (0,0), (6,3), (-2,5)�𒸓_�Ƃ���O�p�`��((-1,-1), (0,-10), (-2,5)��
% �_�Ƃ���O�p�`�Ɏʑ�����A�t�B���ϊ����쐬���܂��B
%
%       u = [0 0; 6 3; -2 5];
%       x = [-1 -1; 0 -10; 4 4];
%       tform = maketform('affine',u,x);
%   
% TFORMINV �� x �ɓK�p���āA���ʂ����؂��܂��B
%
%       tforminv(x,tform)  % ���ʂ́Au �Ɠ������Ȃ�͂��ł��B
%
% �Q�l�F TFORMINV, MAKETFORM, FLIPTFORM, CP2TFORM.



%   Copyright 1993-2002 The MathWorks, Inc.
