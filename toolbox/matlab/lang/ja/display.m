% DISPLAY   �z��̕\��
% 
% DISPLAY(X) �́A�X�e�[�g�����g�̖����ɃZ�~�R�������g�p����Ă��Ȃ��Ƃ���
% �I�u�W�F�N�g X �ɑ΂��ČĂяo����܂��B
%
% ���Ƃ��΁A
% 
%   X = inline('sin(x)')
% 
% �́ADISPLAY(X) ���Ăяo���A���
% 
%   X = inline('sin(x)');
% 
% �́A�Ăяo���܂���B
%
% DISPLAY �̓T�^�I�Ȏ����ł́A���̍�Ƃ̂قƂ�ǂ� DISP ���Ăяo������
% �ŁA���̂悤�ɂȂ�܂��BDISP �́A��z���\�����Ȃ����Ƃɒ��ӂ���
% ���������B
%
%      function display(X)
%      if isequal(get(0,'FormatSpacing'),'compact')
%         disp([inputname(1) ' =']);
%         disp(X)
%      else
%         disp(' ')
%         disp([inputname(1) ' =']);
%         disp(' ');
%         disp(X)
%      end
%   
% �Q�l�FINPUTNAME, DISP.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:50 $
%   Built-in function.
