% CHOLUPDATE   Cholesky�����̃����N1�̍X�V
% 
% R = CHOL(A) �� A �̃I���W�i����Cholesky�����̏ꍇ�A
% R1 = CHOLUPDATE(R,X) �́AA + X*X' �̏�O�pCholesky�������o�͂���
% ���BX �́A�K�؂Ȓ����̗�x�N�g���ł��BCHOLUPDATE �́AR �̑Ίp����
% �Ə�O�p�����݂̂��g���܂��BR �̉��O�p�����͖�������܂��B
%
% R1 = CHOLUPDATE(R,X,'+') �́AR1 = CHOLUPDATE(R,X) �Ɠ����ł��B
%
% R1 = CHOLUPDATE(R,X,'-') �́AA - X*X' ��Cholesky�������o�͂��܂��B
% R ���L����Cholesky�����łȂ����A�_�E���f�[�g���ꂽ�s�񂪐���s���
% �Ȃ��ꍇ�̓G���[���b�Z�[�W���\������ACholesky�����͍s���܂���B
%
% [R1,p] = CHOLUPDATE(R,X,'-') �́A�G���[���b�Z�[�W���o�͂��܂���Bp ��0
% �̏ꍇ�́AR1 �� A - X*X' ��Cholesky�����ł��Bp ��0���傫����΁A
% R1�̓I���W�i���� A ��Cholesky�����ł��Bp ��1�̏ꍇ�́A�_�E���f�[�g��
% �ꂽ�s�񂪐���s��łȂ��̂ŁACHOLUPDATE �͎��s���܂��Bp ��2��
% �ꍇ�́AR �̏�O�p�������L����Cholesky�����łȂ��̂ŁA
% CHOLUPDATE �͎��s���܂��B
%
% CHOLUPDATE �́A�t���s��ɑ΂��Ă̂݋@�\���܂��B
%
% �Q�l�FCHOL.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:59:41 $
%   Built-in function.

