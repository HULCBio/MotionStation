% SS   ��ԋ�ԃ��f�����쐬�A�܂��́ALTI���f������ԋ�ԃ��f���ɕϊ�
%
%
% �쐬:
% SYS = SS(A,B,C,D) �́AA, B, C, D �s�񂩂�Ȃ�A�����ԏ�ԋ��(SS)���f��
% SYS ���쐬���܂��B�o�� SYS ��SS�I�u�W�F�N�g�ł��B
% D = 0 �Őݒ肷�邱�Ƃ��ł��A���̏ꍇ�A�K���Ȏ����̃[���s����Ӗ����܂��B
%
% SYS = SS(A,B,C,D,Ts) �́A�T���v������ Ts �̗��U����SS���f�����쐬���܂�
% (�T���v�����Ԃ𖢒�`�ɂ��邽�߂ɂ́ATs = -1�ɐݒ肵�Ă�������)�B
%
% SYS = SS �́A���SS�I�u�W�F�N�g���쐬���܂��B
% SYS = SS(D) �́A�ÓI�Q�C���s�� D ���`���܂��B
%
% ��L�̂��ׂĂ̏����ł́ASS���f���̗l�X�ȃv���p�e�B��ݒ肷�邽�߂ɁA���̑g
% �ݍ��킹�œ��͈����ɑ����ċL�q���邱�Ƃ��ł��܂��B 'PropertyName1',
% PropertyValue1, ... (�ڍׂ́ALTIPROPS �ƃ^�C�v���Ă�������)�B
% ������LTI���f�� REFSYS ���炷�ׂĂ�LTI�v���p�e�B���p������ SYS ���쐬����
% ���߂ɂ́A���� SYS = SS(A,B,C,D,REFSYS)�𗘗p���Ă��������B
%
% ��ԋ�ԃ��f���̔z��:
% ��L�� A, B, C, D �ɑ΂��āAND �z��𗘗p���邱�Ƃɂ���ԋ�ԃ��f���̔z
% ����쐬���邱�Ƃ��ł��܂��BA, B, C, D �̍ŏ���2�̎�������Ԑ��Ɠ��o�͐�
% �����肵�A�c��̎������z��T�C�Y�����肵�܂��B���Ƃ��΁AA, B,C, D ��4������
% �z��ŁA�Ō��2�̎���������2��5�̂Ƃ��A SYS = SS(A,B,C,D) �́A2�s5��̔z��
% ��SS���f�����쐬���܂��B SYS(:,:,k,m) = SS(A(:,:,k,m),...,D(:,:,k,m)),
% k = 1:2,  m = 1:5���ʂ�SS�z��̂��ׂẴ��f���́A�������o�͐��Ə�Ԑ��ɂ�
% ��܂��B
%
% SYS = SS(ZEROS([NY NU S1...Sk])) �́ANU ���� NY �o�͂Ŕz��̃T�C�Y��[S1.
% ..Sk]�ł���SS�z��̂��߂̃f�[�^�̈���m�ۂ��܂��B
%
% �ϊ�:
% SYS = SS(SYS) �́A�C�ӂ�LTI���f�� SYS ����ԋ�Ԃɕϊ����܂��B ���Ȃ킿�A
% SYS �̏�ԋ�Ԏ������v�Z���܂��B
%
% SYS = SS(SYS,'min') �́ASYS �̍ŏ��������v�Z���܂��B
%
% �Q�l : LTIMODELS, DSS, RSS, DRSS, SSDATA, LTIPROPS, TF, ZPK, FRD.


% Copyright 1986-2002 The MathWorks, Inc.
