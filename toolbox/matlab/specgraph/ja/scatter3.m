% SCATTER3   3�����U�z�}�v���b�g
%
% SCATTER3(X,Y,Z,S,C) �́A�x�N�g�� X,Y,Z(�����͓����T�C�Y�łȂ����
% �Ȃ�܂���)�Ŏw�肳�ꂽ�ʒu�ɁA�J���[�����O�����~��\�����܂��B�e�}�[�J
% �̑傫���́A�x�N�g�� S �̒l�ɂ����(�|�C���g�P�ʂ̓���)�w�肳��A
% �e�}�[�J�̃J���[�́AC �̒l�Ɋ�Â��܂��BS �́A�X�J��(���̂Ƃ����ׂĂ�
% �}�[�J�͓����T�C�Y�ŕ`�悳��܂�)���AX,Y,Z �Ɠ��������̃x�N�g���ł��B
% 
% C �� X,Y,Z �Ɠ��������̃x�N�g���̂Ƃ��AC �̒l�́A�J�����g�̃J���[�}�b�v��
% �̃J���[�ɐ��`�Ɏʑ�����܂��BC �� LENGTH(X) �s 3 ��̍s��̂Ƃ��A
% C �̒l�́A�}�[�J�̃J���[��RGB�l�Ƃ��Ďw�肵�܂��BC �́A�J���[������
% ������ł��\���܂���B
%
% SCATTER3(X,Y,Z) �́A�f�t�H���g�̃T�C�Y�ƃJ���[�Ń}�[�J��`�悵�܂��B
% SCATTER3(X,Y,Z,S) �́A�}�[�J��P�F�ŕ`�悵�܂��B
% SCATTER3(...,M) �́A'o' �̑���ɁA�}�[�JM���g���܂��B
% SCATTER3(...,'filled') �́A�}�[�J��h��Ԃ��܂��B
%
% SCATTER3(AX,...) �́AGCA�̑����AX��v���b�g���܂��B
%
% H = SCATTER3(...) �́A�쐬����PATCH�I�u�W�F�N�g�̃n���h���ԍ����o��
% ���܂��B
%
% ���ʌ݊���
% SCATTER3('v6',...) �́AMATLAB 6.5����т���ȑO�̃o�[�W�����Ƃ̌݊�����
% ���߁Ascatter�O���[�v�I�u�W�F�N�g�̑����patch�I�u�W�F�N�g���쐬���܂��B
%  
% �P�F�ŁA�P��̃}�[�J�T�C�Y��3�����̎U�z�}�ɂ��ẮAPLOT3 ���g�p����
% ���������B
%
% ���
%      [x,y,z] = sphere(16);
%      X = [x(:)*.5 x(:)*.75 x(:)];
%      Y = [y(:)*.5 y(:)*.75 y(:)];
%      Z = [z(:)*.5 z(:)*.75 z(:)];
%      S = repmat([1 .75 .5]*10,prod(size(x)),1);
%      C = repmat([1 2 3],prod(size(x)),1);
%      scatter3(X(:),Y(:),Z(:),S(:),C(:),'filled'), view(-60,60)
%
% �Q�l�FSCATTER, PLOT3.


%   Copyright 1984-2002 The MathWorks, Inc. 
