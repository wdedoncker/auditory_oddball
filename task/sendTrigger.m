function sendTrigger(comport,duration,trigger)
    fwrite(comport,trigger);
    WaitSecs(duration);
    fwrite(comport,0);
end