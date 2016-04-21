% GRAM   ���䐫�O���~�A���Ɖϑ����O���~�A��
%
% Wc = GRAM(SYS,'c') �́A��ԋ�ԃ��f�� SYS �̉��䐫�O���~�A�������߂܂��B
%
% Wo = GRAM(SYS,'o') �́A�ϑ����O���~�A�������߂܂��B
%
% �����̃P�[�X�ŁA��ԋ�ԃ��f�� SYS �͈���łȂ���΂����܂���B�O���~�A��
% �́A���� Lyaponov �������������Čv�Z����܂�
%
%  *   �A�����ԃV�X�e��
%        dx/dt = A x + B u  ,   y = C x + D u  �ł́A
%        A*Wc + Wc*A' + BB' = 0  ��  A'*Wo + Wo*A + C'C = 0 
%    
%  *  ���U���ԃV�X�e��   
%        x[n+1] = A x[n] + B u[n] ,  y[n] = C x[n] + D u[n]  �ł́A
%        A*Wc*A' - Wc + BB' = 0  ��  A'*Wo*A - Wo + C'C = 0 
% 
% LTI ���f�� SYS �� ND �z��ɑ΂��āAWc �� Wo �́A���̂悤�� N+2 ��
% ���������z��ł��B 
% 
%   Wc(:,:,j1,...,jN) = GRAM(SYS(:,:,j1,...,jN),'c') .  
%   Wo(:,:,j1,...,jN) = GRAM(SYS(:,:,j1,...,jN),'o') .  
%
% �Q�l : SS, BALREAL, CTRB, OBSV.


%   J.N. Little 3-6-86
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:08:04 $
