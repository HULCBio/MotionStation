% DIAG   �Ίp�s��ƍs��̑Ίp�v�f
% 
% V��N�v�f�̃x�N�g���̂Ƃ��ADIAG(V,K)�́AK�Ԗڂ̑Ίp���V�̗v�f�����A
% N+ABS(K)���̐����s����o�͂��܂��BK = 0�͎�Ίp�AK > 0�͎�Ίp�̏㑤
% K < 0�͎�Ίp�̉����ɑΉ����܂��B
%
% DIAG(V)�́ADIAG(V,0)�Ɠ����ŁAV�̗v�f����Ίp�v�f�Ƃ��܂��B
%
% �s��X�ɑ΂��āADIAG(X,K)��X��K�Ԗڂ̑Ίp�v�f���������x�N�g�����o
% �͂��܂��B
%
% DIAG(X)�́AX�̎�Ίp�ł��BDIAG(DIAG(X))�́A�Ίp�s��ł��B
%
% ���
% 
%    m = 5;
%    diag(-m:m) + diag(ones(2*m,1),1) + diag(ones(2*m,1),-1)
%  
% �́A2*m+1����3�d�Ίp�s����쐬���܂��B
%
% �Q�l�FSPDIAGS, TRIU, TRIL.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:51:01 $
%   Built-in function.
