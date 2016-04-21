% DLQRY   ���U���ԃV�X�e���ɑ΂���d�ݕt���̏o�͂������`�񎟃��M�����[�^
%
% [K,S,E] = DLQRY(A,B,C,D,Q,R) �́A�]���֐�
% 
%    J = Sum {y'Qy + u'Ru}
% 
% ���A���̍S��������
%
%    x[n+1] = Ax[n] + Bu[n] 
%      y[n] = Cx[n] + Du[n]
%             
% �̂��ƂŁA�ŏ��ɂ��鐧�䑥 u[n] = -Kx[n] �𖞂����œK�t�B�[�h�o�b�N
% �Q�C���s�� K ���v�Z���܂��B
%
% �����ŁA�֘A�������U�s�� Riccati �������̒���Ԃ̉� S �ƁA���[�v��
% �ŗL�l E = EIG(A-B*K) ���o�͂ł��܂��B
%
% �R���g���[���́ADREG ���g���č쐬�ł��܂��B
%
% �Q�l : DLQR, LQRD, DREG.


%   Clay M. Thompson  7-23-90
%   Revised: P. Gahinet  7-25-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:48 $
