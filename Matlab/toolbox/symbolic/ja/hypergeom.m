% HYPERGEOM �́A�K�E�X�̒��􉽊֐��ł��B
% HYPERGEOM(N, D, Z) �́A��ʉ����􉽊֐� F(N, D, Z) �ŁAjFk �Œ�`����
% �� Barnes �g�����􉽊֐��Ƃ��Ă��m���Ă��܂��B�����ŁAj = length(N) 
% �ŁAk = length(D) �ł��B�X�J�� a, b, c �ɑ΂��āAHYPERGEOM([a,b], c, z)
% �́A�K�E�X���􉽊֐� 2F1(a, b;c;z) �ɂȂ�܂��B
% 
% �����ȃx�L�����̒�`�́A���̂悤�ɂȂ�܂��B
% 
%    hypergeom(N,D,z) = sum(k=0:inf, (C(N,k)/C(D,k))*z^k/k!) 
% 
% �����ŁAC(V,k) = prod(i=1:length(V), gamma(V(i)+k)/gamma(V(i))) �ƂȂ�
% �܂��B�ŏ���2�̈����̂ǂ�����A�P��֐��v�Z�ɑ΂���W���p�����[�^��
% �^����x�N�g���ł��B3�Ԗڂ̈������x�N�g���̏ꍇ�A�֐��́A�敪�I�ɕ]��
% ����܂��B���ʂ́A���ׂĂ̈��������l�̏ꍇ�A���l�ɂȂ�A�����̂����ꂩ
% �������̏ꍇ�A���ʂ͐����ɂȂ�܂��BAbramowitz �� Stegun ���� Handbook
% of Mathematical Functions ��15�͂��Q�Ƃ��Ă��������B
% 
% ���F
%    hypergeom([],[],'z')             �́Aexp(z) ���o�͂��܂��B
%    hypergeom(1,[],'z')              �́A-1/(-1+z) ���o�͂��܂��B
%    hypergeom(1,2,'z')               �́A(exp(z)-1)/z ���o�͂��܂��B
%    hypergeom([1,2],[2,3],'z')       �́A-2*(-exp(z)+1+z)/z^2 ���o�͂�
%                                     �܂��B
%    hypergeom('a',[],'z')            �́A(1-z)^(-a) ���o�͂��܂��B
%    hypergeom([],1,'-z^2/4')         �́Abesselj(0,z) ���o�͂��܂��B
%    hypergeom([-n, n],1/2,'(1-z)/2') �́AT(n,z) ���o�͂��܂��B�����ŁA
%    T(n,z) = expand(cos(n*acos(z)))  �́An-���̃V�F�r�V�F�t�������ł��B
%
% �Q�l�F sym/hypergeom.

%   Copyright 1993-2000 The MathWorks, Inc. 
