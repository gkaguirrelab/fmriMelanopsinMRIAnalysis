function [flatVol volDims] = fmriMelanopsinMRIANalysis_flatten4DVolume(volFile)
for ii = 1:4
    volDims(ii)  = size(volFile.vol, ii);
end
flatVol = reshape(volFile.vol,volDims(1)*volDims(2)*volDims(3),volDims(4));