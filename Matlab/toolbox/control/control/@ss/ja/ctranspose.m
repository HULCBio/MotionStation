% CTRANSPOSE   ��ԋ�ԃ��f���̋���]�u
%
% TSYS = CTRANSPOSE(SYS) �́Atsys = SYS' �����s���܂��B
%
% �f�[�^(A,B,C,D)�����A�����ԃ��f�� SYS �ɑ΂��āACTRANSPOSE �́A�f�[�^
% (-A',-C',B',D')������ԋ�ԃ��f�� TSYS ���o�͂��܂��BH(s) ���ASYS ��
% �`�B�֐��̏ꍇ�AH(-s).'�́ATSYS�̓`�B�֐��ɂȂ�܂��B
%
% �f�[�^(A,B,C,D)�������U���ԃ��f�� SYS �ɑ΂��āATSYS �́A�f�[�^ 
% (AA, AA*C', -B'*AA, D'-B'*AA*C')������ԋ�ԃ��f���ɂȂ�܂��B�����ŁA
% AA =inv(A') �ł��B�܂��AH(z) �� SYS �̓`�B�֐��̏ꍇ�AH(z^-1).' �́A
% TSYS �̓`�B�֐��ɂȂ�܂��B
%
% �Q�l : TRANSPOSE, SS, LTIMODELS.


%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
