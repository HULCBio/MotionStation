% IPERMUTE   �z��̎����̕��בւ��̋t����
% 
% A = IPERMUTE(B,ORDER)�́Apermute�̋t�ł��BIPERMUTE �́A
% PERMUTE(A,ORDER) �� B �𐶐�����悤�ɁAB �̎�������בւ��܂��B
% �쐬���ꂽ�z��� A �Ɠ����l�������܂����A�������̗v�f�ɕK�v��
% �����T�u�X�N���v�g�̏��Ԃ��AORDER �Ɏw�肷�邱�Ƃŕ��בւ��܂��B
% ORDER �̗v�f�́A1���� N �̐��l�̕��בւ��łȂ���΂Ȃ�܂���B
%
% PERMUTE��IPERMUTE�́AN�����z��ɑ΂���]�u(.')�̈�ʉ��ł��B
% 
% ���F
%      a = rand(1,2,3,4);
%      b = permute(a,[3 2 1 4]);
%      c = ipermute(b,[3 2 1 4]); % a �� c �͓���
%
% �Q�l�FPERMUTE.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:51:18 $
