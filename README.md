# About the Repository

This repository contains two Docker images with different Astra Linux configurations, tailored for lightweight graphical environments and remote access capabilities.
## Notice!

Before build you could change you username and user password. It's necessary if you're using vnc image.

## Images

### Astra Linux SE Fly

A minimal Docker image based on **Astra Linux Special Edition** with only the **Fly window manager** installed.  
It serves as a lightweight foundation for GUI-based applications without unnecessary overhead.

### Astra VNC

This image builds on top of the **Fly window manager** and provides a **VNC server**, allowing remote graphical access via any VNC client.

To run the VNC container, use the following command:

```bash
docker run -p 7777:80 astra-vnc:latest
```

Then open vnc-client (Tight VNC or something else), And enter ip:port for connection to container.
