% TREEFIT   ���ނ܂��͉�A�ɑ΂�����`���f���̋ߎ�
%
% T = TREEFIT(X,Y) �́A�\���ϐ� X �̊֐��Ƃ��ĉ��� Y ��\�����邽�߂�
% ����� T ���쐬���܂��BX �́A�\���q�� N�~M �s��ł��BY �́A(��A��
% �΂���) N �̉����l�̃x�N�g�����A�܂��́A(���ނɑ΂���) N �̕��ޖ���
% �܂ޕ�����̕����z�񂩃Z���z��̂ǂ��炩�ł��B�ǂ���ɂ���AT �́A
% X �̗�̒l�Ɋ�Â��ČX�̏I�[�ł͂Ȃ��m�[�h���番�򂵂Ă�����i�؂ł��B
%
% T = TREEFIT(X,Y,'PARAM1',val1,'PARAM2',val2,...) �́A�I�v�V������
% �p�����[�^ ��/�l �̑g���w�肵�܂��B:
%
% ���ׂẴc���[�ɑ΂���:
%    'catidx'     X ����ׂ��Ă��Ȃ��J�e�S���ϐ��Ƃ��Ď�舵�����߂�
%                 X �̗�̃C���f�b�N�X�x�N�g���ł��B
%    'method'     'classification' (Y ���e�L�X�g�̏ꍇ�A�f�t�H���g�ł�)
%                 �܂��́A'regression' (Y �����l�̏ꍇ�A�f�t�H���g�ł�)
%    'splitmin'   �� N�B�s�������܂ރm�[�h�́AN ���A���邢�͕�����
%                 ���߂̂�葽���̊ϑ��������Ȃ���΂Ȃ�܂���B
%                 (�f�t�H���g�� 10 �ł�)
%    'prune'      ���S�ȃc���[�ƃT�u�c���[���폜����œK�菇���v�Z����
%                 �ɂ�'on' (�f�t�H���g) �ŁA�T�u�c���[�͍폜�������S��
%                 �c���[�������߂�ꍇ��'off'
%
% ���ޖ؂݂̂ɑ΂���:
%    'cost'       �����s�� C�BC(i,j) �́A�^�̃N���X�� j �ł���_���N��
%                 �X i �ɕ��ނ����ꍇ�̃R�X�g�ł��B(i~=j �̏ꍇ�A�f�t�H
%                 ���g�� C(i,j)=1 �ŁAi=j �̏ꍇ�AC(i,j)=0 �ł�)�B����
%                 ���́A���̒l��2�̃t�B�[���h�����\���� S �ɒu��
%                 �����邱�Ƃ��ł��܂��B: S.group �́A�����̕����z��
%                 �܂��̓Z���z��Ƃ��ăO���[�v�����܂݁AS.cost �́A
%                 �R�X�g�s�� C ���܂݂܂��B
%    'splitcriterion'  �������@�����߂��BGini �̑���_�C���f�b�N�X
%                 �ɑ΂��� 'gdi' (�f�t�H���g)���Atwoing �K���ɑ΂���
%                 'twoing'�A�܂��́A�ޗ��x���ł����������� 'deviance' 
%                 �̂����ꂩ�ɂȂ�܂��B
%    'priorprob'  (�X�̈قȂ����O���[�v���ɑ΂���1�̒l�ƂȂ�)�x�N�g��
%                 ���A�܂���2�̃t�B�[���h�����\���� S �Ƃ��Ďw�肳�ꂽ�A
%                 �e���ނɑ΂��鎖�O�m���B�t�B�[���h�͂��̒ʂ�ł��B: 
%                 S.group �́A�����̕����z�񂩃Z���z��Ƃ��ăO���[�v����
%                 �܂݁AS.prob �́A�Ή�����m���̃x�N�g�����܂�ł��܂��B
%
% ���:  Fisher �� iris data �ɑ΂��镪�ޖ؂��쐬���܂��B
%    load fisheriris;
%    t = treefit(meas, species);
%    treedisp(t,'names',{'SL' 'SW' 'PL' 'PW'});
%
% �Q�l : TREEDISP, TREEPRUNE, TREETEST, TREEVAL.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/05/09 18:27:30 $
