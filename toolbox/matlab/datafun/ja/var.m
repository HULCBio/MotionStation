% VAR    ���U 
% 
% �x�N�g���ɑ΂��āAY = VAR(X)�́AX�̕��U���o�͂��܂��B
% �s��ɑ΂��āAY �́AX�̊e��̕��U���܂ލs�x�N�g���ł��B
% N �����z��ɑ΂��āAVAR�́AX �̍ŏ���1�łȂ������ő��삵�܂��B
%
% VAR�́AN����̒����̂Ƃ��AY�� N-1�Ő��K�����܂��B����́AX �����K���z��
% ��T���v���̏ꍇ�A���U�̍ł��ǂ��o�C�A�X�̂������Ă��Ȃ�����ł��B
%
% Y = VAR(X,1)�́AN�Ő��K�����A���̕��ςɊւ���T���v����2�����[�����g���o
% �͂��܂��B
%
% Y = VAR(X,W) �́A�d�݃x�N�g��W���g���ĕ��U���v�Z���܂��BW�̗v�f���́AW = 1
% �̏ꍇ�������āAX�̍s���Ɠ������Ȃ���΂Ȃ�܂���BW = 1 �̏ꍇ�́A1��
% �v�f�Ƃ���x�N�g���ɑ΂���V���[�g�J�b�g�Ƃ��Ĉ����邩��ł��B
%
% W�̗v�f�͐��łȂ���΂Ȃ�܂���BVAR�́AW���̊e�v�f���A���ׂĂ̗v�f��
% �a�ŏ��Z���邱�Ƃɂ��W�𐳋K�����܂��B
%
% ���U�́A�W���΍�(STD)�̓��ł��B 
%
% ���: X = [4 -2 1
%            9  5 7]
%   �̏ꍇ�Avar(X,0,1) �� [12.5 24.5 18.0] �ł���A var(X,0,2) �� [9.0  �ł��B
%                                                                  4.0]
%
% �Q�l MEAN, STD, COV, CORRCOEF.

% VAR �́A���U�̈�ʂ̒�`�𗼕��Ƃ���`���܂��B  
% X ���x�N�g���̏ꍇ�A
%
%      VAR(X) = SUM(RESID.*CONJ(RESID)) / (N-1)
%      VAR(X,1) = SUM(RESID.*CONJ(RESID)) / N
%
% �����ŁARESID = X - MEAN(X) �ł���A N �� LENGTH(X) �ł��B
%
% �x�N�g�� X �ɑ΂���d�ݕt���̕��U�́A���̂悤�ɒ�`����܂��B
%
%      VAR(X,W) = SUM(W.*RESID.*CONJ(RESID)) / SUM(W)
%
% �����ŁARESID �́A�d�ݕt���̕��ς��g�p���Čv�Z����܂��B

%   Copyright 1984-2003 The MathWorks, Inc.
