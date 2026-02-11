@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"
echo SUITES
set "CUSTOM_DOMAINS="
for /f "usebackq tokens=* delims=" %%a in ("SUITES.txt") do (
    set "line=%%a"
    for /f "tokens=* delims= " %%b in ("!line!") do set "line=%%b"
    for /f "tokens=* delims=	" %%b in ("!line!") do set "line=%%b"
    if not "!line!"=="" if not "!line:~0,1!"=="#" (
        set "line=!line:http://=!"
        set "line=!line:https://=!"
        if "!line:~-1!"=="/" set "line=!line:~0,-1!"
        if not "!line!"=="" (
            if "!CUSTOM_DOMAINS!"=="" (
                set "CUSTOM_DOMAINS=!line!"
            ) else (
                set "CUSTOM_DOMAINS=!CUSTOM_DOMAINS!,!line!"
            )
        )
    )
)
echo !CUSTOM_DOMAINS!
(
echo --wf-tcp=80,443,2053,2083,2087,2096,8443
echo --wf-udp=443,19294-19344,50000-50100
echo --filter-udp=443
echo --hostlist-domains=discord.com,youtube.com,googlevideo.com,ytimg.com,ggpht.com,arena.ai,chatgpt.com,!CUSTOM_DOMAINS!
echo --dpi-desync=fake
echo --dpi-desync-repeats=5
echo --dpi-desync-fake-quic=quic_initial_www_google_com.bin
echo --new
echo --filter-udp=19294-19344,50000-50100
echo --filter-l7=discord,stun
echo --dpi-desync=fake
echo --dpi-desync-repeats=5
echo --new
echo --filter-tcp=2053,2083,2087,2096,8443
echo --hostlist-domains=discord.media,!CUSTOM_DOMAINS!
echo --dpi-desync=fake,fakedsplit
echo --dpi-desync-repeats=20
echo --dpi-desync-fooling=ts
echo --dpi-desync-fakedsplit-pattern=0x00
echo --dpi-desync-fake-tls=tls_clienthello_www_google_com.bin
echo --new
echo --filter-tcp=443
echo --hostlist-domains=youtube.com,googlevideo.com,ytimg.com,ggpht.com,gstatic.com,googleapis.com,arena.ai,chatgpt.com,!CUSTOM_DOMAINS!
echo --dpi-desync=fake,fakedsplit
echo --dpi-desync-repeats=5
echo --dpi-desync-fooling=ts
echo --dpi-desync-fakedsplit-pattern=0x00
echo --dpi-desync-fake-tls=tls_clienthello_www_google_com.bin
echo --new
echo --filter-tcp=80,443
echo --hostlist-domains=discord.com,discord.gg,discordapp.com,discord.media,!CUSTOM_DOMAINS!
echo --dpi-desync=fake,fakedsplit
echo --dpi-desync-repeats=5
echo --dpi-desync-fooling=ts
echo --dpi-desync-fakedsplit-pattern=0x00
echo --dpi-desync-fake-tls=tls_clienthello_www_google_com.bin
) > winsf.conf
echo OK
taskkill /F /IM winws.exe >nul 2>&1
timeout /t 1 >nul
start "" /B winws.exe --debug @winsf.conf