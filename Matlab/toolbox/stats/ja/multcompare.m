% MULTCOMPARE   ���ϒl���邢�͑��̐���ʂɊւ��鑽�d��r����̎��s
%
% MULTCOMPARE�́A(�X���A�ؕЁA���ς̂悤��)���肪�L�ӂȍ������悤��`
% ���ꂽ����q���U����(ANOVA)�܂���ANOCOVA�̌��ʂ�p�������d��r�����
% �s���܂��B
%
% COMPARISON = MULTCOMPARE(STATS) �́A�ȉ��̊֐��̂ǂꂩ����o�͂Ƃ���
% ������\���� STATS �̏����g�p���đ��d��r��������s���܂��B:
% anova1�Aanova2�Aanovan�Aaoctool�Akruskalwallis�Afriedman
% �o�͒l COMPARISON �́A��r�ɑ΂���1�̍s��5�̗�����s��ł��B
% 1-2��ڂ́A��r����Ă���2�̃T���v���̃C���f�b�N�X�ł��B3-5��ڂ́A
% ����̉��E�Ƃ����̍��ɑ΂����E�ł��B
%
% COMPARISON = MULTCOMPARE(STATS, 'PARAM1',val1, 'PARAM2',val2,...) �́A
% �ȉ��̖��O/�l�̑g�ݍ��킹��1���邢�͂���ȏ���w�肵�܂��B:
%   
%     'alpha'       100*(1-ALPHA)%�̋�Ԃ̐M���������w�肵�܂��B
%                   (�f�t�H���g 0.05).
%     'displayopt'  �O��̋�Ԃ��r���鐄��̃O���t��\������ɂ� 'on'
%                   (�f�t�H���g)�ŁA�O���t���ȗ�����ɂ� 'off' �̂����ꂩ��
%                   �w�肵�܂��B
%     'ctype'       ���E�l���g�p���邽�߂̃^�C�v�B�I���ł���̂́A
%                   'tukey-kramer'(�f�t�H���g)�A'dunn-sidak'�A'bonferroni'�A
%                   'scheffe' �ł��B�����̌��E�l�̍ŏ����g�p���邽�߂ɁA
%                   �����̑I������2���A����ȏ���X�y�[�X�ŕ�������
%                   ���͂��Ă��������B
%     'dimension'   1�̎����A�܂��͕�W�c���ӕ��ς��v�Z�����S�̂�
%                   �������w�肷��x�N�g���ł��BSTATS �� anovan ���琶��
%                   �����Ƃ��̂ݎg�p����܂��B�f�t�H���g�́A1�Ԗڂ�
%                   �����S�̂��v�Z���邽��1�ł��B�Ⴆ�� [1 3] �̏ꍇ�A
%                   �ŏ���3�Ԗڂ̗\���q�̊e�����ɑ΂����W�c���ӕ��ς�
%                   �v�Z���܂��B
%     'estimate'    ��r�̂��߂̐���ł��B�I���\�Ȓl�́Astats �\���̂�
%                   �\�[�X�Ɉˑ����܂��B:
%         anova1:   ��������܂��B�O���[�v���ς��r���܂��B
%         anova2:   'column' (�f�t�H���g) �܂��� 'row' ����
%         anovan:   ��������܂��B��W�c���ӕ��ς��r���܂��B
%         aoctool:  'slope'�A'intercept'�A'pmm' (separate-slopes���f����
%                   �΂��ăf�t�H���g��'slope'�A����ȊO��'intercept'�ł�)
%         kruskalwallis:  ��������܂��B��̃����N�̕��ς��r���܂��B
%         friedman:  ��������܂��B��̃����N�̕��ς��r���܂��B
%
%
% [COMPARISON,MEANS,H] = MULTCOMPARE(...)�́A���肳�ꂽ�ʂƂ����̕W��
% �덷�������ƂȂ������s�� MEANS �ƁA�܂��O���t���܂�figure�̃n���h�� 
% H ���o�͂��܂��B
%
% �O���t���Ɏ�����锽���́A���������̔������d�Ȃ�ꍇ�A�L�Ӎ��ł͂Ȃ��A
% �����̔����������Ȃ��ꍇ�A�v�Z���ꂽ2�̐���l�́A�L�Ӎ��̂���
% ���ɋ߂��ߎ��Ƃ��Čv�Z����܂��B(����́A���ׂĂ̕��ς������W�{�T�C�Y
% �Ɋ�Â��ꍇ�Aanova1 ����̕��ς̑��d��r����ɑ΂��Đ��m�ł�)
% �ǂ̕��ς��L�Ӎ��ł��邩���݂邽�߂ɁA�C�ӂ̐���l���N���b�N���邱�Ƃ�
% �ł��܂��B
%
% 2�̕t���I�� CTYPE �̑I�����\�ł��B'hsd' �I�v�V�����́A"honestly 
% significant differences" ��\���A'tukey-kramer' �I�v�V�����Ɠ����ł��B
% 'lsd' �I�v�V�����́A"�ŏ��L�Ӎ�(least significant difference)" ��\���A
% t-����Ŏg�p���܂��B; ����́AF����̂悤�ɁA���O�ɑS�̓I�Ȍ��肪�����
% ���Ȃ�����A���d��r���ɑ΂��ĕی삳��܂���B
%
% �Q�l : ANOVA1, ANOVA2, ANOVAN, AOCTOOL, FRIEDMAN, KRUSKALWALLIS.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:13:13 $
