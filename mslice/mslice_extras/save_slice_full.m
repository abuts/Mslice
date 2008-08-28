function save_slice_full(s,filename)

% function save_slice(slice,filename)
% function to save the complete slice data in <filename>

if isempty(filename)
    return
end

% === return if cut is empty
if isempty(s),
   disp('Slice is empty. Cut not saved. Return.');
   return
end

% === open <filename> for writing
fid=fopen(filename,'wt');
if fid==-1,
   disp([ 'Error opening file ' filename ]);
   fclose(fid);
   return
end

%!
%! Format of slice file:
%!   first line:
%!     <nx = no. x bins>  <ny = no. y bins>  <x coord of centre of bin(1,1)>  <y coord of same>  <x bin width>  <y bin width>
%!
%!   then for each bin in the order (1,1)...(nx,1), (1,2)...(nx,2),  ... , (1,ny)...(nx,ny):
%!      x(av)   y(av)   I(av)   err(I(av))   npix
%!      det_no(1)      eps_centre(1)     d_eps(1)     x(1)     y(1)     I(1)     err(1)
%!         .                 .              .           .        .        .        .
%!      det_no(npix)   eps_centre(npix)  d_eps(npix)  x(npix)  y(npix)  I(npix)  err(npix)

    nx = s.header_info(1);
    ny = s.header_info(2);
    x0 = s.header_info(3);
    y0 = s.header_info(4);
    dx = s.header_info(5);
    dy = s.header_info(6);
    disp(['Saving slice ( ' num2str(nx) ' x ' num2str(ny) ' point(s) and ' num2str(size(s.xpix,1)) ' pixel(s)) to file : ']);
    disp([filename]);
	drawnow;
    fprintf(fid,'%8d %8d %13.5g %17.5g %17.5g %17.5g \n',s.header_info);
    
    index=[0;cumsum(reshape(s.npix,prod(size(s.npix)),1))];
    for iy=1:ny
        for ix=1:nx
            if (s.npix(iy,ix)==0)
                fprintf(fid,'%17.5g %17.5g %17.5g %17.5g %8d \n',x0+(ix-1)*dx,y0+(iy-1)*dy,...
                            s.intensity(iy,ix),s.error_int(iy,ix),s.npix(iy,ix));
            else
                fprintf(fid,'%17.5g %17.5g %17.5g %17.5g %8d \n',s.xav(iy,ix),s.yav(iy,ix),...
                            s.intensity(iy,ix),s.error_int(iy,ix),s.npix(iy,ix));
                ipix = (ix-1)*ny + iy;
                for k=index(ipix)+1:index(ipix+1)
                    fprintf(fid,'%8d %17.5g %17.5g %17.5g %17.5g %17.5g %17.5g \n',s.detno(k),s.epsbin(k),s.deps,...
                                       s.xpix(k),s.ypix(k),s.pix_int(k),s.pix_err(k));
                end
            end
        end
    end
   	% write x_label, y_label, and title
   	header='efixed                          =';	% typical header
   	len=num2str(length(header)-1);	% length of defining field
   	if ischar(s.x_label),
	   	fprintf(fid,['%-' len 's%2s%-s\n'],'x_label','= ',s.x_label);
   	elseif iscell(s.x_label),
      	for i=1:length(s.x_label),
		   	fprintf(fid,['%-' len 's%2s%-s\n'],'x_label','= ',s.x_label{i});
      	end
   	end
   	if ischar(s.y_label),
	   	fprintf(fid,['%-' len 's%2s%-s\n'],'y_label','= ',s.y_label);
   	elseif iscell(s.y_label),
      	for i=1:length(s.y_label),
		   	fprintf(fid,['%-' len 's%2s%-s\n'],'y_label','= ',s.y_label{i});
      	end
   	end
   	if ischar(s.z_label),
	   	fprintf(fid,['%-' len 's%2s%-s\n'],'z_label','= ',s.z_label);
   	elseif iscell(s.z_label),
      	for i=1:length(s.z_label),
		   	fprintf(fid,['%-' len 's%2s%-s\n'],'z_label','= ',s.z_label{i});
      	end
   	end
   	if ischar(s.title),
	   	fprintf(fid,['%-' len 's%2s%-s\n'],'title','= ',s.title);
   	elseif iscell(s.title),
      	for i=1:length(s.title),
		   	fprintf(fid,['%-' len 's%2s%-s\n'],'title','= ',s.title{i});
      	end
    end
   % save unit length along x and y axes
   fprintf(fid,['%-' len 's%2s%-7.5g\n'],'x_unitlength','= ',s.x_unitlength);
   fprintf(fid,['%-' len 's%2s%-7.5g\n'],'y_unitlength','= ',s.y_unitlength);
   
   fclose(fid);
        
disp('--------------------------------------------------------------');

