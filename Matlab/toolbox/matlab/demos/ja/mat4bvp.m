% MAT4BVP  Mathieu��������4�Ԗڂ̌ŗL�l�����o���܂��B
%   
% ���E����  y'(0) = 0, y'(pi) = 0 �������A���[0, pi]�ŁAMathieu ������
%
%      y'' + (lambda - 2*q*cos(2*x))*y = 0
%   
% ���p�����[�^ q = 5 �̂Ƃ��A���E���� y'(0)=0, y'(pi)=0 �ŁA���[0, pi]
% �ŁA4�Ԗڂ̌ŗL�l�����߂܂��傤�B
%
%  Sturm-Liouville ���̓��ʂȐ������L�q�����R�[�h���A�ݒ肵���ŗL�l���v
% �Z���܂��B��ʓI�ȖړI�ŁA�R�[�h�����ꂽ BVP4C ���g���āA����l�̋߂�
% �̌ŗL�l�݂̂��v�Z���邱�Ƃ��ł��܂��B������g���āA�����������𐄒�l
% �Ƃ��ė^���邱�Ƃɂ���]����ŗL�l���v�Z�����邱�Ƃ��ł��܂��B�ŗL��
% �� y(x) �́A�萔����Z���Č��肳��܂��B����ŁA���K�����ꂽ��� 
% y(0) = 1 ���A���ʂȉ���ݒ肷�邽�߂Ɏg���܂��B
%
% BVP4C �Ō��o����郁�b�V����̉��̃v���b�g�́A�X���[�Y�����ꂽ�O���t��
% ���̂Ƃ͈قȂ錋�ʂ������܂��B�� S(x) �́A�A���ŁA���W�����A���ł��B�X
% ���[�Y�ȃO���t�𓾂邽�߂ɁA�K�v�Ȃ�΁A�����̓_��BVPVAL ���g���Ċ�
% �P�Ɍv�Z���邱�Ƃ��ł��܂��B
%   
% �Q�l �F BVP4C, BVPSET, BVPGET, BVPINIT, DEVAL, @.


%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 01:49:01 $
