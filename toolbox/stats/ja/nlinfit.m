% NLINFIT   Gauss-Newton �@���g���āA����`�̍ŏ����f�[�^�ߎ�
% 
% NLINFIT(X,Y,FUN,BETA0) �́A�ŏ�����p��������`�֐��̌W���𐄒肵�܂��B
% Y �́A�����l(�]���ϐ�)�̃x�N�g���ł��B�ʏ�́AX �́AY �̊e�l�ɑ΂���
% 1�̍s���g�����\���q(�Ɨ��ϐ�)�̌v��s��ł��B�������Ȃ���AX �́A
% FUN �Ɏ󂯓�����邽�߂ɏ������ꂽ�C�ӂ̔z��ł��BFUN �́A�W���x�N�g��
% �Ɣz�� X ��2�̈������󂯓���āA�ߎ����ꂽ Y �̒l�̃x�N�g�����o�͂���
% �֐��ł��BBETA0 �́A�W���ɑ΂��鏉���l���܂ރx�N�g���ł��B
%
% [BETA,R,J] = NLINFIT(X,Y,FUN,BETA0) �́A�K���W�� BETA�A�c�� R�A���R�r
% �A�� J ���o�͂��܂��B���[�U�́A�\���̌덷������s�����߂� NLPREDCI �ƁA
% ���肳�ꂽ�W���̌덷������s�����߂� NLPARCI �ł����̏o�͂��g�p����
% ���Ƃ��ł��܂��B
% 
% ���
% ----
%   FUN �́A@���g���Ďw�肷�邱�Ƃ��ł��܂��B:
%      nlintool(x, y, @myfun, b0)
%   �����ŁAMYFUN �́A�ȉ��̂悤��MATLAB�֐��ł��B:
%      function yhat = myfun(beta, x)
%      b1 = beta(1);
%      b2 = beta(2);
%      yhat = 1 ./ (1 + exp(b1 + b2*x));
%
%   FUN �́A�C�����C���I�u�W�F�N�g�ł��\���܂���B:
%      fun = inline('1 ./ (1 + exp(b(1) + b(2)*x))', 'b', 'x')
%      nlintool(x, y, fun, b0)
%
% �Q�l : NLPARCI, NLPREDCI, NLINTOOL.


%   Copyright 1993-2002 The MathWorks, Inc. 
% $Revision: 1.6 $  $Date: 2003/02/12 17:14:05 $
