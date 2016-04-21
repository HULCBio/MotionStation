% CFINTERP1 1-�������}(�e�[�u�����b�N�A�b�v)
% YI = CFINTERP1(X,Y,XI) �́A�x�N�g�� XI �Őݒ肳��Ă���_�ɑ΂��āA��
% �� Y �̒l����ɂ��āAYI ����}���g���ċ��߂܂��B�x�N�g�� X �́A�f�[�^ 
% Y ���^�����Ă���_���w�肵�܂��BY ���s��̏ꍇ�A���}�́AY �̊e��ɑ�
% ���čs���AYI �́Alength(XI) �s size(Y,2) ��̍s��ɂȂ�܂��B
%
% YI = CFINTERP1(Y,XI) �́AX = 1:N �����肵�Ă��܂��B�����ŁAN �́AY ��
% �x�N�g���̏ꍇ�Alength(Y) �ŁA�s��̏ꍇ�ASIZE(Y,1)�ł��B
%
% ���}�́A"�e�[�u�����b�N�A�b�v"�Ɠ��l�ȉ��Z���s���܂��B"�e�[�u�����b�N
% �A�b�v"�̍��ɋL�q����Ă���悤�ɁA"�e�[�u��"�� [X,Y] �ŁACFINTERP1 �́A
% X �̒����� XI �̗v�f��T���A���̈ʒu���x�[�X�ɁAY �̗v�f�Q�̒��œ��}��
% �ꂽ�l YI ���o�͂��܂��B
%
% YI = CFINTERP1(X,Y,XI,'method') �́A�w�肵�� 'method'���g���܂��B
% �f�t�H���g�ł́A���`���}�ł��B���p�\�ȕ��@�́A���̂��̂ł��B
%
%     'nearest'  - �ŋߖT���}
%     'linear'   - ���`���}
%     'spline'   - �敪�I�ȃL���[�r�b�N�X�v���C�����}(SPLINE)
%     'pchip'    - �敪�I�ȃL���[�r�b�N�G���~�[�g���}(PCHIP)
%     'cubic'    - 'pchip' �Ɠ���
%     'v5cubic'  - MATLAB 5 �Ŏg���Ă���L���[�r�b�N���}�ŁA�O�}���ł�
%                  �܂���B�����āAX �����Ԋu�łȂ��ꍇ�A'spline'���g����
%                  ���������B
%
% YI = CFINTERP1(Y,XI,'method') �́AX = 1:N �����肵�Ă��܂��B�����ŁA
% N �́AY ���x�N�g���̏ꍇ�Alength(Y) �ŁA�s��̏ꍇ�ASIZE(Y,1) �ł��B
%
% YI = CFINTERP1(X,Y,XI,'method','extrap') �́AX �Őݒ肵���͈͊O��XI ��
% �v�f�ɑ΂��ẮA�w�肵�����@���g���āA�O�}���܂��B����AYI = CFINTERP1
% (X,Y,XI,'method',EXTRAPVAL) �́AEXTRAPVAL ���g���āA�����̒l��u����
% ���܂��BNaN �� 0 �́AEXTRAVAL �ɁA�悭�g���܂��B4�̓��͈��������f
% �t�H���g�̊O�}�̋����́A'spline'��'pchip'�ɑ΂��āA'extrap'�ŁA���̕��@
% �ɂ��ẮAEXTRAPVAL = NaN �ł��B
%
% ���Ƃ��āA�e���f�[�^�ɂ��Đ����g���쐬���A���̊Ԃ𖄂߂�ׂ����f�[
% �^���g���āA���}���s���܂��B
% 
%       x = 0:10; y = sin(x); xi = 0:.25:10;
%       yi = cfinterp1(x,y,xi); plot(x,y,'o',xi,yi)
%
% CFINTERP1 �́A���}���ꂽ�֐��� pp-�^���o�͂���@�\�������Ă��܂��B
% ���̃V���^�b�N�X�́A���̂��̂ł��B
%
%   F = CFINTERP1(X,Y,'method','pp') 
%
% 'pp' �́AYI = CFINTERP1(Y,XI,'method');�Ƌ�ʂł���K�v������܂��B
%
% F = CFINTERP1(Y,'method') �ł́A'pp' �͕K�v����܂���B�����ŁAX �͗^
% �����Ă��܂���BX �́A1:length(Y) �Ɖ��肵�Ă��܂��B
%
% F = CFINTERP1(Y) �ł́AX �� method ���^�����Ă��܂���BX �́A
% 1:length(Y) �ŁAmethod �́A'linear' �Ɖ��肵�Ă��܂��B
%
% �Q�l   INTERP1Q, INTERPFT, SPLINE, INTERP2, INTERP3, INTERPN.

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
