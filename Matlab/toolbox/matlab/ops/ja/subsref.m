% SUBSREF   �T�u�X�N���v�g�̎Q��
% 
% A(I) �́A�T�u�X�N���v�g�x�N�g�� I �Ŏw�肳�ꂽ A �̗v�f����Ȃ�z��ł��B
% A �� I �̗������x�N�g���ł������ȏꍇ�������āA���ʂ̔z��́AI �Ɠ���
% �傫���ł��B���̏ꍇ�AA(I) �� I �Ɠ����v�f���ŁAA �Ɠ��������������܂��B
% 
% A(I,J) �́A�T�u�X�N���v�g�x�N�g�� I �� J �Ŏw�肳�ꂽ A �̒����`�T�u�s���
% �v�f����Ȃ�z��ł��B���ʂ̔z��́ALENGTH(I) �s LENGTH(J) ��ł��B
% A(I,:)�� �悤�ɁA�T�u�X�N���v�g�Ƃ��Ďg�p�����R�����́A��(�܂��͍s)�S�̂�
% �����܂��B
%
% �������z��ɑ΂��āAA(I,J,K,...) �́A�T�u�X�N���v�g�Ŏw�肳���T�u�z��
% �ł��B���ʂ́ALENGTH(I)*LENGTH(J)*LENGTH(K)...�ł��B
%
% A{I} �́AA ���Z���z��� I ���X�J���̂Ƃ��AA �̎w�肵���Z�����̔z���
% �R�s�[�ł��BI �̗v�f��2�ȏ�̏ꍇ�́A���̎��̓J���}�ŋ�؂�ꂽ���X�g
% �ɂȂ�܂�(LIST ���Q��)�BA{3,4} �̂悤�ȁA�X�J���v�f���w�肷�镡����
% �T�u�X�N���v�g���g�����Ƃ��ł��܂��B
%
% A(I).field �́AA ���\���̔z��� I ���X�J���̂Ƃ��A'field' �Ƃ������O��
% �t�B�[���h���̔z��̃R�s�[�ł��BI �̗v�f��2�ȏ�̏ꍇ�́A���̎���
% �J���}�ŋ�؂�ꂽ���X�g�ɂȂ�܂��BA ��1�s1��̍\���̔z��̏ꍇ�́A
% �T�u�X�N���v�g�͍폜����܂��B���̏ꍇ�AA.field �� A(1).field �Ɠ����ł��B
%
% B = SUBSREF(A,S) �́AA ���I�u�W�F�N�g�̂Ƃ��A�V���^�b�N�X A(I)�AA{I}�A
% A.I �ɑ΂��āA�Ăяo����܂��BS �́A���̃t�B�[���h�����\���̔z��ł��B
% 
%     type -- '()'�A'{}'�A'.'���܂ޕ�����B�T�u�X�N���v�g�̃^�C�v���w��
%             ���܂��B
%     subs -- ���ۂ̃T�u�X�N���v�g���܂ރZ���z��܂��͕�����B
%
% ���Ƃ��΁AS �� S.type = '()' ���� S.subs = {1:2,':'} �ł���1�s1���
% �\���̂̂Ƃ��A�V���^�b�N�XA(1:2,:) �́ASUBSREF(A,S) ���Ăэ��݂܂��B
% �T�u�X�N���v�g�Ƃ��Ďg����R�����́A������ ':' �Ƃ��ēn����܂��B
%
% ���l�ɁAS.type = '{}' �̂Ƃ��A�V���^�b�N�X A{1:2} ��SUBSREF(A,S) ��
% �Ăэ��݁AS.type = '.' ���� S.subs = 'field' �̂Ƃ��A�V���^�b�N�X �A
% A.field �� SUBSREF(A,S) ���Ăэ��݂܂��B
%
% �����̊ȒP�ȃR�[���́A��蕡�G�ȃT�u�X�N���v�g�\���ɑ΂��ĕ�����Ղ�
% ���@�őg�ݍ��킳��܂��B���̂悤�ȏꍇ�Alength(S) �̓T�u�X�N���v�g��
% ���x�����ł��B���Ƃ��΁AS �����̂悤�Ȓl������3�s1��̍\���̔z���
% �Ƃ� A(1,2).name(3:5) �� SUBSREF(A,S) ���Ăэ��݂܂��B
% 
%     S(1).type = '()'       S(2).type = '.'        S(3).type = '()'
%     S(1).subs = {1,2}      S(2).subs = 'name'     S(3).subs = {3:5}
%
% �Q�l�FSUBSASGN, SUBSTRUCT, PAREN, SUBSINDEX, LISTS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:01:06 $
%   Built-in function.
