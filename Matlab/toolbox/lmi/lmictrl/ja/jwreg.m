% a=jwreg(a,b2,c1,d12,knobjw)
%
% �֐�GOPTRIC��PLANTREG�ŗ��p�B
%
% �}�V���C�v�V�����𗘗p���Ă̐�����A -> A + eps*I�ɂ��A���̃V�X�e��
% �̋�����̗�_���폜���܂��B
%
%                    [ A - s I    B2 ]
%           P12(s) = [               ]
%                    [ C1        D12 ]
%
% P21(s)�𐳑������邽�߂ɁA���̂悤�Ɏ��s����܂��B
% 
%      a=jwreg(a',c2',b1',d21',knobjw)'
%
% KNOBJW��[0,1]�̒l�ŁAeps-�������̊������R���g���[�����܂��B
% (eps�̒l��KNOBJW�ő������܂�)
%
% �Q�l�F   HINFRIC.

% Copyright 1995-2001 The MathWorks, Inc. 
