function [figHandle]=fmriMaxMel_makeCRFResultFigure( deduFitData, subjectNameFunc)

figHandle=figure();
lmsCRFCells=deduFitData{1};
melCRFCells=deduFitData{2};
splatCRFCells=deduFitData{3};

contrastLabels={'25','50','100','200','400'};
splatterLabels={[char(188) 'x'], [char(189) 'x'],'1x','2x'};

nSubjects=4;

for ss=1:nSubjects
    subplotHandle=subplot(1,nSubjects,ss);
    
    % Plot the LMS CRF
    meansLMS=cellfun(@(x) x.meanAmplitude, lmsCRFCells);
    semsLMS=cellfun(@(x) x.semAmplitude, lmsCRFCells);
        sems=semsLMS(ss,:);
        means=meansLMS(ss,:);
    fmriMaxMel_PlotCRF( subplotHandle, [1, 2, 3, 4, 5], means, sems, ...
        'xTickLabels',contrastLabels,...
        'xlim',[0 7],...
        'lineColor',[.25 .25 .25],...
        'markerColor',[0 0 0],...
        'errorColor',[.5 .5 .5],...
        'plotTitle',subjectNameFunc(ss));
    hold on
    
    % Plot the Mel CRF
    meansMel=cellfun(@(x) x.meanAmplitude, melCRFCells);
    semsMel=cellfun(@(x) x.semAmplitude, melCRFCells);
        means=meansMel(ss,:);
        sems=semsMel(ss,:);
    fmriMaxMel_PlotCRF( subplotHandle, [1, 2, 3, 4, 5], means, sems, ...
        'xTickLabels',contrastLabels,...
        'xlim',[0 7],...
        'lineColor',[.25 .25 1],...
        'markerColor',[0 0 1],...
        'errorColor',[.5 .5 1],...
        'plotTitle',subjectNameFunc(ss));
    
    % Plot the splatter CRF
    meansSplat=cellfun(@(x) x.meanAmplitude, splatCRFCells);
    semsSplat=cellfun(@(x) x.semAmplitude, splatCRFCells);
        means=meansSplat(ss,:);
        sems=semsSplat(ss,:);
    fmriMaxMel_PlotCRF( subplotHandle, [3, 4, 5, 6], means, sems, ...
        'xTickLabels',splatterLabels,...
        'xlim',[0 7],...
        'lineColor',[1 .25 .25],...
        'markerColor',[1 0 0],...
        'errorColor',[1 .5 .5],...
        'plotTitle',subjectNameFunc(ss),...
        'xLabel','splatter',...
        'secondAxis',true);
    
    % Calculate the multiplier required to shift the splatter CRF to best
    % fit the melanopsin CRF
    interpMel=interp1(-3.4657:0.6931:-0.6931,meansMel(ss,:),-3.4657:0.6931/100:-0.6931);
    interpMel=[interpMel nan(1,100)];
    interpSplat=interp1(-2.0794:0.6931:0,meansSplat(ss,:),-2.0794:0.6931/100:0);
    interpSplat=[nan(1,100) nan(1,100) interpSplat];
    interpX=-3.4657:0.6931/100:0;
    for shifter=1:600
        r(shifter)=sqrt(nansum((interpMel-circshift(interpSplat,-1*shifter)).^2))/sum(~isnan((interpMel-circshift(interpSplat,-1*shifter))));
    end
    idx=find(r==min(r));
    splatShift=1/exp(interpX(end-idx));
    title(subplotHandle,[subjectNameFunc(ss) ' splat x' num2str(splatShift,'%.3g')],'Interpreter', 'none');

end % subjects


end

