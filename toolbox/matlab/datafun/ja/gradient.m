% GRADIENT   ���z�ߎ�
% 
% [FX,FY] = GRADIENT(F)�́A�s��F�̐��l���z���o�͂��܂��BFX�́Ax(��)����
% �̍���dF/dx�ɑΉ����܂��BFY�́Ay(�s)�����̍���dF/dy�ɑΉ����܂��B�e��
% ���̊Ԋu�́A1�Ɖ��肵�܂��BF���x�N�g���̂Ƃ��ADF = GRADIENT(F)��1����
% �̌��z�ł��B
%
% [FX,FY] = GRADIENT(F,H)�́AH���X�J���̂Ƃ��A�e�����ł̊Ԋu�Ƃ��Ďg����
% ���B
%
% [FX,FY] = GRADIENT(F,HX,HY)�́AF��2�����̂Ƃ��AHX��HY�Ŏw�肳�ꂽ�Ԋu
% ���g���܂��BHX��H�x�́A���W�Ԃ̊Ԋu���w�肷�邽�߂̃X�J����A�_�̍��W
% ���w�肷��x�N�g���ł��BHX��HY���x�N�g���̏ꍇ�A���̒�����F�̑Ή�����
% �����ƈ�v���Ȃ���΂Ȃ�܂���B
%
% [FX,FY,FZ] = GRADIENT(F)�́AF��3�����z��̂Ƃ��AF�̐��l���z���o�͂���
% ���BFZ�́Az�����̍���dF/dz�ɑΉ����܂��BGRADIENT(F,H)�́AH���X�J���̂�
% ���A�e�����̓_�Ԋu�Ƃ��Ďg���܂��B
%
% [FX,FY,FZ] = GRADIENT(F,HX,HY,HZ)�́AHX�AHY�AHZ�ŗ^����ꂽ�Ԋu���g��
% �܂��B 
%
% [FX,FY,FZ,...] = GRADIENT(F,...)�́AF��N�����̂Ƃ������l�ŁAN�̏o��
% �ƁA2�A�܂��́AN+1�̓��͂������Ȃ���΂Ȃ�܂���B
%
% ���:
%       [x,y] = meshgrid(-2:.2:2, -2:.2:2);
%       z = x .* exp(-x.^2 - y.^2);
%       [px,py] = gradient(z,.2,.2);
%       contour(z),hold on, quiver(px,py), hold off
%
% �Q�l�FDIFF, DEL2.


%   D. Chen, 16 March 95
%   Copyright 1984-2003 The MathWorks, Inc. 
