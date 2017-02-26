function [blocks,idx]=my_im2col(I,blkSize,slidingDis)
if(slidingDis==1)
    blocks=im2col(I,blkSize,'sliding');%rearranges image blocks into columns.
    idx=[1:size(blocks,2)];
    return
end
idxMat=zeros(size(I)-blkSize+1);
idxMat([[1:slidingDis:end-1],end],[[1:slidingDis:end-1],end]) = 1;%take blocks in distance of 'slidingDix'
% but always take the first and last one(in each row and column)
idx=find(idxMat);
[rows,cols]=ind2sub(size(idxMat),idx);
%returns the matrices I and J containing the equivalent row
%and column subscripts corresponding to each linear index in the matrix IND for a
%matrix of size siz.
blocks=zeros(prod(blkSize),length(idx));
for i=1:length(idx)
    currBlock=I(rows(i):row(i)+blkSize(1)-1,cols(i):cols(i)+blockSize(2)-1);
    blocks(:,i)=currBlock(:);
end

