%ACCUMARRAY �A�L���~�����[�V�����ɂ��z����\�����܂�
%
% A = ACCUMARRAY(IND,VAL) �́AIND �̑Ή�����s���C���f�b�N�X�Ƃ���
% �g�p���āAVAL�̗v�f����z����쐬���܂��BIND ��NDIM ������s��
% �̏ꍇ�AA �́ANDIM �����ƃT�C�Y MAX(IND) �����z��ɂȂ�܂��B
% IND ����x�N�g���̏ꍇ�AA �́A��x�N�g���ɂȂ�܂��BVAL ���X�p�[�X
% �̏ꍇ�AA �̓X�p�[�X�ŁA2D �s��Ɍ����܂��BVAL �� full�̏ꍇ�A
% A �� full�ł��BVAL �́AIND�̍s���Ɠ��������̃x�N�g���ł���K�v��
% ����܂��BVAL ���X�J���[�̏ꍇ�AIND �̂��ׂẴC���f�b�N�X�ɑ΂��āA
% �����l���g�p����܂��BIND �̌J��Ԃ��C���f�b�N�X�ł�VAL�̗v�f�́A
% �A�L���~�����[�g����A���Z����܂��B�w�肳��Ă��Ȃ��C���f�b�N�X
% �ł̒l�́A0�ł��B
%    
% A = ACCUMARRAY(IND,VAL,SZ) �́A�T�C�Y SZ �̔z����쐬���܂��B
% SZ �́AIND �Ɠ������̗�����s�x�N�g���ł���ASZ �̗v�f�́A
% MAX(IND)�̑Ή�����v�f�����傫���Ȃ���΂Ȃ�܂���B
%
% A = ACCUMARRAY(IND,VAL,SZ,FUN) �́A�֐� FUN ���g�p���āA�J��Ԃ�
% �C���f�b�N�X�ł̒l��~�ς��܂��BFUN �́A�֐��n���h���ɂ��w��
% ����܂��BFUN �́A�x�N�g�����󂯎��A�X�J���[��Ԃ��K�v������
% �܂��B���Ƃ��΁A�f�t�H���g�� FUN=@SUM �ł��B�����ŁAS=SUM(X) �́A
% �׃N�g������ X ���󂯎��A�X�J���[�o�� S ��Ԃ��܂��B
%
% A = ACCUMARRAY(IND,VAL,SZ,FUN,FILLVALUE) �́A�l FILLVALUE ��
% �g�p���āA�w�肵�Ă��Ȃ��C���f�b�N�X�ł̒l���L�q���܂��B
%    
% ���: 5x5 �s��̍쐬:
%    ind = [1 2 5 5;1 2 5 5]';
%    dat = [10.1 10.2 10.3 10.4]';
%    A  = accumarray(ind, dat);
%    A1 = accumarray(ind, dat, [5,5], @prod);
%    A2 = accumarray(ind, dat, [5,5], @max, -inf);
%            
% �Q�l FULL, SPARSE, SUM.

%   Copyright 1984-2003 The MathWorks, Inc.
