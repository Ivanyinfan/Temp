tasklist
tasklist /FI "IMAGENAME eq python.exe"
taskkill /f /pid 1111
taskkill /f /IM python.exe
runas /noprofile /user:Administrator "net start MySQL"
runas /noprofile /user:Administrator "net stop MySQL"