% CIRCSHIFT   �z�I�ɔz����V�t�g
%
% B = CIRCSHIFT(A,SHIFTSIZE) �́ASHIFTSIZE �v�f�Ŕz�� A �̒l���z�I��
% �V�t�g���܂��BSHIFTSIZE �́AN�Ԗڂ̗v�f���A�z�� A �� N �Ԗڂ̎�����
% �΂���V�t�g�ʂ��w�肷�鐮���X�J���v�f�����x�N�g���ł��BSHIFTSIZE 
% �̗v�f�����̏ꍇ�AA �̒l�́A������(�܂��͉E����)�ɃV�t�g���܂��B����
% �ꍇ�́AA �̒l�͏����(�܂��͍�����)�ɃV�t�g���܂��B
%
% ���:
%    A = [ 1 2 3;4 5 6; 7 8 9];
%    B = circshift(A,1) % 1�ɂ���čŏ��̎����̒l���������ɏz�I�ɃV�t�g
%    B =     7     8     9
%            1     2     3
%            4     5     6
%    B = circshift(A,[1 -1]) % 1�ɂ���čŏ��̎����̒l���������ɁA2�Ԗ�
%                            % �̎�����1�ɂ���č������ɏz�I�ɃV�t�g
%    B =     8     9     7
%            2     3     1
%            5     6     4
%
% �Q�l: FFTSHIFT, SHIFTDIM.


%   Copyright 1984-2003 The MathWorks, Inc.  
