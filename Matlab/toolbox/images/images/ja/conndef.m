% CONNDEF �@�f�t�H���g�̘A�����z��
% CONN = CONNDEF(NUM_DIMS,TYPE) �́ANUM_DIMS �����ɑ΂��āATYPE �Œ�`
% ���ꂽ�A�����z����o�͂��܂��BTYPE �́A���̒l�̂����ꂩ��I�����邱
% �Ƃ��ł��܂��B
%
%       'minimal'    N �����̏ꍇ�A(N-1)�����T�[�t�F�X�̒��S�v�f�ɐڂ�
%                    �Ă���ߖT�v�f���`
%
%       'maximal'    �C�ӂ̕��@�ŁA���S�v�f�ɐڂ��邷�ׂĂ̋ߖT���܂ނ�
%                    �̂��`�F ONES(REPMAT(3,1,NUM_DIMS)) 
%
% �������� Image Processing Toolbox �̊֐��́ACONNDEF ���g���āA�f�t�H
% ���g�̘A���x�̓��͈������쐬���܂��B
%
%   ���
%   -------
%       conn2 = conndef(2,'min')
%       conn3 = conndef(3,'max')



%   Copyright 1993-2002 The MathWorks, Inc.
