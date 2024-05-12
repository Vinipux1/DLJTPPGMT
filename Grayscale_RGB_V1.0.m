% Apibrėžkite kelią iki aplanko, kuriame yra pilkos spalvos vaizdai
%folderPath = 'Grayscale/S (20565R15)';
%folderPath = 'Grayscale/M+S (19565R16)';
folderPath = 'Grayscale/M (19565R15)';

% Sukurti "ImageDatastore" objektą pilkos skalės vaizdams skaityti
grayscaleDatastore = imageDatastore(folderPath);

% Sukurti aplanką RGB vaizdams išsaugoti
outputFolderPath = 'RGB';
if ~exist(outputFolderPath, 'dir')
    mkdir(outputFolderPath);
end

% Ciklas per kiekvieną pilkosios skalės vaizdą
for i = 1:numel(grayscaleDatastore.Files)
    % Read the grayscale image
    grayImage = readimage(grayscaleDatastore, i);
    
    % Konvertuoti pilkosios skalės vaizdą į RGB
    rgbImage = cat(3, grayImage, grayImage, grayImage);
    
    % Konvertuoti vaizdą iš UINT16 į UINT8  t.y. iš 16 bitų į 8 bitų
    rgbImage = im2uint8(rgbImage);
    
    % RGB vaizdą įrašykite į aplanką
    [~, filename, ~] = fileparts(grayscaleDatastore.Files{i});
    imwrite(rgbImage, fullfile(outputFolderPath, [filename, '.jpg']));
end

disp('Konvertavimas baigtas. RGB vaizdai įrašyti į išvesties aplanką.');
