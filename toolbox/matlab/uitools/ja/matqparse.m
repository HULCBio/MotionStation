% MATQPARSE   MATQDLG�ɑ΂���_�C�A���O�G���g���p�[�T
% 
% [M,ERROR_STR] = MATQPARSE(STR,FLAG) �́AMATQDLG �ɑ΂���miniparser
% �ł��B
% ���Ƃ��΁A'abc de  f ghij' �́A
% 
%                        [abc ]
%                        [de  ]
%                        [f   ]
%                        [ghij]
% 
% �ɂȂ�܂��B�X�y�[�X�A�J���}�A�Z�~�R�����A�����ʂ̂����ꂩ���A�Z�p���[�^
% �Ƃ��Ďg�p���܂��B���������āA'a 10*[b c] d' �̓N���b�V�����܂��B���[�U�́A
% ��L�̑���ɁA'a [10*[b c]] d' ���g��Ȃ���΂Ȃ�܂���B
%
% ���̊֐��͔p�~����Ă���A�����̃o�[�W�����ł͍폜�����ꍇ������܂��B
% 
% �Q�l�F MATQDLG, MATQUEUE.


%  Author(s): A. Potvin, 12-1-92
%  Revised: S. Eddins for use in uitools.
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.7.2.2 $  $Date: 2004/04/28 02:08:27 $

