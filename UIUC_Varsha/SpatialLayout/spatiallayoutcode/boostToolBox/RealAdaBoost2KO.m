%   The algorithms implemented by Alexander Vezhnevets aka Vezhnick
%   <a>href="mailto:vezhnick@gmail.com">vezhnick@gmail.com</a>
%
%   Copyright (C) 2005, Vezhnevets Alexander
%   vezhnick@gmail.com
%   
%   This file is part of GML Matlab Toolbox
%   For conditions of distribution and use, see the accompanying License.txt file.
%
%   RealAdaBoost Implements boosting process based on "Real AdaBoost"
%   algorithm
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%    [Learners, Weights, final_hyp] = RealAdaBoost(WeakLrn, Data, Labels,
%    Max_Iter, OldW, OldLrn, final_hyp)
%    ---------------------------------------------------------------------------------
%    Arguments:
%           WeakLrn   - weak learner
%           Data      - training data. Should be DxN matrix, where D is the
%                       dimensionality of data, and N is the number of
%                       training samples.
%           Labels    - training labels. Should be 1xN matrix, where N is
%                       the number of training samples.
%           Max_Iter  - number of iterations
%           OldW      - weights of already built commitee (used for training 
%                       of already built commitee)
%           OldLrn    - learnenrs of already built commitee (used for training 
%                       of already built commitee)
%           final_hyp - output for training data of already built commitee 
%                       (used to speed up training of already built commitee)
%    Return:
%           Learners  - cell array of constructed learners 
%           Weights   - weights of learners
%           final_hyp - output for training data

function [Learners, Weights, final_hyp] = RealAdaBoost2KO(WeakLrn, Data, Labels, Max_Iter, OldW, OldLrn, final_hyp)

%Feature KO
% NumRandomSamples=1;
% for i=1:size(Data,1)
%     fprintf(1,'%d...',i);
%     pos=find(Labels>0);
%     neg=find(Labels<0);
%     for j=1:NumRandomSamples
%         randomsample1=ceil(rand*(length(pos)-1))+1;
%         randomsample2=ceil(rand*(length(neg)-1))+1;;
%         Data(:,end+1)=Data(:,pos(randomsample1));
%         Data(i,end)=Data(i,neg(randomsample2));
%         Labels(end+1)=Labels(pos(randomsample1));
%         distr(end+1)=distr(pos(randomsample1));
%     end
%     for j=1:NumRandomSamples
%         randomsample1=ceil(rand*(length(neg)-1))+1;
%         randomsample2=ceil(rand*(length(pos)-1))+1;;
%         Data(:,end+1)=Data(:,neg(randomsample1));
%         Data(i,end)=Data(i,pos(randomsample2));
%         Labels(end+1)=Labels(neg(randomsample1));
%         distr(end+1)=distr(neg(randomsample1));
%     end
% end

if( nargin == 4)
  Learners = {};
  Weights = [];
  distr = ones(1,size(Data,2));
  L1=find(Labels>0);
  distr(L1)=distr(L1)/(2*length(L1));
  L2=find(Labels<0);
  distr(L2)=distr(L2)/(2*length(L2));
 % distr = ones(1, size(Data,2)) / size(Data,2);  
  final_hyp = zeros(1, size(Data,2));
elseif( nargin > 5)
  Learners = OldLrn;
  Weights = OldW;
  if(nargin < 7)
    final_hyp = Classify(Learners, Weights, Data);
  end
  distr = exp(- (Labels .* final_hyp));  
  distr = distr / sum(distr);  
else
  error('Function takes eather 4 or 6 arguments');
end


        
for It = 1 : Max_Iter
  fprintf(1,'%d...',It);
  %chose best learner
  distr=distr/sum(distr);

  nodes = train2(WeakLrn, Data, Labels, distr);
  curr_tr = nodes;
  %Feature KO
%   for i=1:2
      pos=find(Labels>0);
      neg=find(Labels<0);
      posRatio=length(pos)/length(Labels);
      if(rand>posRatio)
          randomsample1=ceil(rand*(length(pos)-1))+1;
          randomsample2=ceil(rand*(length(neg)-1))+1;

          dim=GetDim(curr_tr);

          Data(:,end+1)=Data(:,pos(randomsample1));
          Data(dim,end)=Data(dim,neg(randomsample2));
          Labels(end+1)=Labels(pos(randomsample1));
          distr(end+1)=distr(pos(randomsample1));
      else

          randomsample1=ceil(rand*(length(neg)-1))+1;
          randomsample2=ceil(rand*(length(pos)-1))+1;

          Data(:,end+1)=Data(:,neg(randomsample1));
          Data(dim,end)=Data(dim,pos(randomsample2));
          Labels(end+1)=Labels(neg(randomsample1));
          distr(end+1)=distr(neg(randomsample1));
      end
%   end
%    randomsample1=ceil(rand*(length(Labels)-1))+1;
%    randomsample2=randomsample1;
%    while(randomsample1==randomsample2)
%        randomsample2=ceil(rand*(length(Labels)-1))+1;
%    end
%    dim=GetDim(curr_tr);
%       Data(:,end+1)=Data(:,randomsample1);
%       Data(dim,end)=Data(dim,randomsample2);
%       Labels(end+1)=Labels(randomsample1);
%       distr(end+1)=distr(randomsample1);
%    
   

  % End Feature KO

  %for i = 1:length(nodes)
    
    step_out = calc_output(curr_tr, Data); 
    step_out = 2*step_out-1;
    ej = (Labels~=step_out);
    epsIt = sum( ej.*distr);
    BetaIt = epsIt/(1-epsIt);
    
    AlphaIt = log(1 / BetaIt);

    Weights(end+1) = AlphaIt;
    
    Learners{end+1} = curr_tr;
  %end
  distr = distr.*((BetaIt*ones(size(ej))).^(ones(size(ej))-ej));
  
  
end
