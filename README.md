# Bark Notification Scripts for *arr Suite

Custom scripts that send notifications from Sonarr, Radarr, Readarr, and Prowlarr to your Bark iOS device.

## Features

- **Complete *arr Suite Support**: Sonarr (TV), Radarr (Movies), Readarr (Books), Prowlarr (Indexers)
- **Multiple Event Support**: Grab, Download, Upgrade, and Health Issue notifications
- **Time-Sensitive Health Alerts**: Health issues trigger priority notifications on iOS
- **Rich Notifications**: Includes episode/movie/book details, quality info, and more
- **Customizable**: Configure sounds, groups, and icons per application
- **Interactive**: Tap notifications to open the relevant page in your *arr app
- **Self-Hosted Support**: Works with both official Bark API and self-hosted servers

## Requirements

- Sonarr/Radarr/Readarr/Prowlarr v3 or later
- Bark iOS app installed on your device
- `curl` (usually pre-installed on most systems)

## Installation

### 1. Get Your Bark Device Key

1. Install the [Bark app](https://apps.apple.com/app/bark-customed-notifications/id1403753865) on your iOS device
2. Open the app and copy your device key (it will look something like: `AbCdEfGhIjKl1234567890`)

### 2. Configure the Scripts

#### A. Configure Shared Settings (bark.conf)

All scripts share common Bark settings via `bark.conf`. Edit this file once:

1. Open `bark.conf`
2. Set your `BARK_KEY` to your device key from step 1
3. (Optional) Customize:
   - `BARK_SERVER`: Default is `https://api.day.app` (change if self-hosted)
   - `BARK_SOUND`: Default notification sound for all apps

Example bark.conf:
```bash
BARK_SERVER="https://api.day.app"
BARK_KEY="AbCdEfGhIjKl1234567890"
BARK_SOUND="bell"
```

#### B. Configure Application-Specific URLs

For each *arr application you want to set up, edit the corresponding script:

**Sonarr** - Edit `sonarr-bark-notify.sh`:
```bash
SONARR_URL="http://192.168.1.100:8989"
```

**Radarr** - Edit `radarr-bark-notify.sh`:
```bash
RADARR_URL="http://192.168.1.100:7878"
```

**Readarr** - Edit `readarr-bark-notify.sh`:
```bash
READARR_URL="http://192.168.1.100:8787"
```

**Prowlarr** - Edit `prowlarr-bark-notify.sh`:
```bash
PROWLARR_URL="http://192.168.1.100:9696"
```

Each script also has its own `BARK_GROUP` and `BARK_ICON` settings that you can customize if desired.

### 3. Add to Your *arr Applications

#### Sonarr (TV Shows)
1. In Sonarr, go to **Settings** → **Connect**
2. Click the **+** button and select **Custom Script**
3. Configure the connection:
   - **Name**: Bark Notifications
   - **Path**: `/path/to/sonarr-bark-notify.sh`
   - Enable the events: On Grab, On Download, On Upgrade, On Health Issue
4. Click **Test** to verify, then **Save**

#### Radarr (Movies)
1. In Radarr, go to **Settings** → **Connect**
2. Click the **+** button and select **Custom Script**
3. Configure the connection:
   - **Name**: Bark Notifications
   - **Path**: `/path/to/radarr-bark-notify.sh`
   - Enable the events: On Grab, On Download, On Upgrade, On Health Issue
4. Click **Test** to verify, then **Save**

#### Readarr (Books)
1. In Readarr, go to **Settings** → **Connect**
2. Click the **+** button and select **Custom Script**
3. Configure the connection:
   - **Name**: Bark Notifications
   - **Path**: `/path/to/readarr-bark-notify.sh`
   - Enable the events: On Grab, On Download, On Upgrade, On Health Issue
4. Click **Test** to verify, then **Save**

#### Prowlarr (Indexers)
1. In Prowlarr, go to **Settings** → **Connect**
2. Click the **+** button and select **Custom Script**
3. Configure the connection:
   - **Name**: Bark Notifications
   - **Path**: `/path/to/prowlarr-bark-notify.sh`
   - Enable the events: On Health Issue, On Application Update
4. Click **Test** to verify, then **Save**

## Notification Types

### Sonarr (TV Shows)

#### 📺 On Grab
- **Priority**: Normal
- **Contains**: Series, episode, quality, indexer
- **Tap Action**: Opens the series page in Sonarr

#### ✅ On Download
- **Priority**: Normal
- **Contains**: Series, episode, quality, file path
- **Tap Action**: Opens the series page in Sonarr

#### ⬆️ On Upgrade
- **Priority**: Normal
- **Contains**: Series, episode, old/new quality
- **Tap Action**: Opens the series page in Sonarr

#### 🔴 On Health Issue
- **Priority**: Time-Sensitive ⚡
- **Contains**: Issue type, message, wiki link
- **Tap Action**: Opens Sonarr system status page

### Radarr (Movies)

#### 🎬 On Grab
- **Priority**: Normal
- **Contains**: Movie title, year, quality, indexer, size
- **Tap Action**: Opens the movie page in Radarr

#### ✅ On Download
- **Priority**: Normal
- **Contains**: Movie title, year, quality, file path
- **Tap Action**: Opens the movie page in Radarr

#### ⬆️ On Upgrade
- **Priority**: Normal
- **Contains**: Movie title, year, old/new quality
- **Tap Action**: Opens the movie page in Radarr

#### 🔴 On Health Issue
- **Priority**: Time-Sensitive ⚡
- **Contains**: Issue type, message, wiki link
- **Tap Action**: Opens Radarr system status page

### Readarr (Books)

#### 📚 On Grab
- **Priority**: Normal
- **Contains**: Author, book title, quality, indexer, size
- **Tap Action**: Opens the book page in Readarr

#### ✅ On Download
- **Priority**: Normal
- **Contains**: Author, book title, quality, file path
- **Tap Action**: Opens the book page in Readarr

#### ⬆️ On Upgrade
- **Priority**: Normal
- **Contains**: Author, book title, old/new quality
- **Tap Action**: Opens the book page in Readarr

#### 🔴 On Health Issue
- **Priority**: Time-Sensitive ⚡
- **Contains**: Issue type, message, wiki link
- **Tap Action**: Opens Readarr system status page

### Prowlarr (Indexers)

#### 🔴 On Health Issue
- **Priority**: Time-Sensitive ⚡
- **Contains**: Issue type, message, wiki link
- **Tap Action**: Opens Prowlarr system status page

#### 🔄 On Application Update
- **Priority**: Normal
- **Contains**: New version, current version
- **Tap Action**: Opens Prowlarr updates page

## Troubleshooting

### Test Notification Doesn't Arrive

1. Check that your Bark device key is correct
2. Verify your device has an internet connection
3. Check application logs: **System** → **Logs** → **Files**
4. Test the script manually:
   ```bash
   # For Sonarr
   sonarr_eventtype=Test ./sonarr-bark-notify.sh

   # For Radarr
   radarr_eventtype=Test ./radarr-bark-notify.sh

   # For Readarr
   readarr_eventtype=Test ./readarr-bark-notify.sh

   # For Prowlarr
   prowlarr_eventtype=Test ./prowlarr-bark-notify.sh
   ```

### Health Notifications Not Time-Sensitive

Ensure you have enabled Time Sensitive notifications for Bark in iOS Settings:
1. Go to **Settings** → **Notifications** → **Bark**
2. Enable **Time Sensitive Notifications**

### Script Not Executing

1. Verify the script is executable:
   ```bash
   chmod +x sonarr-bark-notify.sh
   chmod +x radarr-bark-notify.sh
   chmod +x readarr-bark-notify.sh
   chmod +x prowlarr-bark-notify.sh
   ```
2. Check the path in your *arr app is absolute (not relative)
3. Ensure the application has permission to execute the script

### Self-Hosted Bark Server

If using a self-hosted Bark server, change the `BARK_SERVER` URL in each script:
```bash
BARK_SERVER="http://your-server:8080"
```

### Different Notifications Per Application

Use the `BARK_GROUP` setting to organize notifications by application:
```bash
# In sonarr-bark-notify.sh
BARK_GROUP="Sonarr"

# In radarr-bark-notify.sh
BARK_GROUP="Radarr"

# In readarr-bark-notify.sh
BARK_GROUP="Readarr"

# In prowlarr-bark-notify.sh
BARK_GROUP="Prowlarr"
```

## Available Bark Sounds

Common notification sounds include:
- `alarm`, `anticipate`, `bell`, `birdsong`, `bloom`
- `calypso`, `chime`, `choo`, `descent`, `electronic`
- `fanfare`, `glass`, `gotosleep`, `healthnotification`
- `horn`, `ladder`, `mailsent`, `minuet`, `multiwayinvitation`
- `newmail`, `newsflash`, `noir`, `paymentsuccess`, `shake`
- `sherwoodforest`, `silence`, `spell`, `suspense`
- `telegraph`, `tiptoes`, `typewriters`, `update`

See the Bark app for the complete list.

## Customization

### Custom Icons Per Application

Set different icons for each application:
```bash
# Sonarr
BARK_ICON="https://sonarr.tv/img/logo.png"

# Radarr
BARK_ICON="https://radarr.video/img/logo.png"

# Readarr
BARK_ICON="https://readarr.com/img/logo.png"

# Prowlarr
BARK_ICON="https://prowlarr.com/img/logo.png"
```

### Different Sounds Per Application

Give each application a distinct sound:
```bash
# In sonarr-bark-notify.sh
BARK_SOUND="bell"

# In radarr-bark-notify.sh
BARK_SOUND="chime"

# In readarr-bark-notify.sh
BARK_SOUND="calypso"

# In prowlarr-bark-notify.sh
BARK_SOUND="glass"
```

## Files Included

- **bark.conf** - Shared configuration for all scripts (BARK_SERVER, BARK_KEY, BARK_SOUND)
- **sonarr-bark-notify.sh** - TV show notifications
- **radarr-bark-notify.sh** - Movie notifications
- **readarr-bark-notify.sh** - Book/audiobook notifications
- **prowlarr-bark-notify.sh** - Indexer and update notifications

## Support

For issues or questions:
- Sonarr: https://wiki.servarr.com/sonarr
- Radarr: https://wiki.servarr.com/radarr
- Readarr: https://wiki.servarr.com/readarr
- Prowlarr: https://wiki.servarr.com/prowlarr
- Bark: https://github.com/Finb/Bark

## Default Ports

- Sonarr: 8989
- Radarr: 7878
- Readarr: 8787
- Prowlarr: 9696

## License

These scripts are provided as-is for personal use.
