function disp_spe(data,img_range,map,linearlog)
% function disp_spe(data,vx_min,vx_max,vy_min,vy_max,i_min,i_max,shad,map);
% puts intenity as colour on the surface of trajectories described by an array of detectors
% includes actual size of pixel bins and can be used to identify masked detectors
% axis [vx_min vx_max vy_min vy_max], default [min(vx) max(vx) min(vy) max(vy)]
% with a colour intensity axis in the range [i_min i_max]
% shading {flat}|{faceted}|{interp}
% map = array(m,3) optional RGB colour map, default = jet
% linearlog {'linear'}|{'log'} = colour scale type
% Radu Coldea 24-September-1999
% to add more postscript printers to the list under 'ColorPrint' menu go to line 37

%=== if 'disp_spe' figure does not exist, create
fig=findobj('Tag','disp_spe');
if isempty(fig),
    colordef none;	% black background
    % === create a new figure with 'Tag' property 'disp_spe'
    if verLessThan('matlab','8.4')
        fig=figure('Tag','disp_spe','PaperPositionMode','auto','Name','MSlice : Display','Renderer','zbuffer');
    else
        fig=figure('Tag','disp_spe','PaperPositionMode','auto','Name','MSlice : Display');
    end
    pos=get(gcf,'Position');
    set(fig,'Position',[pos(1) pos(2)-0.1*pos(4) pos(3) 1.1*pos(4)]);
    % === find any old figures and set current figure size to match the dimensions of the
    % === last old figure of the same type
    oldfig=findobj('Tag','old_disp_spe');
    if ~isempty(oldfig),
        set(fig,'Position',get(oldfig(length(oldfig)),'Position'));
    end
else
    figure(fig);
    if ~ishold
        clf;
    end
end

% === create menu options for ColourHardcopy, Keep and Make Current if not there already
h=findobj(fig,'Type','uimenu','Tag','Color_Print');
if isempty(h),
    % === create menu option to be able to do colour hardcopy printouts
    h=uimenu(fig,'Label','ColourPrint','Tag','Color_Print','Enable','on');
    uimenu(h,'Label','Phaser560','Callback','ms_printc('' \\NDAIRETON\Phaser560:'');');
    uimenu(h,'Label','Phaser0','Callback','ms_printc('' \\NDAIRETON\Phaser0:'');');
    uimenu(h,'Label','DACColour','Callback','ms_printc('' \\NDAIRETON\DACColour:'');');
    uimenu(h,'Label','CRISPColour','Callback','ms_printc('' \\NDAIRETON\CRISPColour:'');');
    uimenu(h,'Label','MAPSColour','Callback','ms_printc('' \\NDAIRETON\MAPSColour:'');');
    %=== TO ADD ANOTHER PRINTER IN THIS LIST INSERT ANOTHER LINE AS ABOVE AND
    %=== EDIT NAME (LABEL) 'Phaser0' AND PATH '\\NDAIRETON\Phaser0:'
    uimenu(h,'Label','default printer','Callback','ms_printc;');
    % === create menu option to be able to keep figure
    h=uimenu(fig,'Label','Keep','Tag','keep','Enable','on');
    uimenu(h,'Label','Keep figure','Callback','keep(gcf);');
    % === create menu option to be able to make old display figures current
    h=uimenu(fig,'Label','Make Current','Tag','make_cur','Enable','off');
    uimenu(h,'Label','Make Figure Current','Callback','make_cur(gcf);');
end

% ==== establish plot limits along the u1 and u2 axes
if isempty(img_range.vx_min)||~isnumeric(img_range.vx_min),
    img_range.vx_min=min([min(data.vb(:,:,1)) min(data.vb(:,:,3))]);
    ms_setvalue('disp_vx_min',img_range.vx_min,'highlight');
end
if isempty(img_range.vx_max)||~isnumeric(img_range.vx_max),
    img_range.vx_max=max([max(data.vb(:,:,1)) max(data.vb(:,:,3))]);
    ms_setvalue('disp_vx_max',img_range.vx_max,'highlight');
end
if isempty(img_range.vy_min)||~isnumeric(img_range.vy_min),
    img_range.vy_min=min([min(data.vb(:,:,2)) min(data.vb(:,:,4))]);
    ms_setvalue('disp_vy_min',img_range.vy_min,'highlight');
end
if isempty(img_range.vy_max)||~isnumeric(img_range.vy_max),
    img_range.vy_max=max([max(data.vb(:,:,2)) max(data.vb(:,:,4))]);
    ms_setvalue('disp_vy_max',img_range.vy_max,'highlight');
end


% ==== establish shading option
if ~ischar(img_range.shad)||~(strcmp(deblank(img_range.shad),'faceted')||...
        strcmp(deblank(img_range.shad),'flat')||strcmp(deblank(img_range.shad),'interp')),
    img_range.shad='flat';
    disp('Default "flat" shading option chosen.')
end

% ==== if powder rebin mode, identify the values for powder rebin.
if data.analmode==4
    [img_range.dx_step_min,img_range.dy_step_min]=find_min_delta(img_range,data.vb,data.u);
    if isempty(img_range.dx_step)||~isnumeric(img_range.dx_step)
        img_range.dx_step = img_range.dx_step_min;
        ms_setvalue('disp_dx_step',img_range.dx_step,'highlight');
    end
    if isempty(img_range.dy_step)||~isnumeric(img_range.dy_step)
        img_range.dy_step = img_range.dy_step_min;
        ms_setvalue('disp_dy_step',img_range.dy_step,'highlight');
    end
    [X,Y,Z] = mslice_rebin2D(data,img_range);
    find_min_max_intensity(Z);
else
    find_min_max_intensity(data.S);
    % === from the trajectories of the bin boundaries construct the X and Y grids for the plot
    % === and do the trick with padding an extra row and column on Z to use pcolor
    [ndet,ne]=size(data.S);
    X=NaN*ones(2*ndet,ne+1);
    Y=X;
    Z=X;
    i=(1:ndet)';
    X(2*i-1,:)=data.vb(i,:,1);	% vx values of the boundary on the "left"
    X(2*i,:)  =data.vb(i,:,3);	% vx values of the boundary on the "right"
    Y(2*i-1,:)=data.vb(i,:,2);
    Y(2*i,:)  =data.vb(i,:,4);
    Z(2*i-1,1:ne)=data.S;
end

hplot=pcolor(X,Y,Z);
axis([img_range.vx_min img_range.vx_max img_range.vy_min img_range.vy_max]);
caxis([img_range.i_min img_range.i_max]);
shading(img_range.shad);

% ==== choose colormap and plot colorbar
if exist('map','var')&&isnumeric(map)&&(size(map,2)==3),
    colormap(map);
else
    colormap jet;
end

% === set aspect ratio 1:1 if units along x and y are the same and are �^{-1}
if (~isempty(strfind(data.axis_unitlabel(1,:),'�^{-1}')))&& ...
        (~isempty(strfind(data.axis_unitlabel(2,:),'�^{-1}')))
    figure(fig);
    set(gca,'DataAspectRatioMode','manual');
    a=get(gca,'DataAspectRatio');
    set(gca,'DataAspectRatio',[1./data.axis_unitlength([1;2])' a(3)]);
else
    a=get(gca,'DataAspectRatio');
    set(gca,'DataAspectRatioMode','manual');
    set(gca,'DataAspectRatio',[a(1) 1.15*a(2) a(3)]);
end

% === adjust colorbar height
h=colorbar;
h_colourbar=h;
set(h,'Tag','Colorbar');
aspect=get(gca,'DataAspectRatio');
YLim=get(gca,'Ylim');
XLim=get(gca,'XLim');
pos =get(gca,'Position');
x=1/aspect(1)*(XLim(2)-XLim(1));
y=1/aspect(2)*(YLim(2)-YLim(1));
scx=pos(3)/x;
scy=pos(4)/y;
if scx<scy && verLessThan('matlab','8.4')
    height=scx*y;
    pos=get(h,'Position');
    set(h,'PlotBoxAspectRatio',[0.975*pos(3) height 1]);
end

h=h_colourbar;
% === establish linear or log colour scale
if exist('linearlog','var')&&ischar(linearlog)&&strcmp(linearlog(~isspace(linearlog)),'log'),
    set(h,'YScale','log');
    index=(Z==0);
    Z(index)=NaN;
    set(hplot,'Cdata',log10(Z));
    caxis([log10(img_range.i_min) log10(img_range.i_max)]);
else
    % === use linear scale and enable colour sliders
    % === put sliders for adjusting colour axis limits
    pos_h=get(h,'Position');
    range=abs(img_range.i_max-img_range.i_min);
    hh=uicontrol(fig,'Style','slider',...
        'Units',get(h,'Units'),'Position',[pos_h(1) pos_h(2) pos_h(3)*1.5 pos_h(4)/20],...
        'Min',img_range.i_min-range/2,'Max',img_range.i_max-range*0.1,...
        'SliderStep',[0.01/1.4*2 0.10/1.4],'Value',img_range.i_min,...
        'Tag','color_slider_min','Callback','color_slider_ms(gcf,''slider'')');
    % the SliderStep is adjusted such that in real terms it is [0.02 0.10] of the displayed intensity range
    hh_value=uicontrol(fig,'Style','edit',...
        'Units',get(h,'Units'),'Position',get(hh,'Position')+pos_h(3)*1.5*[1 0 0 0],...
        'String',num2str(get(hh,'Value')),'Tag','color_slider_min_value','Callback','color_slider_ms(gcf,''min'')');
    hh=uicontrol(fig,'Style','slider',...
        'Units',get(h,'Units'),'Position',[pos_h(1) pos_h(2)+pos_h(4)-pos_h(4)/20 pos_h(3)*1.5 pos_h(4)/20],...
        'Min',img_range.i_min+range*0.1,'Max',img_range.i_max+range/2,...
        'SliderStep',[0.01/1.4*2 0.10/1.4],'Value',img_range.i_max,...
        'Tag','color_slider_max','Callback','color_slider_ms(gcf,''slider'')');
    hh_value=uicontrol(fig,'Style','edit',...
        'Units',get(h,'Units'),'Position',get(hh,'Position')+pos_h(3)*1.5*[1 0 0 0],...
        'String',num2str(get(hh,'Value')),'Tag','color_slider_max_value','Callback','color_slider_ms(gcf,''max'')');
end

% ==== construct plot title and axis labels
form='%7.5g';	% number format
titlestr1=[avoidtex(data.filename) ', ' data.title_label];
if data.emode==1,	% direct geometry Ei fixed
    titlestr1=[titlestr1 ', Ei=' num2str(data.efixed,form) ' meV'];
elseif data.emode==2,	% indirect geometry Ef fixed
    titlestr1=[titlestr1 ', Ef=' num2str(data.efixed,form) ' meV'];
else
    fprintf('Could not identify spectrometer type (only direct/indirect geometry allowed), emode=%g',data.emode);
    titlestr1=[titlestr1 ', E=' num2str(data.efixed,form) ' meV'];
end
% if sample is single crystal and uv orientation and psi_samp are defined, include in title
if isfield(data,'uv')&&~isempty(data.uv)&&isnumeric(data.uv)&&(all(size(data.uv)==[2 3]))&&...
        isfield(data,'psi_samp')&&~isempty(data.psi_samp)&&isnumeric(data.psi_samp)&&...
        (numel(data.psi_samp)==1)
    titlestr2=sprintf('{\\bfu}=[%g %g %g], {\\bfv}=[%g %g %g], Psi=({\\bfu},{\\bfki})=%g',...
        data.uv(1,:),data.uv(2,:),data.psi_samp*180/pi);
else
    titlestr2=[];
end
titlestr3=[num2str(img_range.vx_min,form) '<' deblank(data.axis_label(1,:)) '<' num2str(img_range.vx_max,form) ];
titlestr3=[titlestr3 ',  ' num2str(img_range.vy_min,form) '<' deblank(data.axis_label(2,:)) '<' num2str(img_range.vy_max,form)];
if ~isempty(titlestr2),
    h=title({titlestr1, titlestr2, titlestr3});
else
    h=title({titlestr1, titlestr3});
end
YLim=get(gca,'YLim');
pos=get(h,'Position');
set(h,'Position',[pos(1) YLim(2) pos(3)]);
%
hsamp=findobj('Tag','ms_sample');
if ~isempty(hsamp),
    sample=get(hsamp,'Value');
    if sample==1,
        analmode=get(findobj('Tag','ms_analysis_mode'),'Value');
    end
    if (sample==1)&&(analmode==1),
        % single crystal axes
        labelx=[combil(deblank(data.axis_label(1,:)),data.u(1,:)) ' ' deblank(data.axis_unitlabel(1,:))];
        labely=[combil(deblank(data.axis_label(2,:)),data.u(2,:)) ' ' deblank(data.axis_unitlabel(2,:))];
    else	% powder axes
        labelx=deblank(data.axis_unitlabel(1,:));
        labely=deblank(data.axis_unitlabel(2,:));
    end
else
    labelx=[];
    labely=[];
end
xlabel(labelx);
ylabel(labely);
%--------------------------------------------------------------------
    function find_min_max_intensity(S)
        % ==== establish intensity limits for the colorbar
        if ~(isempty(img_range.i_min)||~isnumeric(img_range.i_min))
            if img_range.i_min>=max(S(:)),
                fprintf('Given intensity range min=%g not suitable for graph.',img_range.i_min);
                img_range.i_min=min(S(:));
                fprintf('Plotting with default intensity range min=%g.',img_range.i_min);
                ms_setvalue('disp_i_min',img_range.i_min,'highlight');
            end
        else
            img_range.i_min=min(S(:));
            ms_setvalue('disp_i_min',img_range.i_min,'highlight');
        end
        if ~(isempty(img_range.i_max)||~isnumeric(img_range.i_max)),
            if img_range.i_max<=min(S(:)),
                fprintf('Given intensity range max=%g not suitable for graph.',img_range.i_max);
                img_range.i_max=max(S(:));
                fprintf('Plotting with default intensity range max=%g.',img_range.i_max);
                ms_setvalue('disp_i_max',img_range.i_max,'highlight');
            end
        else
            img_range.i_max=max(S(:));
            ms_setvalue('disp_i_max',img_range.i_max,'highlight');
        end
        if img_range.i_max<img_range.i_min
            temp=max(img_range.i_max,img_range.i_min);
            img_range.i_min=min(img_range.i_max,img_range.i_min);
            img_range.i_max=temp;
            ms_setvalue('disp_i_min',img_range.i_min,'highlight');
            ms_setvalue('disp_i_max',img_range.i_max,'highlight');
            disp('Swapped axes limits.');
        end
        
    end
end