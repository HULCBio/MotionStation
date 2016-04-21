% SECTF88 �́A1988�N�o�[�W�����̃Z�N�^�ϊ��ł��B
%
% [SS_P] = SECTF(SS_,d11,a,b,sectype)�A�܂��́A
% [Ap,Bp,Cp,Dp] = SECTF(A,B,C,D,d11,a,b,sectype) �́A�Z�N�^[a,b]�̒��̃I��
% �W�i���̓���-�o�͑g(U1,Y1)�����̃Z�N�^[x,y]�Ƀ}�b�s���O�����悤�ȃv��
% ���g P(s)�̓���-�o�̓`�����l��1�A���X�̊֌W�̃`�����l���ɁA���ϐ��Z�N�^
% �o�ꎟ�ϊ����K�p����܂��B
%
%                           |A  B1  B2 |
%           P(s) := |A B| = |C1 D11 D12|
%                   |C D|   |C2 D21 D22|
%
%           d11 = D11 �Ɠ��l�ȃT�C�Y�̍s��
%
% 4�̃I�v�V����������܂�(0 < b <= inf, a < b�̊֌W���K�v)�B
%
%       sectype = 1, sector(a,b) -----> sector(0,inf) = ���̎����
%       sectype = 2, sector(a,b) -----> sector(-1,1)  = �X���[���Q�C�����
%       sectype = 3, sector(0,inf) ---> sector(a,b) (sectype 1�̋t�ʑ�)
%       sectype = 4, sector(-1,1) ----> sector(a,b) (sectype 2�̋t�ʑ�)
%

% Copyright 1988-2002 The MathWorks, Inc. 
