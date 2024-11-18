function TcsSaveData(TcsData, filenameInfo)

if ~exist(filenameInfo)
    csvwrite([filenameInfo '.csv'], TcsData);
else
    csvwrite([filenameInfo '.csv'], TcsData, '-append');
end
        

