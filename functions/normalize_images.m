% NORMALIZE_IMAGES Transform images to a common reference.
%
%   camera = normalize_images(
%       images, 
%       fiducials,       
%       camera,
%       scale,
%       (results_dir)
%       )
% 
% Input:
%
%   images        
%       {,} Image file paths.
%   fiducials
%       {[8x2],[8x2]} Fiducials for each image, as output by
%       find_fiducials.
%   camera
%       {S} Camera structure with fields
%           fmm: Focal length in mm [fx fy]
%           fiducials_mm: Fiducial coordinates in mm [8x2]
%   scale
%       [#] Scale output pixel camera coordinates and image size.
%   results_dir
%       [''] Output directory path for normalized images.
%   
% Output:
%   
%   camera
%       {S} Camera structure with added fields
%           imgsize: Image dimensons in pixels [nx ny]
%           fpx: Focal length in pixels [fx fy]
%           c: Principal point in pixels [cx cy]
%           fiducials_px: Fiducial coordinates in pixels [8x2]
%          
% See also find_fiducials

function camera = normalize_images(images, fiducials, camera, scale, results_dir)

% Prepare results folders
if nargin > 4
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end
end

for i_image = 1:length(images)
    
    % For first image only...
    if i_image == 1
    
        % Retrieve image (px) and camera (mm) fiducial coordinates
        fd_cam_mm = camera.fiducials_mm;
        fd_cam_mm(:,2) = -fd_cam_mm(:,2);
        fd_img = fiducials{i_image};

        % Scale image coordinates
        fd_img = fd_img * scale;

        % Compute appropriate px/mm
        px_mm = pdist(fd_img) ./ pdist(fd_cam_mm);
        %disp(['px/mm = ' num2str(mean(px_mm)) ' ± ' num2str(std(px_mm))]);
        px_mm = mean(px_mm);

        % Express camera fiducials in image coordinates
        fd_cam = fd_cam_mm;
        upper_left = [min(fd_cam(:,1)), min(fd_cam(:,2))];
        fd_cam = fd_cam - repmat(upper_left, size(fd_cam, 1), 1);
        fd_cam = (fd_cam * px_mm);
        c = ([0 0] - upper_left) * px_mm;
        nx = round(max(fd_cam(:,1)));
        ny = round(max(fd_cam(:,2)));
        
        % Add fields to camera
        camera.imgsize = [nx ny];
        camera.c = c;
        camera.fpx = camera.fmm * px_mm;
        camera.fiducials_px = fd_cam;
    end
    
    if nargin > 4
        % Transform image to new coordinates
        img = imread(images{i_image});
        tform = cp2tform(fd_img, fd_cam, 'piecewise linear');
        %X = tforminv(tform, fd_cam);
        %disp(X - fd_img)
        img_transformed = imtransform(img, tform, 'bicubic', 'xdata', [1 nx], 'ydata', [1 ny]);

        % Save transformed image
        [~, filename, ~] = fileparts(images{i_image});
        imwrite(img_transformed, [results_dir '/' filename '.tif'], 'tif');
    end
end