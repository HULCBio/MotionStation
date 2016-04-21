%INTERP1 1�������(table lookup)
% YI = INTERP1(X,Y,XI) �́A�x�N�g�� �܂��� �z�� XI ���̓_�ł̊֐� Y �̒l
% Y1 �����߂邽�߂ɕ�Ԃ��s���܂��BX �́A���� N �̃x�N�g���� SIZE(Y,1) ��
% N �ł���K�v������܂��BY ���T�C�Y [N,M1,M2,...,Mk] �̔z��̏ꍇ�AY ��
% �eM1�~M2�~...Mk �̒l�ɑ΂��āA��Ԃ��s���܂��BXI ���T�C�Y
% [D1,D2,...,Dj] �̔z��̏ꍇ�AYI �́A�T�C�Y [D1,D2,...,Dj,M1,M2,...,Mk]
% �ɂȂ�܂��B
%
% YI = INTERP1(Y,XI) �́AX = 1:N �Ɖ��肵�܂��B�����ŁAN �̓x�N�g�� Y ��
% �΂��Ă� length(Y) �ŁA�z�� Y �ɑ΂��Ă� SIZE(Y,1) �ł��B
%
% ��Ԃ́A"table lookup" �Ɠ������Z���s���܂��B"table lookup"�̗p��Ő���
% ����ƁA"table"�� [X,Y] �ŁAINTERP1 �� X �� XI �̗v�f��"looks-up"���A
% �����̈ʒu�Ɋ�Â��� Y �̗v�f���ŕ�Ԃ��ꂽ�l YI ���o�͂��܂��B
%
% YI = INTERP1(X,Y,XI,'method') �́A��Ԏ�@���w�肵�܂��B�f�t�H���g�́A
% ���`��Ԃł��B�g�p�\�Ȏ�@�͈ȉ��̒ʂ�ł��B
%
%   'nearest' - �ŋߖT�_�ɂ����
%   'linear'  - ���`���
%   'spline'  - �L���[�r�b�N�X�v���C�����(SPLINE)
%   'pchip'   - shape-preserving �̋敪�I�L���[�r�b�N���
%   'cubic'   - �L���[�r�b�N���
%   'v5cubic' - MATLAB 5 �̃L���[�r�b�N��ԁA����́AX �����Ԋu�łȂ�
%               �ꍇ�͊O�}�ł����A 'spline'�𗘗p���܂��B
%
% YI = INTERP1(X,Y,XI,'method','extrap') �́AX �ō쐬���ꂽ��Ԃ̊O����
% XI �̗v�f�ɑ΂��Ďg�p����O�}�@���w�肷��̂Ɏg���܂��B
% �܂��AYI = INTERP1(X,Y,XI,'method',EXTRAPVAL) �́AEXTRAPVAL ���g���āA
% X �ō쐬���ꂽ��Ԃ̊O���̒l��u�������܂��B
% EXTRAPVAL �ɑ΂��ẮANaN �� 0 �����΂��Ύg�p����܂��B4�̓��͈�����
% ���f�t�H���g�̊O�}�@�́A'spline' �� 'pchip' �ɑ΂��Ă� 'extrap' �ŁA
% ���̕��@�ɑ΂��Ă� EXTRAPVAL = NaN �ł��B
%
% PP = INTERP1(X,Y,'method','pp') �́AY �� ppform (piecewise polynomial form)
% ���쐬���邽�߂ɁA�w�肵�����\�b�h���g�p���܂��B���\�b�h�́A'v5cubic' 
% �ȊO�ł́A��L�̂����ꂩ�ƂȂ�܂��B
%
% ���Ƃ��΁A�e�������g���쐬���A�ׂ���������œ��}���܂��B
%       x = 0:10; y = sin(x); xi = 0:.25:10;
%       yi = interp1(x,y,xi); plot(x,y,'o',xi,yi)
%
% �������̗�Ƃ��āAfunctional values �̕\���쐬���܂��B
%       x = [1:10]'; y = [ x.^2, x.^3, x.^4 ]; 
%       xi = [ 1.5, 1.75; 7.5, 7.75]; yi = interp1(x,y,xi);
%
% �́A3 �̊֐��e�X�ɂ���1���A��Ԃ����֐��l��2�s2��̍s���
% �쐬���܂��Byi �́A�T�C�Y�� 2�~2�~3 �ƂȂ�܂��B
%
%   ���� X, Y, XI �ɑ΂���T�|�[�g�N���X: 
%      float: double, single
%  
% �Q�l INTERP1Q, INTERPFT, SPLINE, INTERP2, INTERP3, INTERPN.

%   Copyright 1984-2004 The MathWorks, Inc.
