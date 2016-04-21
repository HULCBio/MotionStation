% LYAPCHOL  �A�����Ԃ� Lyapunov �������ɑ΂��镽�����\���o
%
%
% R = LYAPCHOL(A,B) �́ALyapunov �s��������ɑ΂���� X �̃R���X�L�[���� 
% X = R'*R ���v�Z���܂��B
%
%   A*X + X*A' + B*B' = 0
%
% A �̂��ׂĂ̌ŗL�l�́AR �̊J�������ʂɂȂ���΂Ȃ�܂���B
%
% R = LYAPCHOL(A,B,E) �́A��ʉ����ꂽ Lyapunov�������������AX �̃R���X�L�[
% ���� X = R'*R ���v�Z���܂��B
%
%    A*X*E' + E*X*A' + B*B' = 0
%
% (A,E) �̂��ׂĂ̈�ʉ����ꂽ�ŗL�l�́AR �̊J�������ʂɂȂ���΂Ȃ�܂���B
%
% �Q�l : LYAP, DLYAPCHOL.


% Copyright 1986-2002 The MathWorks, Inc.
