% [a,b2]=ucreg(a,b2,c1,d12,knobjw)
%
% �֐�DGOPTRIC�ŗ��p�B
%
% eps-������ [A,B2] -> (1+eps)*[A,B2]�ɂ��A���̃V�X�e���̒P�ʉ~���
% ��_���������܂��B
%
%                    [ A - z I    B2 ]
%           P12(z) = [               ]
%                    [   C1      D12 ]
%
% P21(z)�𐳑������邽�߂ɁA���̂悤�Ɏ��s���܂��B
% 
%      a=jwreg(a',c2',b1',d21',knobjw)'
%
% KNOBJW��[0,1]�̒l�ŁAeps-�������̊������R���g���[�����܂�(KNOBJW��eps
% �𑝉����܂�)�B
%
% �Q�l�F    DHINFRIC.
% 

% Copyright 1995-2001 The MathWorks, Inc. 
