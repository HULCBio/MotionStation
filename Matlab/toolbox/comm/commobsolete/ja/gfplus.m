% GFPLUS   �w�W2 �̃K���A�̂̌������Z
%
% C = GFPLUS(A, B, FVEC, IVEC) �́AGF(2^M) ��2�̌� A �� B �����Z���܂��B
% A, B, C �́A�w���`�����g���� GF(2^M) �̌���\�����܂��B�܂�A
% alpha^C = alpha^A + alpha^B �ł��B������ GF(2^M) �̌��n���� alpha �ł��B
% A �� B �̗v�f�� -Inf �� 2^M-2 �̊Ԃ̐����łȂ���΂Ȃ�܂���B�S�Ă�
% ���̗v�f�́Aalpha^-Inf = 0 ��\�����܂��B
%
% A �� B �̓X�J�����A�܂��̓x�N�g���A�s�����蓾�܂��BA �� B ��������
% �X�J���łȂ��ꍇ�́A�����T�C�Y�łȂ���΂Ȃ�܂���BA �� B �ǂ��炩��
% �X�J���ŁA���̈�����x�N�g�����s��̏ꍇ�́A�X�J�����͂͊g������܂��B
%
% FVEC �� IVEC �͒��� 2^M �̃x�N�g���ł��B�����̗v�f�� 0 �� 2^M-1 �̊Ԃ�
% �����ł��BFVEC �́AFVEC ���x�N�g���Ɋȗ�������Ă��邱�ƈȊO�́AGFADD 
% �Ŏg���� FIELD �p�����[�^�Ɠ��������܂݂܂��BFVEC �� IVEC �́A
% ���̎��ɂ���ċ��߂邱�Ƃ��ł��܂��B
%   FVEC = GFTUPLE([-1 : 2^M-2]',M) * 2.^[0 : M-1]';
%   IVEC(FVEC+1) = 0 : 2^M-1;
%
% GFPLUS �� GFADD �̗����́A GF(2^M) �̌������Z���܂����A�����̏ꍇ�A
% GFPLUS �̕��������ł��B
%    
% �Q�l : GFADD, GFSUB.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $   $Date: 2003/06/23 04:36:00 $
