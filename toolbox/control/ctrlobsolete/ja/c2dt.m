% C2DT   
%
% �A����ԋ�ԃ��f�����A���͂Ɏ��Ԓx����������Ȃ���A���U���ԃ��f����
% �ϊ����܂��B
%
% [Ad,Bd,Cd,Dd] = C2DT(A,B,C,T,lambda) �́A�A�����ԃV�X�e��
%           .
%           x(t) = Ax(t) + Bu(t-lambda)
%           y(t) = Cx(t) 
%
% ���A�T���v������ T �������U���ԃV�X�e��
%
%         x(k+1) = Ad x(k) + Bd u(k)
%           y(k) = Cd x(k) + Dd u(k) 
%
% �ɁA�ϊ����܂��B
% 
% �Q�l : PADE.


%   G. Franklin 1-17-87
%   Revised 8-23-87 JNL
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:30 $
