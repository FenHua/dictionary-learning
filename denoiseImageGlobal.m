function [IOut,output]=denoiseImageGlobal(Image,sigma,varargin)
% denoise an image by training a dictionary on patches from the noisy
% image, sperately representing the each block with this dictionary and
% averarging the presented parts. 
% The trained dictionary is given in a specific file
% 'globalTrainedDictionary.mat'that must accompany this function
fildNameForGlobalDictionary='globalTrainedDictionary';
Reduce_DC=1;
[NN1,NN2]=size(Image);
waitBarOn=1;
C=1.15;
maxBlocksToConsider=260000;
slidingDis=1;
bb=8;
givenDictionaryFlag=0;
for argI=1:2:length(varargin)
    if(strcmp(varargin{argI},'slidingFactor'))
        slidingDis=vargin{argI+1};
    end
    if(strcmp(varargin{argI},'errorFactor'))
        C=varargin{argI+1};
    end
    if(strcmp(varargin{argI},'maxBlocksToConsider'))
        maxBlocksToConsider=varargin{argI+1};
    end
    if(strcmp(varargin{argI},'givenDictionary'))
        D=varargin{argI+1};
        givenDictionaryFlag=1;
    end
    if(strcmp(varargin{argI},'blockSize'))
        bb=varargin{argI+1};
    end
    if(strcmp(varargin{argI},'waitBarOn'))
        waitBarOn=varargin{argI+1};
    end
end
if(~givenDictionaryFlag)
    eval(['load ',fildNameForGlobalDictionary]);
    D=currDictionary;
end
errT=C*sigma;
while(prod(size(Image)-bb+1)>maxBlocksToConsider)
    slidingDis=slidingDis+1;
end
[blocks,idx]=my_im2col(Image,[bb,bb],slidingDis);
if(waitBarOn)
    counterForWaitBar=size(blocks,2);
    h=waitbar(0,'Denoising In Process...');
end
% go with jumps of 10000
for j=1:10000:size(blocks,2)
    if(waitBarOn)
        waitbar(j/counterForWaitBar);
    end
    jumpSize=min(j+10000-1,size(blocks,2));
    if(Reduce_DC)
        vecOfMeans=mean(blocks(:,j:jumpSize));
        blocks(:,j:jumpSize)=blocks(:,j:jumpSize)-repmat(vecOfMeans,size(blocks,1),1);
    end
    Coefs=OMPerr(D,blocks(:,j:jumpSize),errT);
    if(Reduce_DC)
        blocks(:,j:jumpSize)=D*Coefs+ones(size(blocks,1),1)*vecOfMeans;
    else
        blocks(:,j:jumpSize)=D*Coefs;
    end
end
count=1;
Weight=zeros(NN1,NN2);
IMout=zeros(NN1,NN2);
[rows,cols]=ind2sub(size(Image)-bb+1,idx);
for i=1:length(cols)
    col=cols(i);
    row=rows(i);
    block=reshape(blocks(:,count),[bb,bb]);
    IMout(row:row+bb-1,col:col+bb-1)=IMout(row:row+bb-1,col:col+bb-1)+block;
    Weight(row:row+bb-1,col:col+bb-1)=Weight(row:row+bb-1,col:col+bb-1)+ones(bb);
    count=count+1;
end;
if(waitBarOn)
    close(h);
end
output.D=D;
IOut=(Image+0.0034*sigma*IMout)./(1+0.034*sigma*Weight);
















