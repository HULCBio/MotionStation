% AVEKNT   �ߓ_�̕���
%
% AVEKNT(T,K) �́A�A������K-1�̐ߓ_�̕��ς��o�͂��܂��B���Ȃ킿�A
% S_{K,T} �ŕ�Ԃ���Ƃ��A�悢��ԓ_�Ƃ��Đ��������
%
%       TSTAR(i) = ( T_{i+1} + ... + T_{i+K-1} ) / (K-1)
%
% �̓_��I�����܂��B
%
% ���Ƃ��΁Ak �Ƒ�������� breaks ���^�����Ă���Ƃ��A
%
%   t = augknt(breaks,k); x = aveknt(t,K);
%   sp = spapi( t , x, sin(x) );
%
% �́A��� [breaks(1) .. breaks(end)] ��̐����֐��ɃX�v���C����Ԃ�
% �^���܂��B
%
% �Q�l : SPAPIDEM, OPTKNT, APTKNT, CHBPNT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
