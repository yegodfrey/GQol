# GQol - World of Warcraft Enhancement Addon

GQol is a comprehensive World of Warcraft enhancement addon that provides various useful features to enhance your gaming experience.

## Feature List

- [Audio Assistant](#audio-assistant) - Quick sound toggle and audio device switching
- [Compass](#compass) - Display direction pointer on minimap and world map
- [Zone Brightness Adjustment](#zone-brightness-adjustment) - Set independent brightness, gamma, and contrast for different zones
- [Space Assistant](#space-assistant) - Quick interaction assistant for quests, dialogs, trades, entering/leaving battlegrounds, crafting orders, etc., with quick confirmation via spacebar
- [Free Camera](#free-camera) - Enter free camera mode, no need to hold right mouse button to adjust view, reducing finger fatigue during dragonriding and other scenarios
- [Combat Double-Click Targeting](#combat-double-click-targeting) - Requires double right-click to select targets in combat, avoiding accidental target selection when rotating the camera
- [Target Distance Display](#target-distance-display) - Display distance to target
- [Group Finder Assistant](#group-finder-assistant) - Unified display of applied groups during application phase, supports quick cancellation; displays dungeon teleport spells and tracks wait time and application count when joining a group
- [Profession Skill Tabs](#profession-skill-tabs) - Display profession tabs on the right side of the spellbook
- [System Settings](#system-settings) - Save and load system settings and key bindings
- [Action Bar Profiles](#action-bar-profiles) - Save and load action bar configurations by specialization
- [Macro Management](#macro-management) - Save and load general macros and class macros
- [Edit Mode](#edit-mode) - Save and load UI layouts
- [Auto Roll](#auto-roll) - Automatically roll Need, Greed, Transmog, or Pass on loot items

---

## Detailed Feature Introduction

### Audio Assistant

Audio assistant provides a mini icon for quickly toggling game sound and switching audio output devices.

**Main Features:**
- Left click: Toggle game sound on/off
- Right click: Switch audio output device (skips last device)
- Shift + Left drag: Move icon position
- Customizable icon size
- Supports resetting icon position to default

**Commands:**
- `/gqol sound` - Quick sound toggle

---

### Compass

Displays a compass pointer showing the player's direction on the minimap and world map.

**Main Features:**
- Displays direction pointer on minimap
- Displays direction pointer on world map
- Customizable pointer thickness (minimap/world map separate settings)
- Customizable refresh interval
- Customizable pointer color

---

### Zone Brightness Adjustment

Automatic zone brightness adjustment, allows setting independent brightness, gamma, and contrast for different zones.

**Main Features:**
- Save independent brightness settings for different zones
- Add current zone to management list
- Remove zone from management list
- Save baseline brightness configuration
- Automatically switch zone brightness

**Commands:**
- `/gqol add` - Add current zone to management list
- `/gqol del` - Remove current zone from management list
- `/gqol save` - Save current brightness as baseline configuration

---

### Space Assistant

Spacebar shortcut interaction assistant, use spacebar and number keys 1-5 to quickly complete various interaction operations.

**Supported Keys:**
- Spacebar: Select first option by default
- Number keys 1-5: Select corresponding position option

**Supported Windows:**
- Quest window: Accept quest, complete quest
- Dialog window: Select dialog options
- Dialog boxes: Confirmation dialogs, enter dungeon, enter battleground, accept invite, ready check, role check
- Battleground results window: Leave button
- Honor level up window: Continue button
- Profession crafting window: Start order, create, complete order
- Compatible with PatronOffers addon

**Commands:**
- `/gqol sbt` - Quick toggle space assistant on/off

---

### Free Camera

Free camera mode, releases mouse camera control when holding specified keys, avoiding finger fatigue during dragonriding and other scenarios.

**Main Features:**
- Customizable trigger key (Ctrl/Shift/Alt)
- Adjustable long press delay time
- Long press key to automatically enter free camera
- Release key to exit free camera

---

### Combat Double-Click Targeting

Requires double right-click to select targets in combat, avoiding accidental target selection when rotating the camera. Recommended to also enable "Left Click Interact" in system settings.

**Main Features:**
- Double right-click to select targets in combat
- Prevents accidental selection when rotating camera
- Compatible with system "Left Click Interact" setting

---

### Target Distance Display

Displays distance information to current target, supports customizable colors, size, and position.

**Main Features:**
- Display distance to target
- Customizable colors for within/outside attack range
- Adjustable font size
- Adjustable frame scale
- Adjustable hide distance threshold
- Lock/unlock position
- Supports position reset

---

### Group Finder Assistant

Group finder interface assistant, displays dungeon teleport button, application statistics, and list of pending applications in the group finder interface.

**Main Features:**
- Displays dungeon teleport spell button (shows cooldown)
- Tracks application count and wait time
- Displays list of pending applications
- Can cancel pending applications
- Adjustable font size
- Adjustable frame scale
- Supports position reset
- Draggable frame

**Commands:**
- `/gqol show` - Force show group finder assistant
- `/gqol hide` - Hide group finder assistant

---

### Profession Skill Tabs

Displays profession skill tabs on the right side of the spellbook for quick access to profession skills.

**Main Features:**
- Displays profession tabs on the right side of spellbook
- Click tab to directly use corresponding skill
- Automatically identifies available profession skills
- Supports switching to flight mode (if learned)

---

### System Settings

Save and load system settings (gamma, brightness, contrast, sound, etc.) and key binding profiles, supports automatic application on login.

**Main Features:**
- Save current system settings
- Apply saved system settings
- Save and load key bindings
- Supports automatic application on login

---

### Action Bar Profiles

Save and load action bar profiles by specialization, supports automatic application on login or specialization switch.

**Main Features:**
- Save current specialization's action bar configuration
- Apply saved action bar configuration
- Automatically apply corresponding profile when switching specialization
- Automatically apply current specialization profile on login

---

### Macro Management

Save and load general macro and class macro profiles, class macros saved separately by class, supports automatic application on login.

**Main Features:**
- Save and load general macros
- Save and load class macros (separated by class)
- Supports automatic application on login

---

### Edit Mode

Save and load edit mode layout profiles, supports automatic application on login.

**Main Features:**
- Save current edit mode layout
- Apply saved layout
- Supports automatic application on login and specialization switch

---

### Auto Roll

Click the "Auto Loot" button to automatically roll Need, Greed, or Transmog on loot items (Need > Greed > Transmog).

**Main Features:**
- Shows "Auto Loot" button when loot becomes available (top of screen)
- Click button to automatically process all items
- Fixed strategy: Need > Greed > Transmog
- Displays auto roll result notifications

---

## Configuration Panel

Use the `/gqol` command to open the configuration panel, where you can configure all features.
