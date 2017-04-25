function [ figHandle ] = fmriMaxMel_threeViewSurfacePlot( atlasDir, dataFile, colorScaleLow, colorScaleThresh, colorScaleHigh)

surfaceFileName='lh.inflated';
curvatureFileName='lh.curv';
trans=1;

%% Load surface and curvature files
[vert,face] = freesurfer_read_surf(fullfile(atlasDir,'surf',surfaceFileName));
[curv,~] = freesurfer_read_curv(fullfile(atlasDir,'surf',curvatureFileName));

% Tweak the curvature values for proper display scaling.
mycurv = -curv;
ind.sulci = mycurv<0;
ind.gyri = mycurv>0;
ind.medial = mycurv==0;
mycurv(ind.sulci) = .8;
mycurv(ind.gyri) = 0.9;
mycurv(ind.medial) = 0.7;
cmap_curv = repmat(mycurv,1,3);

% put all into a patch structure
brain.vertices = vert;
brain.faces = face;
brain.facevertexcdata = cmap_curv;

%% Load map data file
if ischar(dataFile)
    tmp = load_nifti(dataFile);
    srf = tmp.vol;
    figName=dataFile;
end

if isnumeric(dataFile)
    if length(dataFile)==163842
        srf=dataFile;
    else
        error('Passed surface file is not fsaverage_sym lh');
    end
    figName='unknown';
end

srf(srf<colorScaleThresh) = nan;

% Define the color scale for the overlay
mycolormap = hot(200);
mapres=[colorScaleLow colorScaleHigh 200];
myvec = linspace(mapres(1),mapres(2),size(mycolormap,1));

%% Color vertices
cmap_vals = zeros(size(cmap_curv))+0.5;
alpha_vals = zeros(size(cmap_curv,1),1);

for i = 1:length(srf)
    % Find the closest color value to the srf(i) value
    [~,ind] = min(abs(myvec-srf(i)));
    if isnan(srf(i))
        col4thisvox = [.8 .8 .8]; % set nan to gray
    else
        col4thisvox = mycolormap(ind,:);
    end
    cmap_vals(i,:) = col4thisvox;
end

%% Set transparency
alpha_vals(~isnan(srf)) = trans;
alpha_vals(~colorScaleThresh) = 0;

%% Make figure
figHandle=figure;

%% Plot brain and surface map
smp = brain;
smp.facevertexcdata = cmap_vals;
set(gcf,'name',figName);

subplot(2,2,1); hold on
view_angle = [90,0];
hbrain = patch(brain,'EdgeColor','none','facecolor','interp','FaceAlpha',1);
hmap = patch(smp,'EdgeColor','none','facecolor','interp','FaceAlpha','flat'...
    ,'FaceVertexAlphaData',alpha_vals,'AlphaDataMapping','none');
daspect([1 1 1]);
% Camera settings
cameratoolbar;
camproj perspective; % orthographic; perspective
lighting phong; % flat; gouraud; phong
material dull; % shiny; metal; dull
view(view_angle(1),view_angle(2));
%lightangle(light_angle(1),light_angle(2));
hcamlight = camlight('headlight');
axis tight off;

subplot(2,2,2); hold on
view_angle = [-90,0];
hbrain = patch(brain,'EdgeColor','none','facecolor','interp','FaceAlpha',1);
hmap = patch(smp,'EdgeColor','none','facecolor','interp','FaceAlpha','flat'...
    ,'FaceVertexAlphaData',alpha_vals,'AlphaDataMapping','none');
daspect([1 1 1]);
% Camera settings
cameratoolbar;
camproj perspective; % orthographic; perspective
lighting phong; % flat; gouraud; phong
material dull; % shiny; metal; dull
view(view_angle(1),view_angle(2));
hcamlight = camlight('headlight');
axis tight off;

subplot(2,2,3); hold on
view_angle = [0,-90];
hbrain = patch(brain,'EdgeColor','none','facecolor','interp','FaceAlpha',1);
hmap = patch(smp,'EdgeColor','none','facecolor','interp','FaceAlpha','flat'...
    ,'FaceVertexAlphaData',alpha_vals,'AlphaDataMapping','none');
daspect([1 1 1]);
% Camera settings
cameratoolbar;
camproj perspective; % orthographic; perspective
lighting phong; % flat; gouraud; phong
material dull; % shiny; metal; dull
view(view_angle(1),view_angle(2));
hcamlight = camlight('headlight');
axis tight off;


% Add a "clean" legend
subPlotHandle=subplot(2,2,4); hold on
h_cb=colorbar(subPlotHandle,'west');
ylabel(h_cb, 'chi-square value (16 df)')
caxis([mapres(1) mapres(2)]);
axis tight equal off
colormap(mycolormap)

% Now a legend to mark up
h_cb=colorbar(subPlotHandle,'east');
caxis([mapres(1) mapres(2)]);
axis tight equal off
colormap(mycolormap)
h_axes = axes('position', h_cb.Position, 'ylim', h_cb.Limits, 'color', 'none', 'visible','off');
cbXLim=h_axes.XLim;

% Lines for threshold, and some p-value levels
if colorScaleHigh>100
    line(cbXLim+2, colorScaleThresh*[1 1], 'color', 'white', 'parent', h_axes);
    text(3,colorScaleThresh,'threshold');
    
    line(cbXLim+2, round(vpa(chi2inv(1-1e-5,16)))*[1 1], 'color', 'white', 'parent', h_axes);
    text(3,double(vpa(chi2inv(1-1e-5,16))),'p=1e-5');
    
    line(cbXLim+2, round(vpa(chi2inv(1-1e-10,16)))*[1 1], 'color', 'white', 'parent', h_axes);
    text(3,double(vpa(chi2inv(1-1e-10,16))),'p=1e-10');
    
    line(cbXLim+2, round(vpa(chi2inv(1-1e-15,16)))*[1 1], 'color', 'white', 'parent', h_axes);
    text(3,double(vpa(chi2inv(1-1e-15,16))),'p=1e-15');
    
    text(3,colorScaleHigh,['max=' num2str(max(srf))]);
end

end % function

