function ThermalNormalFusion()
%%
close all; clear; clc;
de = 0.8; % between 0 and 1
method_type = 1;

%% image preprocessing
[normal_rgb, thermal_rgb] = m_image_preprocessing();

%% image analysis
[normal_ycbcr, normal_luminance, thermal_luminance] = m_image_analysis(normal_rgb, thermal_rgb);

%% luminance manipulation
[new_luminance, new_ycbcr] = m_luminance_manipulation(de, method_type, normal_luminance, thermal_luminance, normal_ycbcr);

%% normal image enhancement
new_rgb = ycbcr2rgb(new_ycbcr);

fig = figure;
subplot(221), imshow(normal_ycbcr), title('YCbCr');
subplot(223), imshow(normal_rgb), title('RGB');
subplot(222), imshow(new_ycbcr), title('YCbCr');
subplot(224), imshow(new_rgb), title('RGB');
saveas(fig, 'new_rgb.png');

%% histogram stretching - luminance
[new_stretched_rgb] = m_histogram_stretching(de, method_type, normal_luminance, thermal_luminance, new_luminance, normal_ycbcr);

fig = figure;
subplot(221), imshow(normal_rgb), title('Normal');
subplot(222), imshow(thermal_rgb), title('Thermal');
subplot(223), imshow(new_rgb), title('Enhanced');
subplot(224), imshow(new_stretched_rgb), title('Enhanced Stretched');
saveas(fig, 'result.png');

end

%%
function [normal_rgb, thermal_rgb] = m_image_preprocessing()
%%
try
    normal_rgb = imread('normal.png');
    thermal_rgb = imread('thermal.png');
catch
    normal_rgb = imread('normal.jpg');
    thermal_rgb = imread('thermal.jpg');
end
% padding uneven image
pad_val = size(normal_rgb, 1) - size(thermal_rgb, 1);
if pad_val < 0
    normal_rgb = padarray(normal_rgb,[-1*pad_val 0 0],0,'pre');
end
if pad_val > 0
    thermal_rgb = padarray(thermal_rgb,[pad_val 0 0],0,'pre');
end
pad_val = size(normal_rgb, 2) - size(thermal_rgb, 2);
if pad_val < 0
    normal_rgb = padarray(normal_rgb,[0 -1*pad_val 0],0,'pre');
end
if pad_val > 0
    thermal_rgb = padarray(thermal_rgb,[0 pad_val 0],0,'pre');
end

end

%%
function [normal_ycbcr, normal_luminance, thermal_luminance] = m_image_analysis(normal_rgb, thermal_rgb)
%%
normal_ycbcr = rgb2ycbcr(normal_rgb);
thermal_ycbcr = rgb2ycbcr(thermal_rgb);

fig = figure;
subplot(221), imshow(normal_rgb), title('RGB');
subplot(223), imshow(normal_ycbcr), title('YCbCr');
subplot(222), imshow(thermal_rgb), title('RGB');
subplot(224), imshow(thermal_ycbcr), title('YCbCr');
saveas(fig, 'ycbcr.png');

normal_luminance = squeeze(normal_ycbcr(:,:,1));
thermal_luminance = squeeze(thermal_ycbcr(:,:,1));
thermal_luminance(thermal_luminance < 150) = 0;

fig = figure;
subplot(221), imshow(normal_ycbcr), title('YCbCr');
subplot(223), imshow(normal_luminance), title('Y');
subplot(222), imshow(thermal_ycbcr), title('YCbCr');
subplot(224), imshow(thermal_luminance), title('Y after Thresholding');
saveas(fig, 'y.png');

end

%%
function [new_luminance, new_ycbcr] = m_luminance_manipulation(de, method_type, normal_luminance, thermal_luminance, normal_ycbcr)
%%
if method_type == 0
    new_luminance = normal_luminance + de .* thermal_luminance;
else
    new_luminance = uint8(double(normal_luminance) + double(thermal_luminance) .^ de);
%     new_luminance = double(normal_luminance) ./ 255 + double(thermal_luminance ./ 255) .^ de;
%     new_luminance = uint8(new_luminance .* 255);
end

fig = figure;
subplot(131), imshow(normal_luminance), title('Normal Y');
subplot(132), imshow(thermal_luminance), title('Thermal Y');
subplot(133), imshow(new_luminance), title('Enhanced Y');
saveas(fig, 'new_y.png');

new_ycbcr = normal_ycbcr;
new_ycbcr(:,:,1) = new_luminance;

fig = figure;
subplot(221), imshow(normal_luminance), title('Y');
subplot(223), imshow(normal_ycbcr), title('YCbCr');
subplot(222), imshow(new_luminance), title('Y');
subplot(224), imshow(new_ycbcr), title('YCbCr');
saveas(fig, 'new_ycbcr.png');

end

%%
function [new_rgb] = m_histogram_stretching(de, method_type, normal_luminance, thermal_luminance, old_luminance, normal_ycbcr)
%%
normal_yrange = [min(normal_luminance,[],'all'), max(normal_luminance,[],'all')];
thermal_yrange = [min(thermal_luminance,[],'all'), max(thermal_luminance,[],'all')];

if method_type == 0
    new_yrange = normal_yrange + de .* thermal_yrange;
else
    new_yrange = uint8(double(normal_yrange) + double(thermal_yrange) .^ de);
%     new_yrange = double(normal_yrange) ./ 255 + double(thermal_yrange ./ 255) .^ de;
%     new_yrange = uint8(new_yrange .* 255);
end

A = 0; B = 255;
a = double(new_yrange(1)); b = double(new_yrange(2));
new_luminance = double(old_luminance);
new_luminance = new_luminance - a;
new_luminance = new_luminance .* (B - A);
new_luminance = new_luminance ./ (b - a);
new_luminance = new_luminance + A;
new_luminance = uint8(new_luminance);

new_ycbcr = normal_ycbcr;
new_ycbcr(:,:,1) = new_luminance;
new_rgb = ycbcr2rgb(new_ycbcr);

end
