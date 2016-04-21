%ORDSCHUR  Schur �����ɂ�����ŗL�l�̕��בւ�
% [US,TS] = ORDSCHUR(U,T,SELECT) �́A�s�� X �� Schur ���� X = U*T*U'
% ����בւ��A�ŗL�l�̑I�����ꂽ�N���X�^���Aquasitriangular Schur �s��
% T ��leading (�����) �Ίp�u���b�N�Ɍ���A�Ή�����s�ϕ�����Ԃ��A 
% U �� leading columns �ɂ��X�p������܂��B �_���x�N�g�� SELECT �́A
% �I�����ꂽ�N���X�^�� E(SELECT) �Ƃ��Ďw�肵�܂��B
% �����ŁAE = EIG(T) �ł��B
%
% ORDSCHUR �́ASCHUR �R�}���h�ɂ�萶�����ꂽ�s��U,T���Ƃ�A
% X = US*TS*US' �𖞂����A���בւ���ꂽ Schur �s�� TS �� 
% cumulative ����ϊ� US ���o�͂��܂��Bincremental �ϊ� 
% T = US*TS*US' �𓾂邽�߂ɂ́AU=[]�Ɛݒ肵�Ă��������B
% 
% [US,TS] = ORDSCHUR(U,T,KEYWORD) �́A���̗̈�̂����ꂩ1�ɂ��ׂ�
% �̌ŗL�l���܂ނ悤�ɑI�������N���X�^��ݒ肵�܂��B
%
%     KEYWORD           �I��̈�
%      'lhp'            ��������  (real(E)<0)
%      'rhp'            �E�����ʁ@(real(E)>0)
%      'udi'            �P�ʉ~�̓��� (abs(E)<1)
%      'udo'            �P�ʉ~�̊O�� (abs(E)>1)
%
% ORDSCHUR �́A�����̃N���X�^�𒼂��ɕ��בւ��邱�Ƃ��ł��܂��B
% �N���X�^�C���f�b�N�X�̃x�N�g�� CLUSTERS ���^�����AE = EIG(T) 
% �ɔ�Ⴕ�A���� CLUSTERS �l�����ŗL�l���ׂĂ�1�̃N���X�^���`��
% ����悤�ȏꍇ�A[US,TS] = ORDSCHUR(U,T,CLUSTERS) �́A�㍶�p�Ɍ����
% �ō��̃C���f�b�N�X�����N���X�^�ATS �̑Ίp�ɉ����āA�~����
% �w��N���X�^���\�[�g���܂��B
%
% �Q�l SCHUR, ORDQZ.

%   Copyright 1984-2002 The MathWorks, Inc. 
