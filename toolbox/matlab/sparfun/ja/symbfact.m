% �V���{���b�N�ȕ������
% 
% count = SYMBFACT(A) �́A��O�p�s�� A �̏�O�p�s��ł���A�Ώ̍s��
% �̏�O�pCholesky���q�ɑ΂���s�̃J�E���g����Ȃ�x�N�g�����o�͂��܂��B
% ���𒆂ɃL�����Z���͂Ȃ��Ɖ��肵�Ă��܂��B���̃��[�`���́Achol(A) 
% ���������ł��B
%
% count = SYMBFACT(A,'col') �́AA'*A ��(�����I�ɍ쐬������)��͂��܂��B
% count = SYMBFACT(A,'sym') �́Ap = symbfact(A) �Ɠ����ł��B
%
% �I�v�V�����̏o�͒l������܂��B
%
% [count,h,parent,post,R] = symbfact(...) �́A���̂��̂��o�͂��܂��B
%      �����c���[�̍���
%      �����c���[
%      �����c���[��postordering�u��
%      �\���̂� chol(A) �̍\���̂Ɠ�����0-1�s�� R
%
% �Q�l�FCHOL, ETREE, TREELAYOUT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:03:40 $
