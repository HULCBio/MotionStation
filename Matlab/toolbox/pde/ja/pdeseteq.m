% PDESETEQ �́APDE Toolbox �� PDE �������̌W����ݒ肵�܂��B
%
%     PDESETEQ(TYPE,C,A,F,D,TLIST,U0,UT0,RANGE)
%
%     PDE (�Δ���������) �́A���� TYPE �ɂ���X�ɐݒ肳��܂��B
%         TYPE: 1 = �ȉ~
%               2 = ������
%               3 = �o�Ȑ�
%               4 = �ŗL�l PDE ���
% 
% �p�����[�^ C, A, F, D �́APDE ����2�����̈���`���܂��B�W���͕���
% ��܂��͎���(���f��)�̂����ꂩ�ŗ^�����܂��B
% TLIST �́A�_�C�i�~�b�N PDE ���ɑ΂�������v�Z����ߒ��̎��ԗ�ł��B
% U0 �� UT0�́A�����l u(t0) �� du(t0)/dt �ł��BRANGE �́A�ŗL�l�A���S��
% �Y���p�̎������̃T�[�`�͈͂��`����2�v�f�x�N�g���ł��B������œ��͂�
% �Ă��������B
%
% �g�p���Ȃ��W���́A��s��œ��͂��Ă��������B
%
% ��� : 
% pdeseteq(2,0,0,'2*sin(pi*x)','logspace(-2,0,20)',0,[],[]) �́A������ 
% PDE ���`���Ă��܂��B
% 

%       Copyright 1994-2001 The MathWorks, Inc.
