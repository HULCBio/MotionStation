% DEL2   ���U���v���V�A��
% 
% L = DEL2(U)�́AU ���s��̂Ƃ��A���U�̋ߎ��@0.25*del^2 u = (d^2u/dx^2 +
% d^2/dy^2)/4���o�͂��܂��B�s��L�́AU�̗v�f�Ƃ��̗אڂ���4�̕��ςƂ̍�
% �Ɠ������v�f�����AU�Ɠ����傫���̍s��ł��B
%
% L = DEL2(U)�́AU��N�����z��̂Ƃ��An��ndims(u)�ł���(del^2 u)/2/n�̋�
% �����o�͂��܂��B
%
% L = DEL2(U,H)�́AH���X�J���̂Ƃ��A�e�����ł̓_�Ԋu�Ƃ���H���g���܂�(H 
% = 1���f�t�H���g)�B
% 
% L = DEL2(U,HX,HY)�́AU��2�����̂Ƃ��AHX��HY�Ŏw�肵���Ԋu���g���܂��B
% HX���X�J���̏ꍇ�Ax�����̓_�̊Ԋu��^���܂��BHX���x�N�g���̏ꍇ�A����
% ��SIZE(U,2)�ŁA�_��x���W���w�肵�܂��B���l�ɁAHY���X�J���̏ꍇ�Ay����
% �̓_�̊Ԋu��^���܂��BHY���x�N�g���̏ꍇ�A������SIZE(U,1)�ŁA�_��y���W
% ���w�肵�܂��B
%
% L = DEL2(U,HX,HY,HZ,...)�́AU��N�����z��̂Ƃ��AHX�AHY�AHZ���ŗ^�����
% ���Ԋu���g���܂��B
%
% �Q�l�FGRADIENT, DIFF.


%   D. Chen, 16 March 95
%   Copyright 1984-2003 The MathWorks, Inc. 
