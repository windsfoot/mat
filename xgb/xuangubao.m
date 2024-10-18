% 配置结构体
config = struct(...
    'url', "https://flash-api.xuangubao.cn/api/market_indicator/line?fields=market_temperature", ...
    'filename', 'market_temperature_data.mat' ...
);

% getTem 函数：从 URL 提取市场温度数据
function marketTemperatureData = getTem(config)
    % 初始化温度和时间数组
    temperatures = [];
    timestamps = {};

    % 从 URL 读取数据
    try
        response = webread(config.url);
    catch ME
        error(['Failed to read data from the URL: ', ME.message]);
    end

    % 检查数据是否存在
    if ~isfield(response, 'data') || isempty(response.data)
        error('No data found in the response.');
    end

    % 遍历数据并提取温度和时间
    for i = 1:length(response.data)
        temperatures(i) = response.data(i).market_temperature;
        posixTime = response.data(i).timestamp;
        datetimeShanghai = datetime(uint64(posixTime), 'ConvertFrom', 'posixtime', 'TimeZone', 'Asia/Shanghai');
        timestamps{end+1} = datetimeShanghai;  % 使用单元格数组追加 datetime 对象
    end

    % 将单元格数组转换为 datetime 数组
    timestamps = [timestamps{:}];

    % 将温度和时间赋值给结构体
    marketTemperatureData.Temperatures = temperatures;
    marketTemperatureData.Timestamps = timestamps;
end

% saveDataToMATFile 函数：将数据保存到 MAT 文件中（支持追加模式）
function saveDataToMATFile(marketTemperatureData, config)
    % 读取现有的 MAT 文件（如果存在）
    if exist(config.filename, 'file')
        existingData = load(config.filename);
        if isfield(existingData, 'marketTemperatureData')
            % 合并新数据和现有数据
            marketTemperatureData.Temperatures = [existingData.marketTemperatureData.Temperatures, marketTemperatureData.Temperatures];
            marketTemperatureData.Timestamps = [existingData.marketTemperatureData.Timestamps, marketTemperatureData.Timestamps];
        end
    end

    % 保存数据到 MAT 文件
    try
        save(config.filename, 'marketTemperatureData');  % 直接保存结构体变量
        fprintf('Data has been saved to %s\n', config.filename);
    catch ME
        error(['Failed to save data to MAT file: ', ME.message]);
    end
end

% 主脚本
% 调用 getTem 函数获取数据
marketTemperatureData = getTem(config);



% 保存数据到 MAT 文件
saveDataToMATFile(marketTemperatureData, config);