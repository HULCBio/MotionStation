% TFORMFWD  �t�H���[�h��ԕϊ���K�p
% U ���A�s��̏ꍇ�AX = TFORMFWD(U,T) �́AT �ɒ�`�����t�H���[�h�ϊ��� 
% U �̊e�s�ɓK�p���܂��BT �́AMAKETFORM, FLIPTFORM, CP2TFORM �ō쐬����
% �� TFORM �\���̂ł��BU �́AM �s T.ndims_in ��̍s��ŁAU �̊e�s�́AT 
% �̓��͋�Ԃ̓_��\���Ă��܂��BX �́AM �s T.ndims_out ��̍s��ŁA�e�s
% �́AT �̏o�͋�Ԃ̒��̓_��\���܂��B�����āAU �̑Ή�����s�̃t�H���[�h
% �ϊ��ɂȂ�܂��B
%
% U ���A(N+1)-�����̔z��(T.ndims_in ���A1 �̏ꍇ�A�C���v���V�b�g�ȃV���O
% ���g���������܂�)�̏ꍇ�ATFORMFWD �́A�e�_ U(P1,P2,...,PN,:) �ɕϊ���K
% �p���܂��BSIZE(U,N+1) �́AT.ndims_in �Ɠ������Ȃ�K�v������܂��BX �́A
% X(P1,P2,...PN,:) �Ɋe�ϊ��̌��ʂ��܂� (N+1)-�����z��ɂȂ�܂��BSIZE(X,
% I) �́AI = 1,...,N �ɑ΂��āASIZE(U,I) �Ɠ������ASIZE(X,N+1) �́AT.nd-
% ims_out �Ɠ������Ȃ�܂��B
% 
% ���
% -------
% (0,0), (6,3), (-2,5)�𒸓_�Ƃ���O�p�`��(-1,-1), (0,-10), (-2,5)�𒸓_
% �Ƃ���O�p�`�Ɏʑ�����A�t�B���ϊ����쐬���܂��B
%
%       u = [0 0; 6 3; -2 5];
%       x = [-1 -1; 0 -10; 4 4];
%       tform = maketform('affine',u,x);
%   
% TPORMFWD �� u �ɓK�p���邱�Ƃɂ��A�}�b�s���O�����؂��܂��B
%
%       tformfwd(u,tform)  % ���ʂ́Ax �Ɠ������͂��ł��B
%
% �Q�l�F TFORMINV, MAKETFORM, FLIPTFORM, CP2TFORM.



%   Copyright 1993-2002 The MathWorks, Inc.
