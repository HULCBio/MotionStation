% QUIT   MATLAB�Z�b�V�����̏I��
% 
% QUIT�́A�X�N���v�g FINISH.M �����݂���ꍇ�͎��s��������ŁAMATLAB
% ���I�����܂��B���[�N�X�y�[�X�̏��́AFINISH.M �� SAVE ���Ăяo���Ȃ�
% ����A�ۑ�����܂���BFINISH.M �����s���ɃG���[���������ꍇ�́A�I����
% �Ƃ̓L�����Z������܂��B
% 
% QUIT FORCE �́A���[�U�ɏI�������Ȃ��悤�Ȍ���� FINISH.M ���������
% ���߂ɗ��p�� �܂��B
% 
% QUIT CANCEL �́A�I�����L�����Z�����邽�߂� FINISH.M ���Ŏg���܂��B
% ����́A�ǂ̈ʒu�ɐݒ肵�Ă��e���͂���܂���B
% 
% ���F
% �I�����L�����Z�������邩�ۂ��������_�C�A���O�{�b�N�X��\�����邽�߂�
% ���[�U�� FINISH.M �ɁA���̃R�[�h��ݒ肵�Ă��������B
% 
% button = questdlg('Ready to quit?', ...
%                           'Exit Dialog','Yes','No','No');
%         switch button
%           case 'Yes',
%             disp('Exiting MATLAB');
%             %Save variables to matlab.mat
%             save 
%           case 'No',
%             quit cancel;
%         end
% 
% ���ӁF
% FINISH.M ����Handle Graphics���g�p����ꍇ�Afigure���������邽�߂ɂ́A
% UIWAIT�AWAITFOR�ADRAWNOW �̂����ꂩ���g�p���Ă��������B


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:53:32 $
%   Built-in function.
