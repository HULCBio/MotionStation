%  [gopt,X1,X2,Y1,Y2] = goptlmi(P,r,gmin,tol,options)
%
% �A������(�A�i���O)�v�����gP�ɑ΂��āALMI�Ɋ�Â����œK���𗘗p���āA
% �œKHinf���\GOPT���v�Z���܂��B
%
% ���[�U�́A���̊֐��𒼐ڗ��p���܂���B
%
%�@�o��:
%  GOPT       ���[GMIN,GMAX]�ł̍œKHinf���\
%  X1,X2,..   gamma = GOPT�ɑ΂���2��HinfRiccati�s�����̉�X = X2/X1��
%             Y = Y2/Y1�B�����I�ɁAR = X1��S = Y1�́AX2=Y2=GOPT*eye�Ƃ�
%             �����LMI�̉��ł��B
%
% �Q�l�F    HINFLMI, KLMI.

% Copyright 1995-2001 The MathWorks, Inc. 
