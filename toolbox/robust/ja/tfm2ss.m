% TFM2SS   �`�B�֐��s��̏�ԋ�Ԏ���
%
% [SS_] = TFM2SS(TFM)�܂���[A,B,C,D] = TFM2SS(NUM,DEN,M,N)�́A
% �v���p�ȗL���`�B�֐��s��(MIMO)�̏�ԋ�ԃu���b�N�R���g���[��
% (�܂��̓I�u�U�[�o)�^���쐬���܂��B
%
%                   |N11(s) N12(s) .... N1m(s)|
%     TFM  = 1/d(s) | ........................| = mksys(num,den,m,n,'tfm');
%                   |Nn1(s) ........... Nnm(s)|
%
%     NUM : �s���`�B�֐��s��v�f�̕��q�W���ł���s��(n11-->row1, 
%           n21-->row2��)
%     DEN : ����������d(s)�̌W�����܂ލs�x�N�g��(�ő原��: r)
%     M   : �V�X�e�����͐�
%     N   : �V�X�e���o�͐�
%
% ����: ���ʂ̍s��A�́A�ŏ������łȂ�"r�smin(m,n)��"�̏�Ԃ������Ȃ����
%       �Ȃ�܂���B�ʏ�̏�ԋ�Ԃ́A"branch"�ŋ��߂邱�Ƃ��ł��܂��B



% Copyright 1988-2002 The MathWorks, Inc. 
