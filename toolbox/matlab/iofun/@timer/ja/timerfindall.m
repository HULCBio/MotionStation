%TIMERFINDALL �w�肵���v���p�e�B�l�������ׂĂ� timer �I�u�W�F�N�g�̌���
%
% OUT = TIMERFINDALL �́A�I�u�W�F�N�g�� ObjectVisibility �v���p�e�B�l
% �Ɉ˂炸�A�������ɂ��邷�ׂĂ� timer �I�u�W�F�N�g���o�͂��܂��Btimer
% �I�u�W�F�N�g�́A OUT �ɑ΂���z��Ƃ��ďo�͂���܂��B
%
% OUT = TIMERFINDALL('P1', V1, 'P2', V2,...) �́Atimer �I�u�W�F�N�g�̔z��A
% OUT ���o�͂��܂��B���̃I�u�W�F�N�g�̃v���p�e�B���ƃv���p�e�B�l�́A�p�����[�^
% �ƒl�̑g�AP1, V1, P2, V2,... �Ƃ��ēn�������̂Ɉ�v���܂��B�p�����[�^�ƒl
% �̑g�́A�Z���z��Ƃ��Ďw�肳��܂��B
%
% OUT = TIMERFINDALL(S) �́Atimer �I�u�W�F�N�g�̔z�� OUT ���o�͂��܂��B 
% ���� timer �I�u�W�F�N�g�̃v���p�e�B�l�́A�\���� S �ɒ�`���ꂽ�v���p�e�B
% �l�ƈ�v���܂��BS �̃t�B�[���h���́Atimer �I�u�W�F�N�g�̃v���p�e�B���ł���A
% �t�B�[���h�̒l�́A�v�������v���p�e�B�l�ł��B
%   
% OUT = TIMERFINDALL(OBJ, 'P1', V1, 'P2', V2,...) �́AOBJ �Ƀ��X�g�����
% timer �I�u�W�F�N�g�̃p�����[�^�ƒl�̑g�Ɍ����𐧌����܂��B
% OBJ �́Atimer �I�u�W�F�N�g�̔z��ɂȂ�܂��B
%
% TIMERFINDALL �ւ̓����Ăяo���ɂ����āA�p�����[�^�ƒl�̕�����̑g�A
% �\���́A�p�����[�^�ƒl�̃Z���z��̑g���g�p���邱�Ƃ��ł��邱�Ƃɒ���
% ���Ă��������B
%
% �v���p�e�B�l���w�肳���ꍇ�AGET �̏o�͂Ɠ����������g�p����K�v������܂��B
% ���Ƃ��΁AGET �� 'MyObject' �Ƃ��� Name ��Ԃ��ꍇ�ATIMERFINDALL �́A
% 'myobject'�� Name �v���p�e�B�l�����I�u�W�F�N�g���������܂���B
% �������A���ׂ�ꂽ���X�g�̃f�[�^�^�C�v�����v���p�e�B�́A�v���p�e�B�l��
% �����̏ꍇ�A�啶���Ə���������ʂ��܂���B 
% ���Ƃ��΁ATIMERFINDALL �́A'FixedRate' �܂��� 'fixedrate' �� Parity 
% �v���p�e�B�l�����I�u�W�F�N�g���������܂��B
%
% ���:
%   t1 = timer('Tag', 'broadcastProgress', 'Period', 5);
%   t2 = timer('Tag', 'displayProgress');
%   out1 = timerfindall('Tag', 'displayProgress')
%   out2 = timerfindall({'Period', 'Tag'}, {5, 'broadcastProgress'})
%
% �Q�l TIMERFIND, TIMER/GET.
%

%    RDD 03-27-2003
%    Copyright 2001-2003 The MathWorks, Inc. 
