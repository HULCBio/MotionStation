% SWITCH   ���Ɋ�Â�case���ԂŎ��s��؂�ւ��܂��
% 
% SWITCH�X�e�[�g�����g�̈�ʓI�ȏ����́A���̂悤�ɂȂ�܂��B
%
%     SWITCH switch_expr
%       CASE case_expr�A
%         statement�A...�Astatement
%       CASE {case_expr1�Acase_expr2�Acase_expr3,...}
%         statement�A...�Astatement
%      ...
%       OTHERWISE�A
%         statement�A...�Astatement
%     END
%
% switch_expr �� case_expr �ƈ�v����ŏ���CASE�������s����܂��Bcase
% �����Z���z��̂Ƃ�(��L��2�Ԗڂ�case�̂悤��)�́A�Z���z��̗v�f��
% �����ꂩ��switch���ƈ�v����΁Acase_expr����v���܂��Bcase���̂���
% ���switch���ƈ�v���Ȃ���΁A(���݂����)OTHERWISE case�������s
% ����܂��B1��CASE�������s����AEND�̌�̃X�e�[�g�����g���g���č�
% �ю��s����܂��B
%
% switch_expr �́A�X�J���܂��͕�����ł��Bswitch_expr =  = case_expr ��
% �ꍇ�́A�X�J����switch_expr �� case_expr �ƈ�v���܂��B
% strcmp(switch_expr,case_expr) ��1���o�͂���ꍇ�́A�������
% switch_expr �́Acase_expr �ƈ�v���܂��B
%
% ��v���� CASE �Ƃ���CASE, OTHERWISE,END �̂����ꂩ�Ƃ̊Ԃ̃X
% �e�[�g�����g�݂̂����s����܂��BC�ƈقȂ�ASWITCH �X�e�[�g�����g�́A
% BREAK ��K�v�Ƃ��܂���B
% 
% ���
%
% ������ METHOD �ɐݒ肳��Ă�����̂��x�[�X�Ɏ�X�̃R�[�h�Q�����s���܂��B
% 
%
%       method = 'Bilinear';
%
%       switch lower(method)
%         case {'linear','bilinear'}
%           disp('Method is linear')
%         case 'cubic'
%           disp('Method is cubic')
%         case 'nearest'
%           disp('Method is nearest')
%         otherwise
%           disp('Unknown method.')
%       end
%
%       Method is linear
% 
% �Q�l�FCASE, OTHERWISE, IF, WHILE, FOR, END.

%   Copyright 1984-2002 The MathWorks, Inc. 

