% BITERR   �r�b�g�G���[�̐��ƃr�b�g�G���[���[�g���v�Z
%
% [NUMBER,RATIO] = BITERR(X,Y) �́A2�̍s�� X �� Y �̊e�v�f�̕����Ȃ�
% �o�C�i���\�����r���܂��B�o�C�i���\���ł̈Ⴂ�����������ANUMBER ��
% �o�͂���܂��B
% NUMBER �ƁA�o�C�i���\���Ŏg����r�b�g�̑����Ƃ̔䂪�ARATIO �ɏo��
% ����܂��B
% X �� Y �̗����̊e�v�f��\�����邽�߂ɁA�����r�b�g�����g���܂��B�g�p
% �����r�b�g���́AX�A�܂��� Y �̓��A�ǂ��炩�傫���ق��̗v�f��\������
% ���߂ɕK�v�Ƃ���ŏ����ł��B2�̓��͂̓��̈�����s��ŁA�������x�N�g��
% �̏ꍇ�A���̊֐��́A�x�N�g���̕����ƈ�v��������ɁA������A�܂��́A
% �s�����ɔ�r���܂��B
%
% ������F
% 2�̓��͂̓��̈���s��ŁA���̂��̂����͍s��̍s���Ɠ����v�f����
% ����x�N�g���̏ꍇ�A������̔�r���s���܂��B���̃��[�h�ŁA���͂�
% ��x�N�g���̃o�C�i���\���́A���͍s��̊e��̃o�C�i���\���Ɣ�r���܂��B
% �f�t�H���g�ŁA�e��̔�r�̌��ʂ��o�͂���ANUMBER �� RATIO �͋��ɍs�x�N
% �g���ł��B���̃f�t�H���g�����������A�S�̂̌��ʂ��o�͂���ɂ́A
% 'overall' �t���O���g���܂�(���Ɏ���)�B
% 
% �s�����F
% ���͂̈���s��ŁA�����A�s��̗񐔂Ɠ����v�f�������s�x�N�g���̏ꍇ�A
% �s�����̔�r�ɂȂ�܂��B���̃��[�h�ŁA���͂̍s�x�N�g���̃o�C�i���\���́A
% ���͍s��̊e�s�̃o�C�i���\���Ɣ�r����܂��B�f�t�H���g�ŁA�e�s�̔�r��
% ���ʂ��ANUMBER �� RATIO ���ɗ�x�N�g�������ďo�͂���܂��B���̃f�t�H���g
% ��Ԃ����������āANUMBER �� RATIO �̑S�̂��o�͂���ɂ́A'overall' �t���O
% ���g���܂�(���Ɏ���)�B
%
% 2�̍s��ɉ����āA2�̃I�v�V�����p�����[�^��^���邱�Ƃ��ł��܂��B
%
% [NUMBER,RATIO] = BITERR(...,K) �e�v�f��\�����邽�߂Ɏg�p����r�b�g��
% ���AK �Őݒ�ł��܂��BK �́A2�̓��͍s��̒��̍ő�v�f��\�����邽��
% �ɕK�v�ȍŏ��̃r�b�g�������傫�����̃X�J�������ł��B
%
% [NUMBER,RATIO] = BITERR(...,FLAG) �́AFLAG ���g���āA��r�Ɋւ��郌�|�[�g
% ���e��ݒ�ł��܂��BFLAG �́A3�̒l�A'column-wise','row-wise','overall'
% ��ݒ肷�邱�Ƃ��ł��܂��BFLAG ��'column-wise'��ݒ肷��ƁABITERR �́A
% �e����r���A�s�x�N�g���Ƃ��āA���ʂ��o�͂��܂��BFLAG �� 'row-wise' ��
% �ݒ肷��ƁABITERR �́A�e�s���r���āA��x�N�g�����o�͂��܂��B�܂��A
% 'overall' ��ݒ肷��ƁABITERR �́A���ׂĂ̗v�f���r���āA���ʂ��X�J��
% �Ƃ��ďo�͂��܂��B
%
% [NUMBER,RATIO,INDIVIDUAL] = BITERR(...) �́A�X�̃o�C�i����r�̌��ʂ�
% �\���s��� INDIVIDUAL �ɏo�͂��܂��B2�̗v�f�������ꍇ�AINDIVIDUAL ��
% �Ή�����v�f�̓[���ɂȂ�܂��B2�̗v�f���قȂ�ꍇ�AINDIVIDUAL �̑Ή�
% ����v�f�̓o�C�i���\���ňقȂ�v�f�̐��ƂȂ�܂��BINDIVIDUAL �́A���[�h
% �Ɋւ�炸�A��ɍs��ł��B
%
% ���F
%    >> A = [1 2 3; 1 2 2];
%    >> B = [1 2 0; 3 2 2];
%
%    >> [Num,Rat] = biterr(A,B)       >> [Num,Rat] = biterr(A,B,3)
%    Num =                            Num =  
%         3                                3
%    Rat =                            Rat = 
%        0.2500                           0.1667
%
%    >> [Num,Rat,Ind] = biterr(A,B,3,'column-wise')
%    Num =
%         1      0      2
%    Rat =
%        0.1667  0     0.3333
%    Ind =
%         0      0      2
%         1      0      0
%
% �Q�l�F SYMERR.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/06/23 04:34:12 $
