% PANFCN  �́AAxes GUI �� Signal GUI �p�� Pan �֐��ł��A
% �g�p�@�F
% ���̊֐��́A���[�U���ړ��������� axes �̒��̃��C���� buttondownfcn ��
% ���āA�܂��́A���[�U�� axes �������N���b�N�������ꍇ�� windowbuttond-
% ownfcn �Ƃ��邩�̂����ꂩ����ŁA�R�[������܂��B
% 
% ���͂́A�p�����[�^��/�l�̑g�ō\������܂��B
% 
% 'Ax'  �ړ��������� axes �ŁA�f�t�H���g�́Agca �ł��B
% 
% 'Bounds' .xlim �� .ylim �����\���́B�ړ����邱�Ƃ́A�����͈̔͂Ɍ�
% �肳��܂���B�f�t�H���g�́A�͈͂Ȃ��ł��B
% 
% 'DirectFlag' ���C���� axes �̒��Ńh���b�O����ꍇ1 == > �ŁA�p���i(pa-
% ner)���Ńh���b�O����ꍇ0 == > �ł��B�f�t�H���g��1�ł��B
% 
% 'borderAxes'  axes �̋��E���́A��`����Ă��Ȃ��ꍇ�A'Axes'�͈̔͊O��
% ��̃s�N�Z���ɂȂ�܂��B���C���� erasemode �� background �ł���ꍇ�A
% erased �ɂȂ�܂��B
% 
% 'PannerPatch'  pannerpatch �ւ̃n���h�� -  [] �̏ꍇ�A�X�V���܂���B�f
% �t�H���g�́A[] �ł��B
% 
% 'DynamicDrag'  1 == > �̏ꍇ�A�����Ƀ��C�����X�V (�f�t�H���g) 
%                0 == > �p���i�̃p�b�`�݂̂��X�V
% 
% 'Data'  ���̃t�B�[���h�����\���̔z��
%       .h      ���C���Ɋւ���n���h����v�f�Ƃ���x�N�g��
%       .data   ���C���Ɋւ���f�[�^��v�f�Ƃ���s�� (��P��)
%       .xdata  ���̃t�B�[���h�����݂���ꍇ�A.data �t�B�[���h�Ɠ����傫
%               ���ŁA���ׂẴ��C���́A�J�����g�͈̔͂ɕϊ�����܂��B��
%               �݂��Ȃ��ꍇ�A���`�ɕ��z���� xdata �����肳��A�p������
%               �I�Ɉړ�����ԁA���C����  xdata �� ydata �́A�J�����g�� 
%               xlimits �Ԃŕ\������Ă�����̂������X�V���܂��B
% �f�t�H���g�́Aaxes ���̃��C���S�̂�ΏۂƂ��܂��B
% 
% 'Transform'  �́A�֐��̕����� - ydata �f�t�H���g�� '' �ɐݒ肷��O�� 
% feval �ɓK�p���܂��B�f�t�H���g�́A'' �ł��B
% 
% 'Immediate' 1 == > �́A���E Axes �ɂ����ɃX�C�b�` (�f�t�H���g)
%             0 == > �́A�}�E�X���ړ�����Ƃ��̂݁A���E Axes �ɃX�C�b�`
% 'Invisible'  �́A�B����Ă�����̂̃n���h���ԍ���v�f�Ƃ����x�N�g���ŁA
% �I�����ɍăX�g�A����܂��B
% 
% 'UserHand'  �́Auserdata �ɑ΂��Ďg�p����I�u�W�F�N�g�p�̃n���h���ԍ� 
% 'EraseMode' �́A�ړ����Ă���Ԃ̃��C���ɑ΂��Ďg�p����A'xor' �܂��� 
%                 'background' ���g���A�f�t�H���g�́A'background' �ł��B
% 
% 'Pointer'  �́Adrag �̊ԂɎg�p����܂��B�f�t�H���g�́A'closedhand' ��
%                ���B
% 
% 'InterimPointer'  �́AImmediate ==  0 �̏ꍇ�Adrag �̑O�Ɏg�p����܂��B
% �f�t�H���g�́Anothing �ŁA�����ω��Ȃ��ł��B����́Asetptr �ɓn�����
% ������ł��B
% 
% �o�́F
% �͈͂��ύX�����ꍇ�A1���o�͂��A���̏ꍇ�́A0���o�͂��܂��B
% 



%   Copyright 1988-2001 The MathWorks, Inc.
