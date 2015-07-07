% Examples

%% find_fiducials (simple)
% Fiducials on all 4 sides using the same single template.

images = {'images/19880405_01_08.tif'};
fiducial_locations = [1, 3, 5, 7];
templates = repmat({{'templates/template-01.tif'}}, 1, 4);
template_rotations = [0, 0, 0, 0];
search_widths = [500];
results_dir = 'fiducials/';

fiducials = find_fiducials(images, fiducial_locations, templates, template_rotations, search_widths, results_dir);
disp(fiducials{1});

%% find_fiducials (complex)
% Fiducials on all 4 sides and 4 corners using different and multiple
% templates.

images = {'images/19970915_02_07.tif'};
fiducial_locations = 1:8;
templates = repmat({{'templates/template-02a.tif', 'templates/template-02b.tif'}, {'templates/template-03.tif'}}, 1, 4);
template_rotations = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4];
search_widths = [1000, 50];
results_dir = 'fiducials/';

fiducials = find_fiducials(images, fiducial_locations, templates, template_rotations, search_widths, results_dir);
disp(fiducials{1});

%% Full example

% Find fiducials
images = {'images/19970915_02_07.tif'};
fiducial_locations = 1:8;
templates = repmat({{'templates/template-02a.tif', 'templates/template-02b.tif'}, {'templates/template-03.tif'}}, 1, 4);
template_rotations = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4];
search_widths = [1000, 50];
results_dir = 'fiducials/';

fiducials = find_fiducials(images, fiducial_locations, templates, template_rotations, search_widths, results_dir);

% Normalize images
camera.fmm = [153.702, 153.702];
camera.fiducials_mm = ...
    [-112.999	-0.012;
    -103.933	103.933;
    0.005	112.996;
    103.937	103.949;
    113.008	-0.005;
    103.974	-103.952;
    -0.005	-113;
    -103.953	-103.952];
scale = 1;
results_dir = 'images_normalized/';

camera_transformed = normalize_images(images, fiducials, camera, scale, results_dir);

% Generate camera XML
[~, filename, ~] = fileparts(images{1});
xml_path = ['camera_xml/' filename '.xml'];
write_agisoft_camera_xml(camera_transformed, xml_path);