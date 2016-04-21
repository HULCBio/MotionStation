%IBURGERSODE  implicit ODE system�Ƃ��ĉ������ Burgers ������
% IBURGERSODE(N) �́A����Burgers �������������܂��BN�_��(�ړ�)���b�V����ŁA
% u(x,0) = sin(2*pi*x) + 0.5*sin(pi*x) ����� u(0,t) = 0, u(1,t) = 0 ��
% �����Ƃ��A0 <= x <= 1 �ɂ����āADu/Dt = 1e-4 * D^2 u/Dx^2 - D(0.5u^2)/Dx.
% ����́A���̘_���� Problem 2 �ł��B
% W. Huang, Y. Ren, and R.D. Russell, Moving mesh methods based on moving 
% mesh partial differential equations, J. Comput. Phys. 113(1994) 279-290. 
%
% ���̘_���ł́ABurger �������́A(19) �ŊT�����q�ׂ�ꂽ�悤�ɁA
% ���S�����ɂ�藣�U������A�p�����ړ����b�V�� PDE �́Atau = 1e-3 
% �Ƃ���MMPDE6�ł��B�} 6 �́AN = 20 �̏ꍇ�̉��������Agamma = 2 �C
% p = 2�Ƃ��ē��ʂȕ��������s���܂��B���̖��́A���΋��e�덷 
% 1e-5 �Ɛ�΋��e�덷 1e-4 ��p���ĉ�����܂����B 
%  
% ���̗�ł́A�����v���b�g�������̂͐}6 �Ɏ��Ă��܂����A�����f�[�^��
% �v���b�g����A��肪 t = 1 �ł̂ݐϕ�����Ă���̂ŁA���s���Ԃ����Ȃ�
% �Ȃ��Ă��܂��B���U�����ꂽ���́Afully implicit system f(t,y,y') = 0 
% �Ƃ��ĉ�����܂��B���̃x�N�g���́Ay = (a1,...,aN,x1,...,xN)�ł��B
% ���� t �ŁAaj �́A�Δ����������̉� u(t,xj) ���ߎ����܂��B
% ���b�V���_ xj �́A���� (�ړ����b�V��)�̊֐��ł��B�����ȓ��֐� df/dy' 
% ��^���Adf/dy �ɃX�p�[�X�p�^�[�����w�肷��ƁA���s���Ԃ��啝�Ɍ������܂��B
%
%   �Q�l ODE15I, BURGERSODE, ODESET, @.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
