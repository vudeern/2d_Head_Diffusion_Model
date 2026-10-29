% ================== LOAD & PREPROCESS IMAGE ==================
img = imread('eyeModel.png');
imgDouble = double(img);

% Compute brightness
brightness = 0.2989 * imgDouble(:,:,1) + 0.5870 * imgDouble(:,:,2) + 0.1140 * imgDouble(:,:,3);

% Ignore pure black pixels (background)
maskNonBlack = ~(img(:,:,1) == 0 & img(:,:,2) == 0 & img(:,:,3) == 0);
nonBlackBrightness = brightness(maskNonBlack);

% Find threshold for 2% darkest non-black pixels
sortedVals = sort(nonBlackBrightness(:));
secondDarkest = sortedVals(round(numel(sortedVals) * 0.02));
tolerance = 10;

% Create mask for dark region
darkRegion = brightness >= (secondDarkest - tolerance) & brightness <= (secondDarkest + tolerance);

% Cleanup region
darkRegion = logical(darkRegion);
darkRegion = bwareaopen(darkRegion, 500);
darkRegion = imfill(darkRegion, 'holes');
darkRegion = bwareafilt(darkRegion, 1);
darkRegion = imclose(darkRegion, strel('disk', 5));

%  Ensure REGION is BLACK and background WHITE
binaryMatrix = ~darkRegion;   % black region = 0, outside = 1

% ================== FIND CENTER & ELLIPSE ==================
props = regionprops(darkRegion, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Orientation');
x0 = props.Centroid(1);
y0 = props.Centroid(2);
major = props.MajorAxisLength / 2;
minor = props.MinorAxisLength / 2;
theta = deg2rad(-props.Orientation);

% Ellipse boundary
t = linspace(0, 2*pi, 400);
ellipse_x = x0 + major*cos(t)*cos(theta) - minor*sin(t)*sin(theta);
ellipse_y = y0 + major*cos(t)*sin(theta) + minor*sin(t)*cos(theta);

fprintf('Estimated Center (x0, y0) = (%.2f, %.2f)\n', x0, y0);

% ================== PLOT & SAVE: ORIGINAL IMAGE ==================
figure;
imshow(img); hold on;
plot(ellipse_x, ellipse_y, 'r', 'LineWidth', 2);
plot(x0, y0, 'r+', 'MarkerSize', 12, 'LineWidth', 2);
title('Original Image with Ellipse & Center');

% Save this image directly
frame = getframe(gca);
imwrite(frame.cdata, 'eyeModel_result.png');

% ================== PLOT & SAVE: BINARY MASK ==================
figure;
imshow(binaryMatrix); hold on;
plot(ellipse_x, ellipse_y, 'r', 'LineWidth', 2);
plot(x0, y0, 'r+', 'MarkerSize', 12, 'LineWidth', 2);
title('Binary Mask (Black Region) with Ellipse & Center');

%  Save this image too
frame2 = getframe(gca);
imwrite(frame2.cdata, 'eyeModel_mask_result.png');

% ================== SAVE DATA IF NEEDED ==================
save('binaryMatrix.mat', 'binaryMatrix');
