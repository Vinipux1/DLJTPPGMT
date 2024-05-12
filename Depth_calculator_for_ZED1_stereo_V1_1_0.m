%% 0 skyrius. Bandymai su ZED 1 kamera išgauti profilį
clc; clear; close;

%% 1 skyrius: Importuokite stereo vaizdų porą ir atvaizduokite
leftImage = imread('image_left_1.png');
rightImage = imread('image_right_1.png');

%leftImage = imread('DepthViewer_SbS_LEFT.png');
%rightImage = imread('DepthViewer_SbS_RIGHT.png');

combinedImage = [leftImage , rightImage];

figure;
imshow(combinedImage);

%% 2 skyrius. Išankstinis vaizdų apdorojimas

% Vaizdų konvertavimas į pilkumo skalę
leftGray = rgb2gray(leftImage);
rightGray = rgb2gray(rightImage);




figure; %atvaizduojame
montage([leftGray, rightGray]);

%% 2A skyrius. Histogramos išlyginimas (papildoma)
leftEnhanced = histeq(leftGray);
rightEnhanced = histeq(rightGray);
figure;
montage([leftEnhanced, rightEnhanced]);
title('Patobulinti pilkosios skalės vaizdai');

%% 3 skyrius. 3D atvaizdavimas

figure;
surf(leftEnhanced);
colormap('parula');  % Malonus ir veiksmingas spalvų žemėlapis
shading interp;      % Interpoliuoja spalvas tarp veidų ir viršūnių
light;               % Prideda šviesos objektą
lighting phong;      % Naudojamas "Phong" apšvietimo modelis gylio pojūčiui sukurti
colorbar;            % Prideda spalvų skalę

figure;
surf(rightEnhanced);
axis tight;
view(0, 90);         % Žiūrima tiesiai žemyn ant Z ašies
colormap('parula');  % Malonus ir veiksmingas spalvų žemėlapis
shading interp;      % Interpoliuoja spalvas tarp veidų ir viršūnių
light;               % Prideda šviesos objektą
lighting phong;      % Naudojamas "Phong" apšvietimo modelis gylio pojūčiui sukurti
colorbar;            % Prideda spalvų skalę


%% 4 skyrius. ištaisykite stereovaizdus (paprastas ištaisymas be kalibravimo). Transformavimas.
% Užtikrinkite, kad abu vaizdai būtų vienodo dydžio

minSize = min(size(leftEnhanced), size(rightEnhanced));
leftEnhanced = leftEnhanced(1:minSize(1), 1:minSize(2));
rightEnhanced = rightEnhanced(1:minSize(1), 1:minSize(2));

% Konvertuoti vaizdus į tą patį duomenų tipą
leftEnhanced = im2single(leftEnhanced);    %Konvertuoti vaizdą į vieno tikslumo
rightEnhanced = im2single(rightEnhanced);  %Konvertuoti vaizdą į vieno tikslumo

% SURF požymių ir juos atitinkančių deskriptorių aptikimas
pointsLeft = detectSURFFeatures(leftEnhanced);
pointsRight = detectSURFFeatures(rightEnhanced);

[featuresLeft, validPointsLeft] = extractFeatures(leftEnhanced, pointsLeft);
[featuresRight, validPointsRight] = extractFeatures(rightEnhanced, pointsRight);

% Suderinti stereovaizdų požymius
indexPairs = matchFeatures(featuresLeft, featuresRight);

% Ištraukti suderintų taškų vietas
matchedPointsLeft = validPointsLeft(indexPairs(:, 1));
matchedPointsRight = validPointsRight(indexPairs(:, 2));

% Sukurti identitetinę transformaciją
tform = affine2d(eye(3));  % 'eye(3)' sukuria 3x3 identitetinę matricą
% Taikyti apskaičiuotą transformaciją vaizdams ištaisyti
 leftRect = imwarp(leftEnhanced, tform);         %Taikyti geometrinę transformaciją vaizdui
 rightRect = imwarp(rightEnhanced, tform);       %Taikyti geometrinę transformaciją vaizdui

figure;
montage([leftRect, rightRect]);      

%% 5 skyrius. žaliosios linijos aptikimas
% a) Spalvų segmentavimas
% greenMask = createGreenMask(leftRect);
greenMask = createGreenMask(leftImage);

figure;
imshow(greenMask)

%% b) Morfologinės operacijos
greenMask = imopen(greenMask, strel('disk', 2));

figure;
imshow(greenMask)

%% c) Išskirkite kontūrus arba naudokite kraštų aptikimą
greenContour = edge(greenMask, 'Canny');

figure;
imshow(greenContour)

%% 6 skyrius. Stereoskopinis sulyginimas
% a) Bloko atitikimas
disparityMap = blockMatching(leftRect, rightRect);

figure;
imshow(disparityMap)

%% b) Apskaičiuokite skirtumų žemėlapį išilgai žalios linijos
greenDisparity = disparityMap(greenContour);

figure;
imshow(greenDisparity) 

%% 7 skyrius. Gylio apskaičiavimas (trianguliacija)
depthValues = depthTriangulation(greenDisparity);

%% 8 skyrius. Padangos gylio profilio išskyrimas
% a) Interpretuokite gylio vertes, kad sudarytumėte gylio profilį
tireDepthProfile = interpretDepthProfile(depthValues);

%% 9 skyrius. Vizualizavimas
% Nubraižykite gylio profilį
figure;
plot(tireDepthProfile, 'LineWidth', 2);
xlabel('Padangos plotis (nesukalibruotas), mm');
ylabel('Profilio aukštis (nesukalibruotas), um');
title('Padangų gylio profilis su ZED 1');
grid on;

%% Pagalbinės funkcijos
function mask = createGreenMask(image)

    % Ensure the image has the correct size
    if size(image, 3) ~= 3
        error('Input image must be a color image (RGB).');
    end

    greenRange = [0.2 1 0];
    mask = (image(:,:,1) >= greenRange(1)) & ...
           (image(:,:,2) >= greenRange(2)) & ...
           (image(:,:,3) >= greenRange(3));
end

function disparityMap = blockMatching(left, right)
    % Įgyvendinti blokų atitikimo algoritmą
    disparityMap = disparity(left, right);
end

function depthValues = depthTriangulation(disparityMap)
    baseline = 120; % Numatomas bazinis atstumas (stereo labs)
    focalLength = 500; % Numatomas židinio nuotolis
    depthValues = focalLength * baseline ./ disparityMap;
end

function tireDepthProfile = interpretDepthProfile(depthValues)
    tireDepthProfile = mean(depthValues, 2); % Pavyzdys: vidutinės reikšmės išilgai stulpelių nustatymas
end
