% INTERPFT   FFT(�����t�[���G�ϊ�)�@���g����1�������
% 
% Y = INTERPFT(X,N) �́AX �̃t�[���G�ϊ��ŕ�Ԃɂ���ē����钷�� N ��
% �x�N�g�� Y ���o�͂��܂��B 
%
% X ���s��̏ꍇ�A��Ԃ͊e��ɑ΂��čs���܂��B
% X ���z��̏ꍇ�A��Ԃ͍ŏ���1�łȂ������ɑ΂��čs���܂��B
%
% INTERPFT(X,N,DIM) �́A���� DIM �ɂ��ĕ�Ԃ��s���܂��B
%
% x(t) ���A���Ԋu�̓_�ŃT���v�����O���ꂽ��� p ������ t �̎����֐���
% ���肷��ƁAT(i) = (i-1)*p/M�Ai = 1:M�AM = length(X) �̂Ƃ��A
% X(i) = x(T(i)) �ƂȂ�܂��By(t) �́A������Ԃ������̎����֐��ŁA
% T(j) = (j-1)*p/N�Aj = 1:N�AN = length(Y) �̂Ƃ��AY(j) = y(T(j)) ��
% �Ȃ�܂��BN �� M �̐����{�̏ꍇ�AY(1:N/M:N) = X�ɂȂ�܂��B
%
% �f�[�^���� x �̃T�|�[�g�N���X
%      float: double, single
%  
% �Q�l INTERP1.

%   Robert Piche, Tampere University of Technology, 10/93.
%   Copyright 1984-2004 The MathWorks, Inc. 