% APPEND   ���͂���яo�͂�t�����ALTI���f�����O���[�v��
%
% SYS = APPEND(SYS1,SYS2, ...) �́A���̌����V�X�e�����쐬���܂��B
% 
%              [ SYS1  0       ]
%        SYS = [  0   SYS2     ]
%              [           .   ]
%              [             . ]
%
% APPEND�́ALTI���f�� SYS1, SYS2,... �̓��͂���яo�̓x�N�g����t�����āA
% �g�僂�f�� SYS ���쐬���܂��B
%
% SYS1,SYS2,... ���ALTI���f���̔z��ł���ꍇ�AAPPEND �͓����T�C�Y�� 
% LTI�z�񃂃f�� SYS ���o�͂��܂��B�����ŁA
% 
%   SYS(:,:,k) = APPEND(SYS1(:,:,k),SYS2(:,:,k),...)
% 
% �ł��B
%
% �Q�l : SERIES, PARALLEL, FEEDBACK, LTIMODELS.


%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
