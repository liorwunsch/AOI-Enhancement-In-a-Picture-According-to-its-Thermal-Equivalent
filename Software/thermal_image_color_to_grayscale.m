clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
% workspace;  % Make sure the workspace panel is showing.
% format long g;
% format compact;
fontSize = 15;

%===============================================================================
% Get the name of the image the user wants to use.
baseFileName = 'thermal_image.png'; % Base file name with no folder prepended (yet).
% Get the full filename, with path prepended.
folder = pwd; % Change to whatever folder the image lives in.
fullFileName = fullfile(folder, baseFileName);  % Append base filename to folder to get the full file name.
fprintf('Transforming image "%s" to a thermal image.\n', fullFileName);

%===============================================================================
% Read in a demo image.
originalRGBImage = imread(fullFileName);
% Display the image.
subplot(2, 3, 1);
imshow(originalRGBImage, []);
axis on;
caption = sprintf('Original Pseudocolor Image, %s', baseFileName);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;

grayImage = min(originalRGBImage, [], 3); % Useful for finding image and color map regions of image.

%=========================================================================================================
% Need to crop out the image and the color bar separately.
% First crop out the image.
imageRow1 = 40;
imageRow2 = 298;
imageCol1 = 20;
imageCol2 = 460;
% Crop off the surrounding clutter to get the RGB image.
rgbImage = originalRGBImage(imageRow1 : imageRow2, imageCol1 : imageCol2, :);
% imcrop(originalRGBImage, [20, 40, 441, 259]);

% Next, crop out the colorbar.
colorBarRow1 = 45;
colorBarRow2 = 293;
colorBarCol1 = 533;
colorBarCol2 = 545;
% Crop off the surrounding clutter to get the colorbar.
colorBarImage = originalRGBImage(colorBarRow1 : colorBarRow2, colorBarCol1 : colorBarCol2, :);
b = colorBarImage(:,:,3);

%=========================================================================================================
% Display the pseudocolored RGB image.
subplot(2, 3, 2);
imshow(rgbImage, []);
axis on;
caption = sprintf('Cropped Pseudocolor Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;
hp = impixelinfo();

imwrite(uint8(rgbImage), 'rectangle_thermal.png');

% Display the colorbar image.
subplot(2, 3, 3);
imshow(colorBarImage, []);
axis on;
caption = sprintf('Cropped Colorbar Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;

% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')

%=========================================================================================================
% Get the color map from the color bar image.
storedColorMap = colorBarImage(:,1,:);
% Need to call squeeze to get it from a 3D matrix to a 2-D matrix.
% Also need to divide by 255 since colormap values must be between 0 and 1.
storedColorMap = double(squeeze(storedColorMap)) / 255;
% Need to flip up/down because the low rows are the high temperatures, not the low temperatures.
storedColorMap = flipud(storedColorMap);

% Convert the subject/sample from a pseudocolored RGB image to a grayscale, indexed image.
indexedImage = rgb2ind(rgbImage, storedColorMap);
% Display the indexed image.
subplot(2, 3, 4);
imshow(indexedImage, []);
axis on;
caption = sprintf('Indexed Image (Gray Scale Thermal Image)');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;

%=========================================================================================================
% Now we need to define the temperatures at the end of the colored temperature scale.
% You can read these off of the image, since we can't figure them out without doing OCR on the image.
% Define the temperature at the top end of the scale.
% This will probably be the high temperature.
highTemp = 31.6;
% Define the temperature at the dark end of the scale
% This will probably be the low temperature.
lowTemp = 20.6;

% Scale the indexed gray scale image so that it's actual temperatures in degrees C instead of in gray scale indexes.
thermalImage = lowTemp + (highTemp - lowTemp) * mat2gray(indexedImage);

% Display the thermal image.
subplot(2, 3, 5);
imshow(thermalImage, []);
axis on;
colorbar;
title('Floating Point Thermal (Temperature) Image', 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');

% Let user mouse around and see temperatures on the GUI under the temperature image.
hp = impixelinfo();
hp.Units = 'normalized';
hp.Position = [0.45, 0.03, 0.25, 0.05];

%=========================================================================================================
% Get and display the histogram of the thermal image.
subplot(2, 3, 6);
histogram(thermalImage, 'Normalization', 'probability');
axis on;
grid on;
caption = sprintf('Histogram of Thermal Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Temperature', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Frequency', 'FontSize', fontSize, 'Interpreter', 'None');

fprintf('Done!  Thanks Image Analyst!\n');

imwrite(uint8(cat(3,thermalImage,thermalImage,thermalImage)), 'rectangle_normal.png');
