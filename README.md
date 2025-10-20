# M3U8 Downloader

A simple and efficient bash script to download M3U8 video streams using FFmpeg. This tool provides a convenient alias that makes downloading M3U8 streams as easy as running a single command.

## ⚡ Quick Install [Linux, macOS, Windows]

**Linux & macOS:**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Diercohen/m3u8-downloader/refs/heads/main/install.sh)"
```

**Windows (PowerShell):**

```powershell
# Method 1: Direct execution (recommended)
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Diercohen/m3u8-downloader/refs/heads/main/install.ps1" -UseBasicParsing).Content

# Method 2: If you get execution policy errors, use bypass
PowerShell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Diercohen/m3u8-downloader/refs/heads/main/install.ps1' -UseBasicParsing).Content"
```

## 🚀 Features

- **One-command installation**: Automated setup script handles everything
- **Cross-platform support**: Works on macOS, Linux, and Windows
- **Automatic FFmpeg installation**: Installs FFmpeg if not present
- **Smart shell detection**: Automatically detects bash/zsh/PowerShell and configures accordingly
- **Alias management**: Safely replaces existing aliases
- **User-friendly interface**: Interactive prompts for easy usage

## 📋 Requirements

- **FFmpeg**: The script will automatically install it if missing
- **Shell**: Compatible with Bash, Zsh, and PowerShell
- **Internet connection**: For downloading M3U8 streams

### Additional Requirements by Platform

#### macOS

- **Homebrew**: Required for automatic FFmpeg installation
  - Install Homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

#### Linux

- **Package manager**: One of the following (for automatic FFmpeg installation):
  - `apt-get` (Ubuntu/Debian)
  - `yum` (CentOS/RHEL)
  - `dnf` (Fedora)
  - `pacman` (Arch Linux)

#### Windows

- **Package manager**: One of the following (for automatic FFmpeg installation):
  - `winget` (built-in on Windows 10/11)
  - `choco` (Chocolatey)
  - `scoop` (Scoop)

## 🛠️ Installation

### Quick Installation

1. **Clone or download this repository**:

   ```bash
   git clone https://github.com/yourusername/m3u8-downloader.git
   cd m3u8-downloader
   ```

2. **Run the installation script**:

   ```bash
   # For Linux/macOS
   ./install.sh

   # For Windows PowerShell
   .\install.ps1
   ```

3. **Reload your shell configuration**:

   ```bash
   # For zsh users
   source ~/.zshrc

   # For bash users
   source ~/.bashrc
   # or
   source ~/.bash_profile

   # For PowerShell users
   . $PROFILE
   ```

### Manual Installation

If you prefer to install manually:

1. **Install FFmpeg** (if not already installed):

   **macOS**:

   ```bash
   brew install ffmpeg
   ```

   **Linux**:

   ```bash
   # Ubuntu/Debian
   sudo apt-get update && sudo apt-get install ffmpeg

   # CentOS/RHEL
   sudo yum install ffmpeg

   # Fedora
   sudo dnf install ffmpeg

   # Arch Linux
   sudo pacman -S ffmpeg
   ```

   **Windows**:

   ```powershell
   # Using winget (Windows 10/11)
   winget install ffmpeg

   # Using Chocolatey
   choco install ffmpeg -y

   # Using Scoop
   scoop install ffmpeg
   ```

2. **Add the alias/function to your shell configuration**:

   **For Zsh users** (add to `~/.zshrc`):

   ```bash
   alias m3u8='echo "Enter m3u8 link to download by ffmpeg:";read link;echo "Enter output filename:";read filename;ffmpeg -i "$link" -bsf:a aac_adtstoasc -vcodec copy -c copy -crf 50 $filename.mp4'
   ```

   **For Bash users** (add to `~/.bashrc` or `~/.bash_profile`):

   ```bash
   alias m3u8='echo "Enter m3u8 link to download by ffmpeg:";read link;echo "Enter output filename:";read filename;ffmpeg -i "$link" -bsf:a aac_adtstoasc -vcodec copy -c copy -crf 50 $filename.mp4'
   ```

   **For PowerShell users** (add to PowerShell profile):

   ```powershell
   function m3u8 {
       $link = Read-Host "Enter m3u8 link to download by ffmpeg"
       $filename = Read-Host "Enter output filename"
       ffmpeg -i $link -bsf:a aac_adtstoasc -vcodec copy -c copy -crf 50 "$filename.mp4"
   }
   ```

3. **Reload your shell configuration**:

   ```bash
   # For bash/zsh
   source ~/.zshrc  # or ~/.bashrc

   # For PowerShell
   . $PROFILE
   ```

## 📖 Usage

### Basic Usage

Simply run the `m3u8` command in your terminal:

```bash
m3u8
```

The script will prompt you for:

1. **M3U8 link**: The URL of the M3U8 stream you want to download
2. **Output filename**: The name for your downloaded video file (without extension)

### Example Session

```bash
$ m3u8
Enter m3u8 link to download by ffmpeg:
https://example.com/stream.m3u8
Enter output filename:
my_video
```

This will download the stream and save it as `my_video.mp4`.

### Common Use Cases

#### Downloading from Video Streaming Sites

```bash
m3u8
# Enter: https://streaming-site.com/playlist.m3u8
# Enter: episode_01
# Result: episode_01.mp4
```

#### Downloading Live Streams

```bash
m3u8
# Enter: https://live-stream.com/live.m3u8
# Enter: live_recording
# Result: live_recording.mp4
```

#### Batch Downloads

You can create a simple script to download multiple streams:

```bash
#!/bin/bash
# download_multiple.sh

streams=(
    "https://site1.com/stream1.m3u8"
    "https://site2.com/stream2.m3u8"
    "https://site3.com/stream3.m3u8"
)

for i in "${!streams[@]}"; do
    echo "Downloading stream $((i+1))..."
    echo "${streams[i]}" | m3u8
done
```

## 🔧 FFmpeg Parameters Explained

The script uses these FFmpeg parameters for optimal quality and compatibility:

- `-i "$link"`: Input M3U8 stream URL
- `-bsf:a aac_adtstoasc`: Bitstream filter for AAC audio compatibility
- `-vcodec copy`: Copy video stream without re-encoding (faster)
- `-c copy`: Copy all streams without re-encoding
- `-crf 50`: Constant Rate Factor for quality (lower = better quality)

## 🐛 Troubleshooting

### Common Issues

#### "ffmpeg: command not found"

- **Solution**: Run the installation script again or install FFmpeg manually
- **macOS**: `brew install ffmpeg`
- **Linux**: Use your package manager (see manual installation above)

#### "Permission denied" when running install.sh

- **Solution**: Make the script executable:
  ```bash
  chmod +x install.sh
  ```

#### "Homebrew not found" on macOS

- **Solution**: Install Homebrew first:
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

#### "No package manager found" on Windows

- **Solution**: Install a package manager:

  ```powershell
  # Install Chocolatey
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

  # Or install Scoop
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  irm get.scoop.sh | iex
  ```

#### PowerShell execution policy error on Windows

This error occurs when PowerShell's execution policy prevents script execution. Here are several solutions:

**Solution 1: Bypass execution policy for current session (recommended)**

```powershell
# Run this command first, then run the installation:
Set-ExecutionPolicy Bypass -Scope Process
```

**Solution 2: Change execution policy permanently**

```powershell
# Run PowerShell as Administrator, then:
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Solution 3: Use bypass in command (alternative)**

```powershell
# Use the bypass method in the quick install command above
PowerShell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Diercohen/m3u8-downloader/refs/heads/main/install.ps1' -UseBasicParsing).Content"
```

#### Alias/function not working after installation

- **Solution**: Reload your shell configuration:

  ```bash
  # For bash/zsh
  source ~/.zshrc  # or ~/.bashrc

  # For PowerShell
  . $PROFILE
  ```

#### Download fails with "Invalid data found"

- **Possible causes**:
  - Invalid M3U8 URL
  - Stream requires authentication
  - Network connectivity issues
- **Solutions**:
  - Verify the M3U8 URL is correct
  - Check if the stream requires special headers or authentication
  - Test with a different M3U8 stream

#### Slow download speeds

- **Solutions**:
  - Check your internet connection
  - Try downloading during off-peak hours
  - Some streams may have bandwidth limitations

### Getting Help

If you encounter issues:

1. **Check FFmpeg installation**:

   ```bash
   ffmpeg -version
   ```

2. **Verify the alias/function is installed**:

   ```bash
   # For bash/zsh
   alias | grep m3u8

   # For PowerShell
   Get-Command m3u8
   ```

3. **Test with a simple M3U8 stream**:
   ```bash
   ffmpeg -i "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8" test.mp4
   ```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## ⭐ Acknowledgments

- [FFmpeg](https://ffmpeg.org/) - The powerful multimedia framework
- [Homebrew](https://brew.sh/) - The macOS package manager
- The open-source community for continuous improvements

---

**Happy downloading!** 🎬
