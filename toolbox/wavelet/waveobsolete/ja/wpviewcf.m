% WPVIEWCF    �E�F�[�u���b�g�p�P�b�g�J���[�W���̃v���b�g�\��
% wpviewcf(T,D,CMODE) �́A�c���[�\�� T �̕s�A���m�[�h�Ɋւ���J���[�W�����v���b
% �g�\�����܂��B
%   T �́A�c���[�\���ł��B
%   D �́A�f�[�^�\���ł��B
%   CMODE �́A�J���[���[�h��\�����鐮���ł��B
% 1: 'FRQ : Global + abs'
% 2: 'FRQ : By Level + abs'
% 3: 'FRQ : Global'
% 4: 'FRQ : By Level'
% 5: 'NAT : Global + abs'
% 6: 'NAT : By Level + abs'
% 7: 'NAT : Global'
% 8: 'NAT : By Level'
%
% wpviewcf(T,D,CMODE,NB) �́ANB �Ŏw�肳�ꂽ�J���[��p���܂��B
%
% ���:
%   x = sin(8*pi*[0:0.005:1]);
%   [t,d] = wpdec(x,4,'db1');
%   plottree(t);
%   wpviewcf(t,d,1);
%
% �Q�l�F MAKETREE, WPDEC.



% $Revision: 1.1 $
% Copyright 1995-2002 The MathWorks, Inc.
