% CAT   �z��̘A��
% 
% CAT(DIM,A,B)�́A����DIM�ɂ��Ĕz��A��B��A�����܂��B
% CAT(2,A,B)�́A[A,B]�Ɠ����ł��B
% CAT(1,A,B)�́A[A;B]�Ɠ����ł��B
%
% B = CAT(DIM,A1,A2,A3,A4,...)�́A����DIM�ɂ��āA���͔z��A1�AA2����A
% �����܂��B
%
% �J���}�ŋ�؂�ꂽ���X�g�̃V���^�b�N�X��p����ƁACAT(DIM,C{:})�A�܂�
% �́ACAT(DIM,C.FIELD)�́A���l�s����܂ރZ���z���\���̔z���P��̍s��
% �ɘA������֗��ȕ��@�ł��B
%
% ���:
%   a = magic(3); b = pascal(3); 
%   c = cat(4,a,b)
% 
% �́A3*3*1*2�̔z������܂��B
% 
%   s = {a b};
%   for i = 1:length(s)�A
%     siz{i} = size(s{i});
%   end
%   sizes = cat(1,siz{:})
% 
% �́A�T�C�Y�x�N�g������Ȃ�2�s2��̔z������܂��B
% 
% �Q�l�FNUM2CELL.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:50:58 $
%   Built-in function.

