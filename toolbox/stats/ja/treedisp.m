% TREEDISP   ���ނ܂��͉�A�؂̃O���t�B�J���ȕ\��
%
% TREEDISP(T) �́ATREEFIT �֐��ɂ���Čv�Z���ꂽ����� T ����͂Ƃ��A
% figure �E�B���h�E�ɕ\�����܂��B�c���[�̊e�}�ɂ́A����K�����\������A
% �e�I�[�m�[�h�ɂ́A�m�[�h�ɑ΂���\���q���\������܂��B�C�ӂ̃m�[�h��
% �N���b�N���邱�ƂŁAfigure �̈�ԏ�̃|�b�v�A�b�v���j���[�Ŏw�肳���
% ����悤�ȃm�[�h�Ɋւ���ǉ����𓾂邱�Ƃ��ł��܂��B
%
% TREEFIT(T,'PARAM1',val1,'PARAM2',val2,...) �́A�I�v�V�����p�����[�^
% ��/�l �̑g�ݍ��킹���w�肵�܂��B:
%
%    'names'       �\���ϐ��ɑ΂��閼�O�̃Z���z��B
%                  �c���[���쐬���ꂽ X �̍s����ɂ���炪����鏇�ł�
%                  (TREEFIT ���Q��)
%    'prunelevel'  �͂��߂ɕ\������}�̍폜(pruning)���x��
%
% �e�}�̃m�[�h�ɑ΂��āA�����̎q�m�[�h�͏����𖞂����_�ɑΉ����A�E����
% �q�m�[�h�́A�����𖞂����Ȃ��_�ɑΉ����܂��B
%
% ���:  Fisher�� ires data �ɑ΂��镪�ޖ؂��쐬���A�\�����܂��B
%        ���O�́A��̓��e(sepal length, sepal width, petal length, 
%        petal width)�ɑ΂��闪��ł��B
%    load fisheriris;
%    t = treefit(meas, species);
%    treedisp(t,'names',{'SL' 'SW' 'PL' 'PW'});
%
% �Q�l : TREEFIT, TREETEST, TREEPRUNE, TREEVAL.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/05/09 18:27:30 $


