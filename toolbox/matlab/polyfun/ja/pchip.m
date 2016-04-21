%PCHIP  �敪�I�L���[�r�b�N�G���~�[�g���}�������̌v�Z
% PP = PCHIP(X,Y) �́A�ʒu X �ł� Y �̒l�ɑ΂���Ashape-preserving ��
% �敪�I�L���[�r�b�N�G���~�[�g���}�̋敪�I��������^���܂��B����́A��ŁA
% PPVAL �ƃX�v���C�����[�e�B���e�B UNMKPP �Ŏg�p�ł��܂��B
% X �́A�x�N�g���łȂ���΂Ȃ�܂���B
% Y ���x�N�g���̏ꍇ�A Y(j) �́A X(j) �ň�v����l���Ƃ��܂��B�]���āA
% Y �́AX �Ɠ��������ł���K�v������܂��B
% Y ���s�� �܂��� ND �z��̏ꍇ�AY(:,...,:,j) �́AX(j) �ň�v����l�Ƃ���
% �Ƃ��A���̂��߁AY �̍Ō�̎����� length(X) �ɓ������Ȃ�K�v������܂��B
%   
% YY = PCHIP(X,Y,XX) �́AYY = PPVAL(PCHIP(X,Y),XX) �Ɠ����ł��B�]���āA
% YY �ɁAXX �ł̕�Ԃ̒l��^���܂��B
%
% PCHIP �ł́A���}�֐� p(x) �����̏����𖞑����܂��B
% �e�T�u��� X(k) <= x <= X(k+1) ��ŁAp(x) �́A���[�_�ŗ^����ꂽ�l�Ƃ���
% ���z�ɑ΂���L���[�r�b�N�G���~�[�g���}�ł��B���̂��߁Ap(x) �� Y ����}���A
% ���Ȃ킿�Ap(X(j)) = Y(:,j) �ŁA1�K���� Dp(x) �͘A���ł����AD^2p(x) �͑���
% �A���ł͂���܂���B����́AX(j)�ŃW�����v����\��������܂��B 
% X(j) �ł̌��z�́Ap(x) ��"�`��ۑ�"������P����������"�悤�ɑI������܂��B
% ����́A�f�[�^���P���ł����ԂŁAp(x) �ɂȂ邱�Ƃ��Ӗ����Ă��܂��B���Ȃ킿�A
% �f�[�^���ɒl�����_�� p(x) �ɂȂ�܂��B
%
% PCHIP �� SPLINE �Ɣ�r���܂��B
% SPLINE �ŗ^������֐� s(x) �́AX(j) �ł̌��z�� D^2s(x) ���A���ɂȂ�
% �悤�ɑI�����镔���ȊO�́A�S���������@�ō쐬����܂��B����́A����
% �悤�ȉe���������܂��B
% SPLINE  �́A��蕽��������܂��B���Ȃ킿�AD^2s(x) �͘A���ł��B
% SPLINE �́A�f�[�^���������֐��̒l�̏ꍇ�́A��萳�m�ɂȂ�܂��B
% PCHIP �́A�f�[�^������������Ă��Ȃ��ꍇ�́A�I�[�o�[�V���[�g�͂Ȃ��A
% �U�����܂���B
% PCHIP �́A�ݒ肪�ȒP�ł��B
% 2�̕��@�́A�v�Z�ʂ͓����ł��B
%
% ���:
%
%     x = -3:3;
%     y = [-1 -1 -1 0 1 1 1];
%     t = -3:.01:3;
%     plot(x,y,'o',t,[pchip(x,y,t); spline(x,y,t)])
%     legend('data','pchip','spline',4)
%
% ���� x, y, xx �̃T�|�[�g�N���X
%      float: double, single
%
% �Q�l INTERP1, SPLINE, PPVAL, UNMKPP.

% �Q�l����:
%   F. N. Fritsch and R. E. Carlson, "Monotone Piecewise Cubic
%   Interpolation", SIAM J. Numerical Analysis 17, 1980, 238-246.
%   David Kahaner, Cleve Moler and Stephen Nash, Numerical Methods
%   and Software, Prentice Hall, 1988.
%
%   Copyright 1984-2004 The MathWorks, Inc.
