% function [out1,out2,out3,...] = vveval(name,in1,in2,in3,...)
%
% MATLAB��FEVAL�Ɠ��l�ɋ@�\���܂����AVARYING�s���CONSTANT/SYSTEM�s���
% �΂��Ă��@�\���܂��BNAME�́AMATLAB�֐���(���[�U���쐬�A�܂���MATLAB��
% �񋟂������)���܂ރL�����N�^������ł��B
%
%	in1, in2, ... in_last���A���ׂ�CONSTANT�܂���SYSTEM�s��̏ꍇ�A
%       VVEVAL�́AFEVAL���g���āA�ϐ�NAME�Ŏw�肵���֐����Ăяo���܂��B
%
%       in1, in2, ... in_n�̂����ꂩ��VARYING�s��A�܂�Ain_K�̏ꍇ�A
%       VVEVAL�͂��ׂĂ�VARYING�s��̃f�[�^�������ł��邱�Ƃ��`�F�b�N
%       ���A���̕��@�Ń��J�[�V�u�Ɏ��g���Ăяo�����Ƃɂ���āA���[�v
%       �����s���܂��B
%
%   out1 = [];
%
%   outm = [];
%   for i=1:length(getiv(in_K))
%      [t1,t2,..,tm] = vveval(xtracti(in1,i),xtracti(in2,i),...
%        ,xtracti(in_n,i);
%     out1 = [out1;t1];
%     out2 = [out2;t2];
%     outm = [outm;tm];
%   end
%   out1 = vpck(out1,ivvalue);
%   out2 = vpck(out2,ivvalue);
%   outm = vpck(outm,ivvalue);
%
% �Q�l: EVAL, FEVAL, SWAPIV, VEVAL, MVEVAL.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
