% DDEX1  DDE23�ɑ΂�����1
% ����́A�x������������(DDE)�̃V�X�e���̉��̊ȒP�Ȓ莮���A�v�Z�A
% �v���b�g��������� Wille' and Baker�̗��ł��B 
%
% ����������
%
%        y'_1(t) = y_1(t-1)  
%        y'_2(t) = y_1(t-1)+y_2(t-0.2)
%        y'_3(t) = y_2(t)
%
% �́A t <= 0 �ɑ΂��� history y_1(t) = 1, y_2(t) = 1, y_3(t) = 1 ��
% ���� [0, 5] �ŉ�����܂��B
%
% lags�́A�x�N�g��[1, 0.2]�Ƃ��Ďw�肳��A�x�������������̓T�u�֐�DDEX1DE��
% �R�[�h������A�����͊֐�DDEX1HIST�ɂ���ĕ]������܂��B�����͒萔�Ȃ̂ŁA
% �x�N�g���Ƃ��ė^�����܂��B
%       sol = dde23(@ddex1de,[1, 0.2],ones(3,1),[0, 5]);
%
%   �Q�l �F DDE23, @.


%   Jacek Kierzenka, Lawrence F. Shampine and Skip Thompson
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 01:48:19 $
