%  [gopt,X1,X2,Y1,Y2] = dgoptlmi(P,r,gmin,tol,options)
%
% ���U���ԃv�����gP(z)�ɑ΂��āALMI�Ɋ�Â����œK���𗘗p���A�œKHinf
% ���\GOPT���v�Z���܂��B
%
% USER�́A���̊֐��𒼐ڗ��p���܂���B
%
% �o��:
%  GOPT        �Ԋu[GMIN,GMAX]�ł̍œKHinf���\
%�@X1,X2,..    gamma = GOPT�ɑ΂���2��HinfRiccati�s�����̉� X = X2/X1
%              ��Y = Y2/Y1�BR = X1��S = Y1�́AX2=Y2=GOPT*eye�ƂȂ����
%              LMI�̉��ł��B
%
% �Q�l�F    DHINFLMI, DKCEN.

% Copyright 1995-2001 The MathWorks, Inc. 
