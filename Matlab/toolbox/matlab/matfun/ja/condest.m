% CONDEST �́A1�m�����̏��������v�Z���܂��B
% C = CONDEST(A) �́A�����s�� A ��1�m�����̏������ɑ΂��āA���� C 
% ���v�Z���܂��B
%
% C = CONDEST(A,T) �́AT �𐳂̐����Ƃ��āA�J��Ԃ��s��̒��ŕύX��
% ���̔ԍ����w�肵�܂��B�񐔂𑝉����邱�Ƃ́A�ʏ�A�ǂ����ʂ�^����
% �����A�v�Z���Ԃ������Ȃ�܂��B�ʏ�A�f�t�H���g�� T = 2 �ŁA�䗦2�ȓ�
% �Ő���������𓾂邱�Ƃ��ł��܂��B
%
% [C,V] = CONDEST(A) �́AC ���傫���ꍇ�͋ߎ��I�ȃk���x�N�g���ł���x
% �N�g�� V ���v�Z���܂��BV �́ANORM(A*V,1) = NORM(A,1)*NORM(V,1)/C ��
% �������܂��B
%
% ���ӁFCONDEST �́ARAND ���N�����܂��B�J��Ԃ��̌��ʂ��K�v�ɂȂ�ꍇ
% �́A���̊֐����Ăяo���O�ɁAJ �ɑ΂��� RAND('STAYE',J) ���Ăэ��݂܂��B
%
% Higham��Tisseur�̃u���b�N������1�m�����p���[�@���g���Ă��܂��B
%
% �Q�l�FNORMEST1, COND, NORM.

%   Nicholas J. Higham, 9-8-99
%   Copyright 1984-2003 The MathWorks, Inc. 
