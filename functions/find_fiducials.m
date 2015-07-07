% FIND_FIDUCIALS Find coordinates of fiducials in an image.
%
%   fiducials = find_fiducials(
%       images, 
%       fiducial_locations,       
%       templates,
%       template_rotations,
%       search_widths,
%       (results_dir)
%       )
% 
% Input:
%
%   images        
%       {,} Image file paths, in formats that support imread 'PixelRegion')
%   fiducial_locations
%       [,] Locations of fiducials in the images, where left = 1,
%       top-left = 2, top = 3, ... , bottom-left = 8.
%   templates
%       {{}, {}} Template file paths for each location, from largest to
%       smallest.
%   template_rotations
%       [,] K*90 degree clockwise rotations of the templates at each
%       location.
%   search_widths
%       [,] Widths in pixels of the search window for each template search
%       depth (must be as long as the longest cell array in templates).
%   results_dir
%       [''] Output directory path for fiducial images and coordinates.
%   
% Output:
%   
%   fiducials
%       {[8x2],[8x2]} Fiducials for each image as image pixel coordinates 
%       [x y] for each possible fiducial location (1-8). Origin (0,0) is
%       the upper-left corner of the upper-left pixel.
%
% NOTES: The last fiducial template used at each location must have the
% fiducial point at the center of the image.
% 
% TODOS: Modulate template rotation and scale to find best match.
%          
% See also normxcorr2_general

function fiducials = find_fiducials(images, fiducial_locations, templates, template_rotations, search_widths, results_dir)

% Prepare results folder
if nargin > 5
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end
end

% For each image...
fiducials = repmat({nan(8,2)}, 1, length(images));
for i_image = 1:length(images)
  
    % get image info
    [~, filename, ~] = fileparts(images{i_image});
    image_info = imfinfo(images{i_image});
    nx = image_info.Width;
    ny = image_info.Height;

    % search origins (upper left corner, as indices)
    % (left, top-left, top, top-right, right, bottom-right, bottom, bottom-left)
    w = search_widths(1);
    x0 = round((nx-w)/2);
    y0 = round((ny-w)/2);
    I0 = [y0 ; 1 ; 1 ; 1 ; y0; ny-w ; ny-w ; ny-w];
    J0 = [1 ; 1 ; x0 ; nx-w ; nx-w ; nx-w; x0 ; 1];
    
    % For each location...
    for i_location = 1:length(fiducial_locations)
        
        % search origin
        i_fiducial = fiducial_locations(i_location);
        i0 = I0(i_fiducial);
        j0 = J0(i_fiducial);
        
        % For each template...
        for i_template = 1:length(templates{i_location})
            
            % load image region
            % FIXME: Result cropped if PixelRegion extends beyond image
            % (leads to wrong image-wide coordinates)
            w = search_widths(i_template);
            if i_template == 1
                img = imread(images{i_image}, 'PixelRegion', {[i0 i0+w], [j0 j0+w]});
            else
                img = imread(images{i_image}, 'PixelRegion', {[i0-w/2 i0+w/2], [j0-w/2 j0+w/2]});
            end
            if (size(img,3) == 3)
                img = double(rgb2gray(img));
            end
            
            % load template
            base_template = double(imread(templates{i_location}{i_template}));
            template = rot90(base_template, -template_rotations(i_location));

            % cross-correlation
            cc = normxcorr2_general(template, img, length(template(:)));
            
            % find peak
            [~,ind] = max(cc(:));
            [icc,jcc] = ind2sub(size(cc),ind);
            imax = icc - floor(size(template,1)/2);
            jmax = jcc - floor(size(template,2)/2);
            
            % convert back to image-wide coordinates
            if i_template == 1
                j0 = j0 + jmax - 1;
                i0 = i0 + imax - 1;
            else
                j0 = j0 - w/2 + jmax - 1;
                i0 = i0 - w/2 + imax - 1;
            end
            
            % save image of match
            marked_img = insertMarker(img, [jmax imax], 'plus', 'Color', 'green', 'Size', 3);
            [ny, nx] = size(template);
            cropped_img = imcrop(marked_img, [jmax-nx/2 imax-ny/2 nx ny]);
            imwrite(cropped_img, [results_dir '/' filename '_' num2str(i_fiducial) '.jpg']);
        end

        % store as UL coordinates
        % (-0.5 since origin at 0, not 0.5 as in MATLAB)
        fiducials{i_image}(i_fiducial,:) = [j0 i0] - 0.5;
    end
    
    % Show full image with fiducials
    %full_img = imread(image_paths{i_image});
    %figure(); imshow(full_img); hold on
    %plot(fiducials{i_image}(: ,1)+0.5, fiducials{i_image}(:,2)+0.5,'y+','linewidth',4);

    % write fiducial coordinates to file
    if nargin > 5
        dlmwrite([results_dir '/' filename '.tab'], fiducials, '\t');
    end
end