% IF   �������s�X�e�[�g�����g
% 
% IF�X�e�[�g�����g�̈�ʓI�ȏ����́A���̂悤�ɂȂ�܂��B
%
%    IF expression
%      statements
%    ELSEIF expression
%      statements
%    ELSE
%      statements
%    END
%
% IF �ɑ���expression�̎�������[���v�f�ł���ꍇ�́Astatement�����s
% ����܂��BELSE �� ELSEIF �̕����́A�I�v�V�����ł��B�l�X�e�B���O���ꂽ
% IF �Ɠ��l�ɁA0�ȏ��ELSEIF�������g�����Ƃ��ł��܂��Bexpression�́A
% rop�� == �A<�A>�A< = �A> = �A~ = �̂Ƃ��ɂ́A�ʏ�expr rop expr�̏����ł��B 
%
% ���
%      if I == J
%        A(I,J) = 2;
%      elseif abs(I-J) == 1
%        A(I,J) = -1;
%      else
%        A(I,J) = 0;
%      end
%
% �Q�l�FRELOP, ELSE, ELSEIF, END, FOR, WHILE, SWITCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:04 $
%   Built-in function.
