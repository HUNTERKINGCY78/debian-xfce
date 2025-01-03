# Gunakan image Debian 12 sebagai basis
FROM debian:bookworm

# Install XFCE, NoVNC, dan dependensi
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies xfce4-terminal novnc websockify \
    x11vnc xvfb supervisor curl wget net-tools && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Konfigurasi VNC dengan password default
RUN mkdir -p ~/.vnc && \
    x11vnc -storepasswd 1234 ~/.vnc/passwd

# Tambahkan tema gelap dan atur desktop XFCE
RUN echo '[Settings]\nxsettings/Net/ThemeName=Adwaita-dark' > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml && \
    mkdir -p ~/.config/xfce4/panel && \
    echo '[panels]\npanel-0/size=48\n' > ~/.config/xfce4/panel/default.xml

# Konfigurasi Supervisor
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Tambahkan NoVNC
RUN mkdir -p /novnc && \
    curl -L https://github.com/novnc/noVNC/archive/v1.4.0.tar.gz | tar xz -C /novnc --strip-components=1 && \
    ln -s /novnc/utils/websockify /usr/local/bin/websockify

# Set environment variables
ENV DISPLAY=:0
EXPOSE 8080

# Jalankan Supervisor untuk mengelola layanan
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
