function[IOut,output]=denoiseImageDCT(Image,sigma,K,varargin)
%denoise an image by separsely reprenting each block with the overcomplate
%DCT dictionary and averarging the represented parts.
%sigma: the s.d of the noise(assume to be white Gaussian)
% K: the number of atoms in the representing dictionary
%optional argumeters.
%Output:IOut: a 2-dimensional array in the same size of the input
%image,that contains the cleaned image.
% output a struct that contains that following field: D-the dictionary used
% for denoising
Reduce_DC=1;
[NN1,NN2]=size(Image);
C=1.15;
waitBarOn=1;
maxBlocksToConsider=260000;
slidingDis=1;
bb=8;
for argI=1:2:length(varargin)
    if(strcmp(varargin{argI},'slidingFactor'))
        slidingDis=varargin{argI+1};
    end
    if(strcmp(varargin(arginI),'errorFactor'))
        C=varargin{argI+1};
    end
    if(strcmp(varagin{argI},'maxBlocksToConsider'))
        maxBlocksToConsider=varargin{argI+1};
    end
    if(strcmp(varargin{argI},'blockSize'))
        bb=varargin{argI+1};
    end
    if(strcmp(varargin{argI},'waitBarOn'))
        waitBarOn=varargin{argI+1};
    end
end
errT=C*sigma;
%Create an initial dictionary from the DCT frame
Pn=ceil(sqrt(K));
DCT=zeros(bb,Pn);
for k=0:1:Pn-1
    V=cos([0:1:bb-1]'*k*pi/Pn);
    if k>0
        V=V-mean(V);
    end
    DCT(:,k+1)=V/norm(V);
end;
DCT=kron(DCT,DCT);% returns the Kronecker tensor product of matrices A and B. super big
while(prod(floor((size(Image)-bb)/slidingDis)+1)>maxBlocksToConsider)
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
    Coefs=OMPerr(DCT,blocks(:,j:jumpSize),errT);
    if(Reduce_DC)
        blocks(:,j:jumpSize)=DCT*Coefs+ones(size(blocks,1),1)*vecOfMeans;
    else
        blocks(:,j:jumpSize)=DCT*Coefs;
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
end
if(waitBarOn)
    close(h);
end
IOut=(Image+0.034*sigma*IMout)./(1+0.034*sigma*Weight);
output.D=DCT;



























