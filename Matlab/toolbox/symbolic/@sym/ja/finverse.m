% FINVERSE   �t�֐�
% g = FINVERSE(f) �́Af �̋t�֐����o�͂��܂��Bf �́A1�̃V���{���b�N��
% ���A������ 'x' �̊֐���\�킷�V���{���b�N���ł��B���̂Ƃ��Ag �́A
% g(f(x)) = x �𖞂����V���{���b�N���ł��B
%
% g = FINVERSE(f, v) �́A�Ɨ��ϐ��Ƃ��ăV���{���b�N�ϐ� v ���g���܂��B��
% �̂Ƃ��Ag �́Ag(f(v)) = v �𖞂����V���{���b�N���ł��Bf ��2�ȏ�̃V
% ���{���b�N�ϐ����܂�ł���Ƃ��ɁA���̏������g���܂��B
%
% ��� :
%      finverse(1/tan(x))�́Aatan(1/x)���o�͂��܂��B
% 
%      f = x^2+y;
%      finverse(f, y) �́A-x^2+y ���o�͂��܂��B
%      finverse(f) �́A(-y+x)^(1/2)���o�͂��A�t�֐������j�[�N�łȂ�����
%      ���������[�j���O��\�����܂��B
%
% �Q�l�F COMPOSE.



%   Copyright 1993-2002 The MathWorks, Inc.
