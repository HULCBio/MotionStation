% DDEX2  DDE23�ɑ΂�����2
%
% ���̗��́At = 600����n�܂���ӈ�R���w���֐��G��1.05����0.84�Ɍ���
% ����Ƃ��AJ.T. Ottesen, Modelling of the Baroflex-Feedback Mechanism 
% With Time-Delay, J. Math. Biol., 36 (1997)�ɂ��S�����ǃ��f���������܂��B
%
% ���́A���炩���ߒm���Ă���_ (t = 600)�ɂ����āA�᎟�̔��W���ɂ�����
% �s�A���Ɋւ��ă\���o�ɓ`���邽�߂ɁA'Jumps'�I�v�V�����𗘗p������@��
% �����Ă��܂��B 'Jumps'���g������ɁA���̗��́A2�̕����ɕ�����
% ���Ƃɂ���ĉ������Ƃ��ł��܂��B
%       sol = dde23(@ddex2de,tau,history,[0, 600],[],p);
%       sol = dde23(@ddex2de,tau,sol,[600, 1000],[],p);
% [0, 600] �ɂ�������̍\����SOL�́At = 600�ɂ����Đϕ����ĊJ���邽�߂�
% �����Ƃ��ė��p����܂��B2��ڂ̌Ăяo���ɂ����āADDE23 �� [0 1000]��
% ���ׂĂɂ����ĉ������p�ł���悤��SOL���g�����܂��B���炩���߂Ēm��
% ��Ă���_�ɂ����Ē᎟�̔��W���ɂ����ĕs�A�������������Ƃ��́A'Jumps' 
% �I�v�V�������g���������ǂ��ł��傤�B�C�x���g�֐����g���ĕs�A����T��
% �Ȃ���΂Ȃ�Ȃ��Ƃ��́A�s�A���_�ɂ����čĊJ����K�v������܂��B
%
% �Q�l �F DDE23, DDESET, @.


%   Jacek Kierzenka, Lawrence F. Shampine and Skip Thompson
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 01:48:20 $
