%ORDQZ  QZ �����ɂ�����ŗL�l�̕��בւ�
% [AAS,BBS,QS,ZS] = ORDQZ(AA,BB,Q,Z,SELECT) �́A�s��̑g (A,B) �� QZ
% ���� Q*A*Z = AA, Q*B*Z = BB ����בւ��A�ŗL�l�̑I�����ꂽ�N���X�^��
% quasitriangular �̑g (AA,BB)�� leading (����) �Ίp�u���b�N�Ɍ���A
% �Ή�����s�ϕ�����Ԃ́AZ �� leading columns �ɂ��X�p������܂��B
% �_���x�N�g�� SELECT �́A�I�����ꂽ�N���X�^�� E(SELECT) �Ƃ��Ďw�肵�܂��B
% �����ŁAE = EIG(AA,BB) �ł��B
%
% ORDQZ �́AQZ �R�}���h�ɂ�萶�����ꂽ�s�� AA,BB,Q,Z ���Ƃ�A
% QS*A*ZS = AAS, QS*B*ZS = BBS �𖞂����A���בւ���ꂽ�g (AAS,BBS) 
% �� cumulative ����ϊ� QS ����� ZS ���o�͂��܂��B
% (AA,BB) �� (AAS,BBS) �ɕϊ����� incremental QS,ZS �𓾂邽�߂ɂ́A
% Q=[] �܂��́AZ=[] �Ɛݒ肵�Ă�������
% 
% [AAS,BBS,...] = ORDQZ(AA,BB,Q,Z,KEYWORD) �́A���̗̈�̂����ꂩ
% 1�ɁA���ׂĂ̌ŗL�l���܂ނ悤�ɑI�����ꂽ�N���X�^��ݒ肵�܂��B
%
%     KEYWORD           �I��̈�
%      'lhp'            ��������  (real(E)<0)
%      'rhp'            �E������  (real(E)>0)
%      'udi'            �P�ʉ~�̓��� (abs(E)<1)
%      'udo'            �P�ʉ~�̊O�� (abs(E)>1)
%
% ORDQZ �́A�����̃N���X�^�𒼂��ɕ��בւ��邱�Ƃ��ł��܂��B
% �N���X�^�C���f�b�N�X�̃x�N�g�� CLUSTERS ���^������ƁAE = EIG(AA,BB)
% �ɔ�Ⴕ�A���� CLUSTERS �l�����ŗL�l���ׂĂ�1�̃N���X�^���`��
% ����悤�ȏꍇ�A[...] = ORDQZ(AA,BB,Q,Z,CLUSTERS) �́A�㍶�p�Ɍ����
% �ō��̃C���f�b�N�X�����N���X�^�A(AAS,BBS)�̑Ίp�ɉ����āA�~����
% �w��N���X�^���\�[�g���܂��B
%
%   �Q�l QZ, ORDSCHUR.

%   Copyright 1984-2002 The MathWorks, Inc. 
