function unflatVol = fmriMelanopsinMRIANalysis_unflatten4DVolume(flatVol, volDims)
unflatVol = reshape(flatVol, volDims(1), volDims(2), volDims(3), volDims(4));