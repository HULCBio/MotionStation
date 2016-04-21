% GCD   �ő����
% 
% G = GCD(A,B) �́AA �� B �̑Ή�����v�f���m�̍ő���񐔂ł��B�z�� A �� B
% �́A���łȂ������v�f�������A�����T�C�Y�łȂ���΂Ȃ�܂���(�܂��́A������
% �����X�J���ł��\���܂���)�BGCD(0,0) �́A�֋X��0���o�͂��܂��B����ȊO�́A
% GCD �͐��̐������o�͂��܂��B
%
% [G,C,D] = GCD(A,B) �́AG = A.*C + B.*D �ł���悤�� C �� D ���o�͂��܂��B
% ����́ADiophantine����������������A�G���~�[�g�ϊ����v�Z���邽�߂ɕ֗�
% �ł��B
%
% �Q�l�FLCM.



%   Algorithm: See Knuth Volume 2, Section 4.5.2, Algorithm X.
%   Author:    John Gilbert, Xerox PARC
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:04:18 $
