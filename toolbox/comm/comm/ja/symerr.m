% SYMERR   �V���{���G���[���ƃV���{���G���[���[�g���v�Z
%
% [NUMBER,RATIO] = SYMERR(X,Y) �́A2�̍s�� X �� Y �̒��̗v�f�̔�r����
% �܂��B�قȂ�v�f�����ANUMBER �ɏo�͂���܂��BNUMBER �Ɨv�f�̑����̔䂪
% RATIO �ɏo�͂���܂��B���͂̈���s��ŁA���̂��̂��x�N�g���̏ꍇ�A
% �֐��́A�x�N�g���̕���(�s�x�N�g���܂��͗�x�N�g��)���x�[�X�ɔ�r���܂��B
% 
% ������F
% 2�̓��͂̓��̈���s��ŁA���̂��̂����͍s��̍s���Ɠ����v�f��������
% ��x�N�g���̏ꍇ�A������̔�r���s���܂��B���̃��[�h�ŁA��x�N�g���́A
% ���͍s��̊e��Ɣ�r���܂��B�f�t�H���g�ŁA�e��̔�r�̌��ʂ��o�͂���A
% NUMBER �� RATIO �͋��ɍs�x�N�g���ł��B���̃f�t�H���g�����������A�S�̂�
% ���ʂ��o�͂���ɂ́A(���Ɏ���) 'overall' �t���b�O���g���܂��B
%
% �s�����F
% ���͂̈���s��ŁA�����A�s��̗񐔂Ɠ����v�f�������s�x�N�g���̏ꍇ�A
% �s�����̔�r�ɂȂ�܂��B���̃��[�h�ŁA�s�x�N�g���́A���͍s��̊e�s��
% ��r����܂��B�f�t�H���g�ŁA�e�s�̔�r�̌��ʂ��ANUMBER �� RATIO ����
% ��x�N�g�������ďo�͂���܂��B���̃f�t�H���g��Ԃ����������āANUMBER  
% �� RATIO �̑S�̂��o�͂���ɂ́A(���Ɏ���) 'overall' �t���b�O���g���܂��B
% 
% 2�̍s��ɉ����āA2�̃I�v�V�����p�����[�^��^���邱�Ƃ��ł��܂��B
%
% [NUMBER,RATIO] = SYMERR(...,FLAG) �́AFLAG ���g���āA��r�Ɋւ���
% ���|�[�g���e��ݒ�ł��܂��BFLAG �́A3�̒l�A'column-wise','row-wise',
% 'overall'��ݒ肷�邱�Ƃ��ł��܂��BFLAG ��'column-wise'��ݒ肷��ƁA
% SYMERR �́A�e����r���A�s�x�N�g���Ƃ��āA���ʂ��o�͂��܂��BFLAG ��
% 'row-wise'��ݒ肷��ƁASYMERR �́A�e�s���r���āA��x�N�g�����o�͂�
% �܂��B�܂��A'overall' ��ݒ肷��ƁASYMERR �́A���ׂĂ̗v�f���r���āA
% ���ʂ��X�J���Ƃ��ďo�͂��܂��B
%
% [NUMBER,RATIO,INDIVIDUAL] = SYMERR(...) �́A�X��2�l��r�̌��ʂ�\��
% �s��� INDIVIDUAL �ɏo�͂��܂��B2�̗v�f�������ꍇ�AINDIVIDUAL �̑Ή�
% ����v�f�̓[���ɂȂ�܂��B�قȂ�ꍇ�́A�قȂ�2�l�̐���v�f�Ƃ��܂��B
% INDIVIDUAL �́A���[�h�Ɋւ�炸�A��ɍs��ɂȂ�܂��B
%
% ���F
%    >> A = [1 2 3; 1 2 2];
%    >> B = [1 2 0; 3 2 2];
%
%    >> [Num,Rat] = symerr(A,B)
%    Num =  
%         2  
%    Rat =    
%        0.3333 
%
%    >> [Num,Rat,Ind] = symerr(A,B,'column-wise')
%    Num =
%         1      0      1
%    Rat =
%        0.5000  0     0.5000
%    Ind =
%         0      0      1
%         1      0      0
%
% �Q�l�F BITERR.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/06/23 04:35:19 $
