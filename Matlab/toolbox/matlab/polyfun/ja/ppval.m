%PPVAL  �敪�������̌v�Z
% V = PPVAL(PP,XX) �́AXX �̗v�f�ŁAPCHIP, SPLINE, �܂��́A�X�v���C��
% ���[�e�B���e�B MKPP �ō\�������悤�ɁAPP �ɓ�����敪������ f ��
% �l���o�͂��܂��B
%
% V �́AXX �̊e�v�f��f �̒l�Œu�������邱�Ƃɂ�蓾���܂��B
% f ���X�J���[�l�̏ꍇ�AV �́AXX �Ɠ����T�C�Y�ł��B 
% f �� [D1,..,Dr]-�l�ŁAXX ���T�C�Y [N1,...,Ns] �����ꍇ�AV �́AXX(J1,...,Js) 
% �ł� f �̒l�AV(:,...,:, J1,...,Js) �ł���A�T�C�Y[D1,...,Dr, N1,...,Ns]  
% �������܂��B -- ���̏ꍇ�́A�����܂��B 
%   (1)  1 ����� s �� 2 �̏ꍇ�AN1 �͖�������܂��B���Ȃ킿�AXX ���s�x�N�g��
%        �ł���A
%   (2) PPVAL �́AXX �̌�ɑ��������𖳎����܂��B
%
% V = PPVAL(XX,PP) �́AFMINBND, FZERO, QUAD �⑼�̊֐��������Ƃ���֐���
% ���킹�Ďg�p���邱�Ƃ��\�ł��B
%
% ���:
% �֐� cos ���g�������̂ƁAspline ��Ԃ��g�������̂̌��ʂ��r���܂��B
%
%     a = 0; b = 10;
%     int1 = quad(@cos,a,b,[],[]);
%     x = a:b; y = cos(x); pp = spline(x,y); 
%     int2 = quad(@ppval,a,b,[],[],pp);
%
% int1�͋�� [a,b] �Ŋ֐� cos ���v�Z���A����Aint2 �͌v�Z���� x,y �̒l��
% ���}���邱�ƂŁA������ԂŊ֐� cos ���ߎ����āA�敪������ pp ���v�Z
% �������̂ł��B
%
% ���� pp, xx �̃T�|�[�g�N���X
%      float: double, single
%
% �Q�l SPLINE, PCHIP, MKPP, UNMKPP, SPLINES (The Spline Toolbox).

%   Carl de Boor 7-2-86
%   Copyright 1984-2004 The MathWorks, Inc.
