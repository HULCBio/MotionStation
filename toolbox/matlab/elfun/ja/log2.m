% LOG2   2���Ƃ����ΐ��ƕ��������l�̕���
% 
% Y = LOG2(X)�́AX�̗v�f��2���Ƃ����ΐ����o�͂��܂��B
%
% �����z��X�̊e�v�f�ɑ΂��āA [F,E] = LOG2(X)�́A�ʏ�0.5 < =  abs(F) < 1
% �ł�������z��F�ƁA�����̔z��E���o�͂��A�����̊֌W�́AX = F .* 2.^E
% �ɂȂ�܂��BX�̗v�f�Ƀ[��������ƁAF = 0����E = 0�ɂȂ�܂��B����́A
% ANSI C�̊֐�frexp()��AIEEE�̕��������_�W���̊֐�logb()�ɑ������܂��B
%
% �Q�l�FLOG, LOG10, POW2, NEXTPOW2, REALMAX, REALMIN.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:50:31 $
%   Built-in function.
