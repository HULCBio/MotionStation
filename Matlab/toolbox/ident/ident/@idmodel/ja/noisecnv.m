% NOISECNV �́A�m�C�Y�`�����l���𑪒�`�����l���ɕϊ����܂��B
% 
%   Modc = NOISECNV(Model,Noise)
%
% Model �́A�C�ӂ� IDMODEL �I�u�W�F�N�g(IDGREY, IDARX, IDPOLY, IDSS)��
% ���BModc �́AModel �Ɠ����N���X�̃��f���ŁA������͂ƃm�C�Y�������ɑ���
% ���͂Ƃ��Ď�舵���܂��B
%
% 2�̏ꍇ������܂��BNoise = 'N'(���K��) �̏ꍇ�A�܂��A�Ɨ��ŒP�ʕ�
% �U�����悤�Ƀm�C�Y���𐳋K�����܂��B�܂��ANoise = 'I' (�C�m�x�[�V����)
% �̏ꍇ�A���K���͂Ȃ��ꂸ�A�m�C�Y���̓C�m�x�[�V�����ߒ��Ƃ��Ďc��܂��B
%
% ���ڂ������Ă݂܂��傤�BModel �����̌^�ŕ\�����܂��B
% 
%   y = G u + H e;  
% 
% �܂��́A��ԋ�Ԍ^
% 
%   x(t+1) = Ax(t) + Bu(t) + Ke(t)
%   y(t) = Cx(t) + Du(t) + e(t)
% 
% �����ł́A���f���̃C�m�x�[�V���������݂��Ă��܂��Be �̕��U�́AModel.No-
% iseVariance = L*L' �ł��B
%   
% Noise = 'Innovations' �𗘗p����ƁAModc �͂��̃��f����\�����܂��B
% (�f�t�H���g�ł́ANoise = 'Innovations'�ł��B)
% 
%   y = [G H] [u;e] 
% 
% �܂��́A��ԋ�Ԍ^
% 
%   x(t+1) = Ax(t) + [B K][u(t);e(t)]
%   y(t) = Cx(t) + [D I][u(t);e(t)];
% 
% ����́ANu+Ny �̓��̓`�����l���������Ă��܂��B���̓`�����l�� e �́A
% InputNames 'e@yk' �ŗ^�����܂��B�����ŁA'yk' �́Ak �Ԗڂ� OutputNa-
% me �ŁAk �Ԗڂ̏o�̓`�����l����"e �ɉe������"���̂��Ӗ����܂��B���̏�
% ���AModc�ɑ΂���TFDATA , ZPKDATA���𗘗p���邱�ƂŁA�`�B�֐�G��H�𒊏o
% ���܂��B
%
% Noise = 'Normalize' �𗘗p����ƁA�܂��A���K�� e = Lv ���Ȃ���܂��Bv 
% �͓Ɨ��ȃ`�����l���ŁA�P�ʕ��U�������F�m�C�Y�ł��B����́A�����U�s��
% L*L' �������F�m�C�Y�ɂȂ�܂��B
% 
% Modc �́A���f��
% 
%   y = [G HL][u;v]
% 
% �܂��́A��ԋ�Ԍ^
% 
% x(t+1) = Ax(t) + [B KL][u(t);v(t)]
% y(t) = Cx(t) +[D L][u(t);v(t)]
% 
% �ƂȂ�܂��B�����ŁANu+Ny �̓��̓`�����l���������Ă��܂��B���̓`����
% �l�� v �́AInputNames'v@yk' �ŗ^�����܂��B'yk' �́Ak �Ԗڂ̃`�����l
% ���� OutputName �ŁAk �Ԗڂ̏o�̓`�����l����"v �ɉe���������"���Ӗ���
% �܂��BModc�ɑ΂���TFDATA , ZPKDATA���𗘗p���邱�ƂŁA�`�B�֐�G��H��
% �o���܂��B���Ȃ킿�ASTEP �� Modc �ɓK�p�����ꍇ�A�m�C�Y���x�������f��
% ��܂��B
%
% G, H, �m�C�Y���U�̒��̕s�m�������́AModel ���� Modc �ɓK�؂ɕϊ�����
% �܂��B



%   Copyright 1986-2001 The MathWorks, Inc.
