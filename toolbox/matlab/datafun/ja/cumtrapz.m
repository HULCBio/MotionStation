% CUMTRAPZ   �ݐϑ�`���l�ϕ�
% 
% Z = CUMTRAPZ(Y)�́A(�P�ʊԊu�ł�)��`�ϕ��@���g���āAY�̗ݐϐϕ��̋ߎ�
% ���v�Z���܂��B�P�ʊԊu�łȂ��ϕ����v�Z���邽�߂ɂ́A�Ԋu�̑�����Z�Ɋ|
% ���Ă��������B 
%
% Y���x�N�g���̏ꍇ�ACUMTRAPZ(Y)��Y�̗ݐϐϕ����܂ރx�N�g�����o�͂��܂��B
% Y���s��̏ꍇ�ACUMTRAPZ(Y)�́A�e��ł̗ݐϐϕ���v�f�ɂ��AX�Ɠ�����
% �����̍s����o�͂��܂��BY��N�����z��̏ꍇ�ACUMTRAPZ(Y)�͍ŏ���1�łȂ�
% �����ɂ��ċ@�\���܂��B
%
% Z = CUMTRAPZ(X,Y)�́A��`�ϕ����g���āAX�ɑ΂���Y�̗ݐϐϕ����v�Z����
% ���B X��Y�́A���������̃x�N�g���A�܂��́AX�͗�x�N�g���ŁAY�͍ŏ���1��
% �Ȃ�������length(X)�ł���z��łȂ���΂Ȃ�܂���BCUMTRAPZ�́A���̎�
% ���ɂ��ċ@�\���܂��B
%
% Z = CUMTRAPZ(X,Y,DIM)�A�܂��́ACUMTRAPZ(Y,DIM) �́AY�̒���DIM�Ŏw�肳��
% ��Y�̎����ɂ��Đϕ����s���܂��BX�̒����́Asize(Y,DIM) �Ɠ����łȂ���
% �΂Ȃ�܂���B
%
% ���:
% 
%   Y = [0 1 2
%        3 4 5]
%
% �̏ꍇ�Acumtrapz(Y,1) �� [0   0   0     �ŁAcumtrapz(Y,2) �� [0 0.5 2  
%                           1.5 2.5 3.5]                        0 3.5 8];
% �ł��B
% 
%
% 
% �Q�l�FCUMSUM, TRAPZ.


%   Clay M. Thompson, 10-16-90, 1-9-95; Cleve Moler, 1-19-92.
%   Copyright 1984-2003 The MathWorks, Inc. 
