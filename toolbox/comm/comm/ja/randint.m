% RANDINT   ��l���z���闐�������̍s��̍쐬
%
% OUT = RANDINT �́A�������m���ŁA"0"�A�܂��́A"1"�𐶐����܂��B
%
% OUT = RANDINT(M) �́AM �s M ��̃����_���ȃo�C�i���s����쐬���܂��B
% "0" �� "1" �́A�����m���Ő����܂��B
%
% OUT = RANDINT(M,N) �́AM �s N ��̃����_���ȃo�C�i���s����쐬���܂��B
% "0" �� "1" �́A�����m���Ő����܂��B
%
% OUT = RANDINT(M,N,RANGE) �́AM �s N ��̃����_���Ȑ������쐬���܂��B
%
% RANGE �́A�X�J���A�܂��́A2�v�f�x�N�g���̂����ꂩ�ł��B:
% �X�J��   : RANGE �����̐����̏ꍇ�A�o�͐����͈̔͂� [0, RANGE-1] ��
%            �Ȃ�܂��BRANGE �����̐����̏ꍇ�A�o�͐����͈̔͂� 
%            [RANGE+1, 0] �ɂȂ�܂��B
% �x�N�g�� : RANGE ��2�v�f�x�N�g���̏ꍇ�A�o�͐����͈͂�
%            [RANGE(1), RANGE(2)]�ɂȂ�܂��B
%
% OUT = RANDINT(M,N,RANGE,STATE) �́ARAND �̏�Ԃ� STATE �Ƀ��Z�b�g���܂��B
%
% ���F
%    >> out = randint(2,3)               >> out = randint(2,3,4)  
%    out =                              out =                 
%         0     0     1                      1     0     3
%         1     0     1                      2     3     1
%                                                                  
%    >> out = randint(2,3,-4)            >> out = randint(2,3,[-2 2])  
%    out =                              out =                   
%        -3    -1    -2                     -1     0    -2
%        -2     0     0                      1     2     1
%
% �Q�l�F RAND, RANDSRC, RANDERR.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/06/23 04:35:06 $
