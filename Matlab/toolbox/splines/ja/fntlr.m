% FNTLR   �e�C���[(Taylor)�W�����邢�͑�����
%
% FNTLR(F,DORDER,X) �́AX �ɂ����鎟�� DORDER �� F �̃e�C���[(Taylor)
% �W�����o�͂��܂��BDORDER �́A�e�C���[(Taylor)�̃x�N�g���ł��B
%
%      T(F,DORDER,X) := [F(X); DF(X); ...; D^(DORDER-1)F(X)]
%
% ���̏ꍇ F �͈�ϐ��ŁAX �̓X�J���ł��B
%
% ����ʓI�ɁAX ���s��̏ꍇ�A�e�C���[(Taylor)�̃x�N�g���ɑΉ�������̂�
% �e���͂�u�������邱�Ƃɂ���āAX ���瓾��ꂽ�s�񂪏o�͂���܂��B
%
% ����ʓI�ɁAF �� d>1�A�܂��� length(d)>1 �ł���d�̒l�������A
% �����/���邢�́A�����炩�� m>1 �ɑ΂���m�ϐ��֐��ł���ꍇ�ADORDER 
% �́A���̐�����m�̃x�N�g���ł��邱�Ƃ��v������A�܂� X �́Am�s�̍s���
% ���邱�Ƃ��v������܂��B�����Ă��̏ꍇ�A
%
%     T(F,DORDER,X(:,j))(i1,...,im) = D_1^{i1-1}...D_m^{im-1}F(X(:,j))
%
%                                       i1=1:DORDER(1), ..., im=1:DORDER(m).
%
% ��j�Ԗڂ̗�Ƃ��Ċ܂ށA�傫�� [prod(d)*prod(DORDER),size(x,2)] �̏o��
% �ƂȂ�܂��B
%
% FNTLR(F,DORDER,X,INTERV) �́AX �� [m,1] �̑傫���ŁAINTERV �� [m,2] 
% �̑傫���ŗ^�����AF �ɂ���ċL�q���ꂽm�ϐ��֐��ɑ΂��āA�^����ꂽ
% ��{��Ԃ������� DORDER �� X �ɂ�����e�C���[(Taylor)��������pp-�^��
% �o�͂��܂��B
%
% �Ⴆ�΁Afntlr(f,3,x) �́A
%
%   df = fnder(f); [fnval(f,x); fnval(df,x); fnval(fnder(df),x)]
%
% �Ɠ����o�͂𐶐����܂��B
%
% ����́Af �ɂ���ċL�q���ꂽ�֐����L���X�v���C���̏ꍇ�ŁAfnder(f) ��
% �G���[���b�Z�[�W�̂ݐ�������ꍇ�ɓ��ɖ𗧂��܂��B
% �Ⴆ�΁A�ȉ��́A�L����Runge�֐��̃v���b�g�ƈꎟ������^���܂��B:
%      runge = rpmak([-5 5],[0 0 1; 1 -10 26],1);  x = -5:.1:5;
%      tlr = fntlr(runge,2,x);
%      plot(x,tlr)
%   
% �Ⴆ�΁Af ���敪�I��bicubic�֐����L�q���Ă���ꍇ�A
%
%   tp = fntlr(f,[4 4],[0;0],[-1 1;-1 1]);
%
% �́A���_ (0,0) ���܂މ�ꂽ�l�p(break-rectangle)��̊֐��Ɉ�v����
% ���������L�q���܂��B
%
% �Q�l : FNDER, FNDIR, FNVAL.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
