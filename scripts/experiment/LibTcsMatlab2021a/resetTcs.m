function resetTcs(COM)
    ser = TcsOpenCom(COM);
    TcsAbortStimulation(ser)
    TcsSetBaseLine(ser,30)
    disp('Thermode has been reset')
end