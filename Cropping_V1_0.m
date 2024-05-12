%tikrina visus RGB pav folderius ir apkerpa

for j = 1:6
    % Nustatykite aplanką (-us), kuriame yra jūsų vaizdai
    switch j
        case 1
            imageFolder = '1. Foto_png_3_classes_full/S (20565R15)/1. FolderisR_S_HQ_OK';
            outputFolder = 'Cropped_S_R';
            if ~exist(outputFolder, 'dir')
                mkdir(outputFolder);
            end

        case 2
            imageFolder = '1. Foto_png_3_classes_full/S (20565R15)/1. FolderisL_S_HQ_OK';
            outputFolder = 'Cropped_S_L';
            if ~exist(outputFolder, 'dir')
                mkdir(outputFolder);
            end            
        case 3
            imageFolder = '1. Foto_png_3_classes_full/M+S (19565R16)/2. FolderisR_M+S_HQ';
            outputFolder = 'Cropped_M+S_R';
            if ~exist(outputFolder, 'dir')
                mkdir(outputFolder);
            end
        case 4
            imageFolder = '1. Foto_png_3_classes_full/M+S (19565R16)/2. FolderisL_M+S_HQ';
            outputFolder = 'Cropped_M+S_L';
            if ~exist(outputFolder, 'dir')
                mkdir(outputFolder);
            end
        case 5
            imageFolder = '1. Foto_png_3_classes_full/M (19565R15)/3. FolderisR_winter_M_HQ';
            outputFolder = 'Cropped_M_R';
            if ~exist(outputFolder, 'dir')
                mkdir(outputFolder);
            end
        case 6
            imageFolder = '1. Foto_png_3_classes_full/M (19565R15)/3. FolderisL_winter_M_HQ';
            outputFolder = 'Cropped_M_L';
            if ~exist(outputFolder, 'dir')
                mkdir(outputFolder);
            end
    end

    % Sukurti ImageDatastore vaizdams įkelti
    imds = imageDatastore(imageFolder);   % kam to reikia?

    % Ciklas per kiekvieną paveikslėlį
    for i = 1:length(imds.Files)
        % Skaityti paveikslėlį
        img = readimage(imds, i);
        
        % Apibrėžkite apkarpomą sritį (pavyzdys: apkarpyti po 100 pikselių iš kiekvienos pusės)

        if mod(j,2) == 1                                %0 lyginis, 1 nelyginis
        croppedImg = img(100:end-50, 50:end-350, :);
        end
        if mod(j,2) == 0                            %0 lyginis, 1 nelyginis
        croppedImg = img(100:end-50, 350:end-50, :);  % Pakoreguokite šias vertes pagal savo reikalavimus
        end


        % Išsaugoti apkarpytą vaizdą
        [~, filename, ext] = fileparts(imds.Files{i});
        outputFilename = fullfile(outputFolder, [filename, '_cropped', ext]);
        imwrite(croppedImg, outputFilename);
    end
        disp(['Tarpinis apkarpymas baigtas. Folder: ', num2str(j)]);
end
    disp('Apkarpymas baigtas.');
%end
