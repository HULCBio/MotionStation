% SUBSASGN   �T�u�X�N���v�g���g�������
% 
% A(I) = B �́AB �̒l���T�u�X�N���v�g�x�N�g�� I �Ŏw�肵�� A �̗v�f��
% ���蓖�Ă܂��BB �́AI �Ɠ������̗v�f�����x�N�g���܂��̓X�J���łȂ����
% �Ȃ�܂���B
%
% A(I,J) = B �́AB �̒l���T�u�X�N���v�g�x�N�g�� I �� J �Ŏw�肵�� A ��
% �����`�T�u�s��̗v�f�Ɋ��蓖�Ă܂��BB �́ALENGTH(I) �s LENGTH(J) ���
% �Ȃ���΂Ȃ�܂���BA(I,:) = B �̂悤�ɁA�T�u�X�N���v�g�Ƃ��Ďg�p
% �����R�����́A��(�܂��͍s)�S�̂������܂��B
%
% �������z��ɑ΂��āAA(I,J,K,...) = B �́AB �� A �̎w�肵���v�f�Ɋ���
% ���Ă܂��BB �́ALENGTH(I)*LENGTH(J)*LENGTH(K)*... ���A1�̎�����ǉ�
% �܂��͍폜���āA���̃T�C�Y�ɃV�t�g�\�łȂ���΂Ȃ�܂���B
%
% A{I} = B �́AA ���Z���z��� I ���X�J���̂Ƃ��A�z�� B �̃R�s�[�� A ��
% �w�肵���Z���ɔz�u���܂��BI �̗v�f��2�ȏ�̏ꍇ�́A���̎��̓G���[��
% �Ȃ�܂��BB �̃R�s�[�� A �̕����̃Z���ɔz�u���邽�߂ɂ́A[A{I}] = DEAL(B) 
% ���g���Ă��������BA{3,4} = magic(3) �̂悤�ɁA�X�J���v�f���w�肷�镡��
% �̃T�u�X�N���v�g���g�����Ƃ��ł��܂��B
%
% A(I).field = B �́AA ���\���̔z��� I ���X�J���̂Ƃ��A�z�� B �̃R�s�[
% �� 'field' �Ƃ������O�̃t�B�[���h�ɔz�u���܂��BI �������v�f�����ꍇ
% �ɂ́A���̎��̓G���[�ɂȂ�܂��BB �̃R�s�[�� A �̕����̗v�f�ɔz�u����
% ���߂ɂ́A[A(I).field] = DEAL(B) ���g���Ă��������BA ��1�s1��̍\����
% �z��̏ꍇ�A�T�u�X�N���v�g�̓h���b�v����܂��B���̏ꍇ�AA.field = B �� 
% A(1).field = B�Ɠ����ł��B
%
% A = SUBSASGN(A,S,B) �́AA ���I�u�W�F�N�g�̂Ƃ��A�V���^�b�N�X A(I) = B�A
% A{I} = B�AA.I = B �ɑ΂��ČĂяo����܂��BS �́A���̃t�B�[���h������
% �\���̔z��ł��B
% 
%     type -- '()'�A'{}'�A'.' ���܂ޕ�����B�T�u�X�N���v�g�̃^�C�v���w��
%             ���܂��B
%     subs -- ���ۂ̃T�u�X�N���v�g���܂ރZ���z��܂��͕�����B
%
% ���Ƃ��΁AS �� S.type = '()' ���� S.subs = {1:2,':'} �ł���1�s1��̍\���̂�
% �Ƃ��A�V���^�b�N�X A(1:2,:) = B �́AA = SUBSASGN(A,S,B) ���Ăяo���܂��B
% �T�u�X�N���v�g�Ƃ��Ďg����R�����́A������ ':' �Ƃ��ēn����܂��B
%
% ���l�ɁAS.type = '{}' �̂Ƃ��A�V���^�b�N�X A{1:2} = B �́A
% A = SUBSASGN(A,S,B) ���Ăэ��݁AS.type = '.' ���� S.subs = 'field' 
% �̂Ƃ��A�V���^�b�N�X A.field = B �́ASUBSASGN(A,S,B) ���Ăэ��݂܂��B
%
% �����̊ȒP�ȃR�[���́A��蕡�G�ȃT�u�X�N���v�g�\���ɑ΂��ĕ�����Ղ�
% ���@�őg�ݍ��킳��܂��B���̂悤�ȏꍇ�Alength(S) �̓T�u�X�N���v�g��
% ���x�����ł��B���Ƃ��΁AS �����̂悤�Ȓl������3�s1��̍\���̔z���
% �Ƃ��AA(1,2).name(3:5) = B �́AA = SUBSASGN(A,S,B) ���Ăэ��݂܂��B
% 
%     S(1).type = '()'       S(2).type = '.'        S(3).type = '()'
%     S(1).subs = {1,2}      S(2).subs = 'name'     S(3).subs = {3:5}
%
% �Q�l�FSUBSREF, SUBSTRUCT, PAREN, SUBSINDEX, LISTS.


%   Copyright 1984-2004 The MathWorks, Inc. 
