% DWTPER2  �@�P�ꃌ�x���̗��U2�����E�F�[�u���b�g�ϊ�(�����I��舵��)
% [CA,CH,CV,CD] = DWTPER2(X,'wname') �́A���͍s�� X �̎�������p�����E�F�[�u���b
% �g�����ɂ�蓾���� Approximation �W���s�� CA �� Detail �W���s�� CH,CV,CD ��
% �v�Z���܂��B'wname' �́A�E�F�[�u���b�g�����܂ޕ�����ł�(WFILTERS ���Q��)�B
%
% �E�F�[�u���b�g����ݒ肷�����ɁA�t�B���^��ݒ肷�邱�Ƃ��ł��܂��B���͈���
% ��3�ݒ肷��ƁA���̂悤�ɂȂ�܂��B
% 
%   [CA,CH,CV,CD] = DWTPER2(X,Lo_D,Hi_D)
% 
% �����ŁA
%   Lo_D �́A�������[�p�X�t�B���^�ł��B
%   Hi_D �́A�����n�C�p�X�t�B���^�ł��B
%
% sx = size(X) �̏ꍇ�Asize(CA) = size(CH) = size(CV) = size(CD) = CEIL(sx/2) ��
% �������܂��B
%
% �Q�l�F DWT2, IDWTPER2.



% $Revision: $
% Copyright 1995-2002 The MathWorks, Inc.
