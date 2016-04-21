% ZPK   ��-��_-�Q�C���^���f���ɕϊ��A�܂��͍쐬
%
%
% �쐬:
% SYS = ZPK(Z,P,K) �́A��_ Z�A�� P�A�Q�C�� K �̘A�����ԋ�-��_-�Q�C���^(
% ZPK)���f�� SYS ���쐬���܂��B�o�� SYS ��ZPK�I�u�W�F�N�g�ł��B
%
% SYS = ZPK(Z,P,K,Ts) �́A�T���v������ Ts �̗��U����ZPK���f�����쐬���܂�
% (�T���v�����Ԃ𖢒�`�ɂ���ꍇ�ATs = -1�ɐݒ肵�Ă�������)�B
%
% S = ZPK('s') �́AH(s) = s (���v���X���Z�q)���`���܂��B
% Z = ZPK('z',TS) �́A�T���v������ TS �� H(z) = z ���`���܂��B
% ZPK���f�����A���̂悤�ɊȒP�ɕ\���ł��܂��B S �܂��� Z �𗘗p���āA���Ƃ�
% �΁A z = zpk('z',0.1);  H = (z+.1)*(z+.2)/(z^2+.6*z+.09)
%
% SYS = ZPK �́A��̋�-��_-�Q�C�����f�����쐬���܂��B
% SYS = ZPK(D) �́A�ÓI�Q�C���s�� D ���`���܂��B
%
% ��L�̂��ׂĂ̏����ŁA���̓��X�g�͑g�ɂ��đ����邱�Ƃ��ł��܂��B '
% PropertyName1', PropertyValue1, ... ����ɂ��AZPK���f���̗l�X�ȃv���p�e�B
% (�ڍׂ́ALTIPROPS ���Q��)��ݒ肵�܂��B������ LTI ���f�� REFSYS �̂��ׂĂ�
% LTI �v���p�e�B���p������SYS ���쐬���邽�߂ɂ́ASYS = ZPK(NUM,DEN,
% REFSYS) �̏����𗘗p���܂��B
%
% �f�[�^�t�H�[�}�b�g:
% SISO���f���ɑ΂��āAZ �� P �́A��_�Ƌɂ̃x�N�g����(��_���Ȃ��Ƃ���
% z = [] �Ɛݒ肵�Ă�������)�AK �̓X�J���̃Q�C���ł��B
%
% NU ���� NY �o�͂�MIMO�V�X�e���ɑ΂��ẮA* Z �� P �́ANY*NU �̃Z���z��ŁA
% Z{i,j} �� P{i,j} �́A���� j ����o�� i�܂ł̓`�B�֐��̗�_�Ƌɂ�\���܂��B
% * K �́A�e I/O �`�����l���ɑ΂���Q�C����2�����s��ł��B���Ƃ��΁A
% H = ZPK( {[];[2 3]} , {1;[0 -1]} , [-5;1] ) �́A����1����2�o�͂̋�-��_
% -�Q�C�����f�����`���܂��B [    -5 /(s-1)      ] [ (s-2)(s-3)/s(s+1) ]
%
% ��-��_-�Q�C�����f���̔z��:
% ��L�� Z, P �ɑ΂��� ND �Z���z����A K �ɑ΂��� ND �z��𗘗p���邱�ƂŁA
% ZPK���f���̔z����쐬���邱�Ƃ��ł��܂��B���Ƃ��΁AZ, P, K ���T�C�Y
% [NY NU 5] ��3�����z��Ƃ���ƁA SYS = ZPK(Z,P,K) �́AZPK���f����5�s1��̔z
% ����쐬���܂��B SYS(:,:,m) = ZPK(Z(:,:,m),P(:,:,m),K(:,:,m)),   m = 1:
% 5.�����̌X�̃��f���́ANU ���� NY �o�͂ɂȂ�܂��B
%
% NU ���� NY �o�͂�����ZPK���f���ɁA�[���s������炩���ߊ��蓖�Ă�ɂ́A��
% �̏�����p���Ă��������B SYS = ZPK(ZEROS([NY NU k1 k2...])) . .
%
% �ϊ�:
% SYS = ZPK(SYS) �́A�C�ӂ�LTI���f�� SYS ��ZPK�\���ɕϊ����܂��B
% ���ʂ́AZPK�I�u�W�F�N�g�ɂȂ�܂��B
%
% SYS = ZPK(SYS,'inv') �́A��ԋ�Ԃ���ZPK���f���ւ̕ϊ��ɍ����ȃA���S���Y��
% ��p���܂����A�����̃V�X�e���ɑ΂��ẮA���x�������܂��B
%
% �Q�l : LTIMODELS, SET, GET, ZPKDATA, SUBSREF, SUBSASGN, LTIPROPS, TF, SS.


% Copyright 1986-2002 The MathWorks, Inc.
