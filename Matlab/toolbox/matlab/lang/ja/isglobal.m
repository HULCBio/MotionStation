%ISGLOBAL �O���[�o���ϐ��̌��o
% ISGLOBAL(A) �́AISGLOBAL ���R�[�������R���e�L�X�g�ŁAA ���O���[�o��
% �ϐ��Ƃ��Đ錾����Ă���΁ATRUE �ł���A�����łȂ��ꍇ�AFALSE �ł��B
%
% ISGLOBAL �͔p�~����Ă���AMATLAB �̏����̃o�[�W�����ł͎g�p����Ȃ��Ȃ�
% �܂��B
%
% ISGLOBAL �́A�����O���[�o���錾�ƂƂ��ɒʏ�g�p����܂��B 
% ����̃A�v���[�`�́A���[�J������уO���[�o���ɐ錾���ꂽ�ϐ��̑g
% ���g�p���邱�Ƃł��B
%
%
%     if condition
%       global x
%     end
%
%     x = some_value
%
%     if isglobal(x)
%       do_something
%     end
%
%
% ��L���g�p�������ɁA�ȉ����g�p���邱�Ƃ��ł��܂��B
%
%
%     global gx
%     if condition
%       gx = some_value
%     else
%       x = some_value
%     end
%
%     if condition
%       do_something
%     end
%
%
% ���̉���􂪂Ȃ��ꍇ�A"isglobal(variable)" �̑���ɂ��̂悤�ɂ��܂��B
%
%     ~isempty(whos('global','variable'))
%
%
% �Q�l GLOBAL, CLEAR, WHO.

%   Copyright 1984-2003 The MathWorks, Inc. 
