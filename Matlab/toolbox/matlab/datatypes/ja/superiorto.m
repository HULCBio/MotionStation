% SUPERIORTO   ��ʃN���X�̊֌W
%
% SUPERIORTO('CLASS1','CLASS2',...) ���A�N���X�R���X�g���N�^���\�b�h
% (myclass.m)�ɌĂяo�����ƁAmyclass �̃I�u�W�F�N�g��A�N���X CLASS1�A
% CLASS2 ����1�ȏ�̃I�u�W�F�N�g�Ƌ��Ɋ֐����R�[�����ꂽ�ꍇ�ɂ́A
% myclass ���\�b�h���Ăяo����܂��B
%
% A�̃N���X��'class_a'�ŁAB�̃N���X��'class_b'�AC�̃N���X��'class_c'��
% ����Ɖ��肵�܂��B�܂��Aclass_c.m���X�e�[�g�����g
%
%      SUPERIORTO('CLASS_A')
%
% ���܂ޏꍇ�AE = FUN(A,C)�A�܂��́AE = FUN(C,A)�́ACLASS_C/FUN���Ă�
% �o���܂��B
%
% �w�肳��Ă��Ȃ��֌W������2�̃I�u�W�F�N�g�Ƌ��Ɋ֐����R�[�������ƁA
% 2�̃I�u�W�F�N�g�͓����̗D�挠�����ƍl�����A��ԍ��̃I�u�W�F�N�g
% �̃��\�b�h���R�[������܂��BFUN(B,C)�́ACLASS_B/FUN���Ăяo���AFUN(C,B)
% ��CLASS_C/FUN���Ăяo���܂��B
%
% �Q�l�FINFERIORTO.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:47:54 $
%   Built-in function.
