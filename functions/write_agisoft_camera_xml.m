% WRITE_AGISOFT_CAMERA_XML Write camera XML for Agisoft Photoscan.
%
%   write_agisoft_camera_xml(
%       camera,
%       xml_path
%       )
% 
% Input:
%
%   camera
%       {S} Camera structure with fields imgsize, fpx, c. See
%       normalize_images.
%   xml_path
%       [''] Path to xml file.
%          
% See also normalize_images

function [] = write_agisoft_camera_xml(camera, xml_path)

% Initialize XML
docNode = com.mathworks.xml.XMLUtils.createDocument('calibration');
calibration = docNode.getDocumentElement;
item = docNode.createElement('projection');
item.appendChild(docNode.createTextNode('frame'));
calibration.appendChild(item);

% Dimensions
item = docNode.createElement('width');
item.appendChild(docNode.createTextNode(num2str(camera.imgsize(1))));
calibration.appendChild(item);
item = docNode.createElement('height');
item.appendChild(docNode.createTextNode(num2str(camera.imgsize(2))));
calibration.appendChild(item);

% Focal length
item = docNode.createElement('fx');
item.appendChild(docNode.createTextNode(num2str(camera.fpx(1))));
calibration.appendChild(item);
item = docNode.createElement('fy');
item.appendChild(docNode.createTextNode(num2str(camera.fpx(2))));
calibration.appendChild(item);

% Principal point
item = docNode.createElement('cx');
item.appendChild(docNode.createTextNode(num2str(camera.c(1))));
calibration.appendChild(item);
item = docNode.createElement('cy');
item.appendChild(docNode.createTextNode(num2str(camera.c(2))));
calibration.appendChild(item);

% Write XML
xmlwrite(xml_path, docNode);