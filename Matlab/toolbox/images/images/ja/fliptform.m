% FLIPTFORM   �\���� TFORM �̓��͑��Əo�͑��̔��]
% TFLIP = FLIPTFORM(T) �́A���ɑ��݂���\���� TFORM �̒��̓��͑��Əo��
% ���𔽓]���邱�Ƃɂ��A�V������ԓI�ȕϊ��\��("TFORM �\����")���쐬
% ���܂��B
%
% ���
% -------
%       T = maketform('affine',[.5 0 0; .5 2 0; 0 0 1]);
%       T2 = fliptform(T);
%
% ���̃X�e�[�g�����g�́A�����ł��B
%       x = tformfwd([-3 7],T)
%       x = tforminv([-3 7],T2)
%
% �Q�l�FMAKETFORM, TFORMFWD, TFORMINV.



%   Copyright 1993-2002 The MathWorks, Inc.
